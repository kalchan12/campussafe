import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env.dart';
import '../../../../shared/models/campus_alert.dart';
import '../../../../shared/models/safety_report.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../data/repositories/safety_report_repository.dart';

enum AlertsTabMode {
  broadcasts,
  myReports,
  safetyGuide,
}

/// Active tab in the Alerts hub
final alertsTabSegmentProvider = StateProvider<AlertsTabMode>((ref) {
  return AlertsTabMode.broadcasts;
});

/// Search query string
final alertsSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Filter by category (null for all)
final selectedAlertCategoryFilterProvider = StateProvider<AlertCategory?>((ref) {
  return null;
});

/// Filter by report status (null for all)
final selectedReportStatusFilterProvider = StateProvider<ReportStatus?>((ref) {
  return null;
});

/// StateNotifier for Campus Broadcast Alerts
final campusAlertsListProvider = StateNotifierProvider<CampusAlertsNotifier, List<CampusAlert>>((ref) {
  return CampusAlertsNotifier();
});

class CampusAlertsNotifier extends StateNotifier<List<CampusAlert>> {
  CampusAlertsNotifier() : super([]) {
    _init();
  }

  void _init() {
    if (Env.isConfigured) {
      _loadFromBackend();
    } else {
      state = [];
    }
  }

  Future<void> _loadFromBackend() async {
    // Alerts backend not fully implemented in DB yet, so we will keep empty or fetch later
    state = [];
  }

  void markAsRead(String alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(isRead: true);
      }
      return alert;
    }).toList();
  }

  void acknowledgeAlert(String alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(isAcknowledged: true, isRead: true);
      }
      return alert;
    }).toList();
  }

  void addAlert(CampusAlert alert) {
    state = [alert, ...state];
  }
}

/// StateNotifier for Safety Reports submitted by users
final userSafetyReportsListProvider = StateNotifierProvider<UserSafetyReportsNotifier, List<SafetyReport>>((ref) {
  final repository = ref.watch(safetyReportRepositoryProvider);
  return UserSafetyReportsNotifier(ref, repository);
});

class UserSafetyReportsNotifier extends StateNotifier<List<SafetyReport>> {
  final Ref ref;
  final SafetyReportRepository _repository;

  UserSafetyReportsNotifier(this.ref, this._repository) : super([]) {
    _init();
  }

  void _init() {
    if (Env.isConfigured) {
      _loadFromBackend();
    } else {
      state = [];
    }
  }

  Future<void> _loadFromBackend() async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.userId;
    if (userId != null) {
      final result = await _repository.getMyReports(userId);
      result.fold(
        (_) { state = []; },
        (reports) {
          if (mounted) {
            state = reports;
          }
        },
      );
    } else {
      state = [];
    }
  }

  Future<SafetyReport> submitReport({
    required bool isAnonymous,
    required ReportType type,
    required String description,
    String? locationDescription,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.userId;

    if (Env.isConfigured) {
      final result = await _repository.submitReport(
        reporterId: isAnonymous ? null : userId,
        isAnonymous: isAnonymous,
        type: type,
        description: description,
        locationDescription: locationDescription,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
      );

      return result.fold(
        (error) {
          // If network failed, throw error instead of faking it
          throw Exception('Failed to submit report: $error');
        },
        (savedReport) {
          state = [savedReport, ...state];
          return savedReport;
        },
      );
    } else {
      throw Exception('App is offline or not configured');
    }
  }

  void addReport(SafetyReport report) {
    state = [report, ...state];
  }
}
