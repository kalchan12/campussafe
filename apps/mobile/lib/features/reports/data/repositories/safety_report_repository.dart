import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/env.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../shared/models/safety_report.dart';

final safetyReportRepositoryProvider = Provider<SafetyReportRepository>((ref) {
  return SafetyReportRepository(Env.isConfigured ? Env.supabase : null);
});

class SafetyReportRepository {
  final SupabaseClient? _client;
  static const _uuid = Uuid();

  SafetyReportRepository(this._client);

  bool get _isAvailable => _client != null;

  /// Submits a safety report. Anonymous reports omit the reporter_id.
  Future<Result<SafetyReport>> submitReport({
    String? reporterId,
    required bool isAnonymous,
    required ReportType type,
    required String description,
    double? latitude,
    double? longitude,
    String? locationDescription,
    String? imageUrl,
  }) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client!.from('safety_reports').insert({
        'id': _uuid.v4(),
        if (!isAnonymous && reporterId != null) 'reporter_id': reporterId,
        'is_anonymous': isAnonymous,
        'type': type.value,
        'status': ReportStatus.submitted.value,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'location_description': locationDescription,
        'image_url': imageUrl,
        'created_at': now,
        'updated_at': now,
      }).select().single();
      return Right(SafetyReport.fromJson(data));
    } catch (e) {
      return Left(NetworkError(message: 'Failed to submit report: $e'));
    }
  }

  /// Fetches reports submitted by a specific user.
  Future<Result<List<SafetyReport>>> getMyReports(String userId) async {
    if (!_isAvailable) return Left(NetworkError.noConnection());
    try {
      final data = await _client!
          .from('safety_reports')
          .select()
          .eq('reporter_id', userId)
          .order('created_at', ascending: false);
      final reports = (data as List)
          .map((e) => SafetyReport.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(reports);
    } catch (e) {
      return Left(NetworkError(message: 'Failed to load reports: $e'));
    }
  }
}
