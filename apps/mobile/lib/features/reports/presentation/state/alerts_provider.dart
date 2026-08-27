import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/campus_alert.dart';
import '../../../../shared/models/safety_report.dart';

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
    _loadInitialAlerts();
  }

  void _loadInitialAlerts() {
    final now = DateTime.now();

    state = [
      CampusAlert(
        id: 'ALT-1088',
        title: 'Severe Weather Advisory: High Wind & Rain Warning',
        message: 'A severe weather front with winds up to 45mph is approaching campus. Avoid walking near heavy tree lines and construction zones.',
        severity: AlertSeverity.warning,
        category: AlertCategory.weather,
        affectedLocations: const ['North Campus', 'Outdoor Sports Fields', 'Central Walkway'],
        issuedAt: now.subtract(const Duration(minutes: 18)),
        expiresAt: now.add(const Duration(hours: 3)),
        actionRequired: true,
        actionGuidance: 'Remain inside designated campus buildings. Report fallen branches to facilities.',
        author: 'Campus Emergency Management',
      ),
      CampusAlert(
        id: 'ALT-1085',
        title: 'Security Notice: North Quad Perimeter Check',
        message: 'Campus Security is conducting scheduled patrols and lighting inspections across the North Quad perimeter. All facilities remain accessible.',
        severity: AlertSeverity.info,
        category: AlertCategory.security,
        affectedLocations: const ['North Quad', 'Residence Halls A & B'],
        issuedAt: now.subtract(const Duration(hours: 1, minutes: 40)),
        actionRequired: false,
        author: 'Campus Safety & Patrol',
      ),
      CampusAlert(
        id: 'ALT-1079',
        title: 'Emergency Maintenance: West Gate Water Main Repair',
        message: 'Scheduled valve replacement at West Gate walkway. Temporary pedestrian detour is active through South Annex corridor.',
        severity: AlertSeverity.advisory,
        category: AlertCategory.facilities,
        affectedLocations: const ['West Gate entrance', 'Annex Corridor'],
        issuedAt: now.subtract(const Duration(hours: 4)),
        expiresAt: now.add(const Duration(hours: 6)),
        actionRequired: true,
        actionGuidance: 'Please use South entrance for wheelchair and bicycle access.',
        author: 'Campus Infrastructure Dept',
      ),
      CampusAlert(
        id: 'ALT-1072',
        title: 'All Clear: Science Block Chemistry Lab Vent Check Completed',
        message: 'The ventilation sensor inspection at Chemistry Lab B has concluded safely. Normal laboratory sessions have resumed.',
        severity: AlertSeverity.resolved,
        category: AlertCategory.hazard,
        affectedLocations: const ['Science Complex - Chem Lab B'],
        issuedAt: now.subtract(const Duration(hours: 8)),
        actionRequired: false,
        author: 'Environmental Health & Safety',
      ),
    ];
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
  return UserSafetyReportsNotifier();
});

class UserSafetyReportsNotifier extends StateNotifier<List<SafetyReport>> {
  UserSafetyReportsNotifier() : super([]) {
    _loadInitialReports();
  }

  void _loadInitialReports() {
    final now = DateTime.now();

    state = [
      SafetyReport(
        id: 'REP-2041',
        reporterId: 'usr_me',
        isAnonymous: true,
        type: ReportType.suspiciousActivity,
        status: ReportStatus.underReview,
        description: 'Unattended suspicious backpack left near Engineering Library east entrance.',
        locationDescription: 'Engineering Library, 1st Floor East Vestibule',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        updatedAt: now.subtract(const Duration(minutes: 40)),
      ),
      SafetyReport(
        id: 'REP-1988',
        reporterId: 'usr_me',
        isAnonymous: false,
        type: ReportType.safetyConcern,
        status: ReportStatus.resolved,
        description: 'Broken handrail on exterior staircase leading down to cafeteria.',
        locationDescription: 'Student Union Cafeteria Stairwell B',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      SafetyReport(
        id: 'REP-1950',
        reporterId: 'usr_me',
        isAnonymous: false,
        type: ReportType.fireHazard,
        status: ReportStatus.submitted,
        description: 'Emergency exit push-bar latch sticking in Fine Arts Hallway.',
        locationDescription: 'Fine Arts Building, 2nd Floor Corridor',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  void addReport(SafetyReport report) {
    state = [report, ...state];
  }
}
