import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/incident_queue_db.dart';
import '../../features/incidents/data/repositories/incident_repository.dart';
import '../../features/incidents/presentation/state/incidents_provider.dart';
import '../../shared/models/incident.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final queueDb = ref.watch(incidentQueueDbProvider);
  final incidentRepo = ref.watch(incidentRepositoryProvider);
  return SyncService(ref, queueDb, incidentRepo);
});

class SyncService {
  final Ref _ref;
  final IncidentQueueDb _queueDb;
  final IncidentRepository _incidentRepo;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(this._ref, this._queueDb, this._incidentRepo) {
    _initConnectivityListener();
    syncPendingIncidents();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncPendingIncidents();
      }
    });
  }

  Future<void> syncPendingIncidents() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingIncidents = await _queueDb.getPendingIncidents();
      
      for (final payload in pendingIncidents) {
        final localId = payload.remove('_local_id') as String;
        
        // Reconstruct type
        final emergencyType = EmergencyType.fromString(payload['type'] ?? 'other');
        
        final result = await _incidentRepo.createIncident(
          reporterId: payload['reporterId'],
          type: emergencyType,
          priority: payload['priority'] ?? 1,
          latitude: payload['latitude'],
          longitude: payload['longitude'],
          locationDescription: payload['locationDescription'],
          campusBlock: payload['campusBlock'],
          description: payload['description'],
          source: payload['source'] ?? 'mobile_queued',
        );

        result.fold(
          (error) {
            // Keep in queue if network error, maybe delete if it's a 400 Bad Request
            print('Failed to sync queued incident: ${error.message}');
          },
          (incident) {
            // Successfully synced, remove from queue
            _queueDb.removeIncident(localId);
            _ref.read(incidentsListProvider.notifier).addIncident(incident);
          },
        );
      }
    } catch (e) {
      print('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
