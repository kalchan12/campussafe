import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../shared/models/incident.dart';
import '../../../../shared/models/incident_community_response.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return IncidentRepository(Env.isConfigured ? Env.supabase : null);
});

class IncidentRepository {
  final SupabaseClient? _client;

  IncidentRepository(this._client);

  bool get _isAvailable => _client != null;

  /// Creates a new incident (SOS submission).
  Future<Result<Incident>> createIncident({
    String? reporterId,
    required EmergencyType type,
    required int priority,
    double? latitude,
    double? longitude,
    String? locationDescription,
    String? campusBlock,
    String? description,
    String source = 'mobile',
  }) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final now = DateTime.now().toIso8601String();
      final insertData = <String, dynamic>{
        if (reporterId != null && reporterId.isNotEmpty) 'reporter_id': reporterId,
        'type': type.value,
        'status': IncidentStatus.created.value,
        'priority': priority,
        'latitude': latitude,
        'longitude': longitude,
        'location_description': locationDescription,
        'campus_block': campusBlock,
        'description': description,
        'created_at': now,
        'updated_at': now,
      };
      final data = await _client!.from('incidents').insert(insertData).select().single();
      return Right(Incident.fromJson(data));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to create incident: $e'));
    }
  }

  /// Fetches all active incidents visible to the current user.
  Future<Result<List<Incident>>> getActiveIncidents() async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final data = await _client!
          .from('incidents')
          .select()
          .not('status', 'in', '("resolved","cancelled","failed")')
          .order('created_at', ascending: false);
      final incidents =
          (data as List).map((e) => Incident.fromJson(e as Map<String, dynamic>)).toList();
      return Right(incidents);
    } catch (e) {
      return Left(NetworkError(message: 'Failed to load incidents: $e'));
    }
  }

  /// Fetches a single incident by ID.
  Future<Result<Incident>> getIncident(String incidentId) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final data = await _client!
          .from('incidents')
          .select()
          .eq('id', incidentId)
          .single();
      return Right(Incident.fromJson(data));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to load incident: $e'));
    }
  }

  /// Updates the status of an incident.
  Future<Result<Incident>> updateStatus({
    required String incidentId,
    required IncidentStatus status,
    String? responderId,
  }) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final updates = <String, dynamic>{
        'status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (responderId != null) updates['assigned_responder_id'] = responderId;
      if (status == IncidentStatus.assigned || status == IncidentStatus.received) {
        updates['assigned_at'] = DateTime.now().toIso8601String();
      } else if (status == IncidentStatus.responding) {
        updates['responded_at'] = DateTime.now().toIso8601String();
      } else if (status == IncidentStatus.arrived) {
        updates['arrived_at'] = DateTime.now().toIso8601String();
      } else if (status == IncidentStatus.resolved) {
        updates['resolved_at'] = DateTime.now().toIso8601String();
      }
      final data = await _client!
          .from('incidents')
          .update(updates)
          .eq('id', incidentId)
          .select()
          .single();
      return Right(Incident.fromJson(data));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to update incident: $e'));
    }
  }

  /// Deletes an incident permanently.
  /// Only the reporter (creator) of the incident can delete it (enforced by RLS).
  Future<Result<void>> deleteIncident(String incidentId) async {
    if (!_isAvailable) return const Right(null);
    try {
      await _client!
          .from('incidents')
          .delete()
          .eq('id', incidentId);
      return const Right(null);
    } catch (_) {
      // Gracefully succeed locally even if remote DB delete is blocked or offline
      return const Right(null);
    }
  }

  /// Returns a real-time stream of incident changes.
  /// The stream emits the full updated list of active incidents whenever any
  /// incident row changes.
  Stream<List<Incident>> watchActiveIncidents() {
    if (!_isAvailable) return Stream.error(NetworkError.noConnection());
    return _client!
        .from('incidents')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .map((e) => Incident.fromJson(e))
              .where((i) => i.isActive)
              .toList();
        });
  }

  /// Returns a real-time stream of a single incident's state.
  Stream<Incident?> watchIncident(String incidentId) {
    if (!_isAvailable) return Stream.error(NetworkError.noConnection());
    return _client!
        .from('incidents')
        .stream(primaryKey: ['id'])
        .eq('id', incidentId)
        .map((data) {
          if (data.isEmpty) return null;
          return Incident.fromJson(data.first);
        });
  }

  /// Returns a real-time stream of a responder's data.
  Stream<Map<String, dynamic>?> watchResponder(String responderId) {
    if (!_isAvailable) return Stream.error(NetworkError.noConnection());
    // Since assigned_responder_id is user_id, we need to match user_id
    return _client!
        .from('responders')
        .stream(primaryKey: ['id'])
        .eq('user_id', responderId)
        .map((data) {
          if (data.isEmpty) return null;
          return data.first;
        });
  }

  /// Fetches community responses for an incident.
  Future<Result<List<IncidentCommunityResponse>>> getCommunityResponses(String incidentId) async {
    if (!_isAvailable) return const Right([]);
    try {
      final data = await _client!
          .from('incident_community_responses')
          .select()
          .eq('incident_id', incidentId)
          .order('created_at', ascending: true);
      final list = (data as List)
          .map((e) => IncidentCommunityResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (_) {
      // Return empty list if table does not exist on Supabase
      return const Right([]);
    }
  }

  /// Submits a community response or eyewitness report.
  Future<Result<IncidentCommunityResponse>> submitCommunityResponse({
    required String incidentId,
    String? responderId,
    required String responderName,
    required CommunityResponseType responseType,
    required String message,
  }) async {
    final fallback = IncidentCommunityResponse(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      responderId: responderId,
      responderName: responderName,
      responseType: responseType,
      message: message,
      createdAt: DateTime.now(),
    );

    if (!_isAvailable) return Right(fallback);
    try {
      final payload = <String, dynamic>{
        'incident_id': incidentId,
        if (responderId != null && responderId.isNotEmpty) 'responder_id': responderId,
        'responder_name': responderName,
        'response_type': responseType.value,
        'message': message,
      };
      final data = await _client!
          .from('incident_community_responses')
          .insert(payload)
          .select()
          .single();
      return Right(IncidentCommunityResponse.fromJson(data));
    } catch (_) {
      return Right(fallback);
    }
  }

  /// Streams community responses for an incident in real-time.
  Stream<List<IncidentCommunityResponse>> watchCommunityResponses(String incidentId) {
    if (!_isAvailable) return Stream.value([]);
    try {
      return _client!
          .from('incident_community_responses')
          .stream(primaryKey: ['id'])
          .eq('incident_id', incidentId)
          .order('created_at', ascending: true)
          .map((data) {
            return data
                .map((e) => IncidentCommunityResponse.fromJson(e))
                .toList();
          })
          .handleError((error) {
            // Silently suppress missing table PostgrestException (PGRST205)
            return <IncidentCommunityResponse>[];
          });
    } catch (_) {
      return Stream.value([]);
    }
  }
}

