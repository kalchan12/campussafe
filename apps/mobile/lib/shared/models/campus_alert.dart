import 'package:equatable/equatable.dart';

enum AlertSeverity {
  critical('critical'),
  warning('warning'),
  advisory('advisory'),
  info('info'),
  resolved('resolved');

  final String value;
  const AlertSeverity(this.value);

  String get displayName {
    switch (this) {
      case AlertSeverity.critical:
        return 'Critical Alert';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.advisory:
        return 'Advisory';
      case AlertSeverity.info:
        return 'Information';
      case AlertSeverity.resolved:
        return 'All Clear';
    }
  }
}

enum AlertCategory {
  weather('weather'),
  security('security'),
  hazard('hazard'),
  fire('fire'),
  facilities('facilities'),
  health('health'),
  general('general');

  final String value;
  const AlertCategory(this.value);

  String get displayName {
    switch (this) {
      case AlertCategory.weather:
        return 'Weather';
      case AlertCategory.security:
        return 'Security';
      case AlertCategory.hazard:
        return 'Hazard';
      case AlertCategory.fire:
        return 'Fire Safety';
      case AlertCategory.facilities:
        return 'Facilities';
      case AlertCategory.health:
        return 'Health';
      case AlertCategory.general:
        return 'General';
    }
  }
}

class CampusAlert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertCategory category;
  final List<String> affectedLocations;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final bool actionRequired;
  final String? actionGuidance;
  final String author;
  final bool isRead;
  final bool isAcknowledged;

  const CampusAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.category,
    required this.affectedLocations,
    required this.issuedAt,
    this.expiresAt,
    this.actionRequired = false,
    this.actionGuidance,
    this.author = 'Campus Safety Operations',
    this.isRead = false,
    this.isAcknowledged = false,
  });

  CampusAlert copyWith({
    String? id,
    String? title,
    String? message,
    AlertSeverity? severity,
    AlertCategory? category,
    List<String>? affectedLocations,
    DateTime? issuedAt,
    DateTime? expiresAt,
    bool? actionRequired,
    String? actionGuidance,
    String? author,
    bool? isRead,
    bool? isAcknowledged,
  }) {
    return CampusAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      affectedLocations: affectedLocations ?? this.affectedLocations,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      actionRequired: actionRequired ?? this.actionRequired,
      actionGuidance: actionGuidance ?? this.actionGuidance,
      author: author ?? this.author,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        severity,
        category,
        affectedLocations,
        issuedAt,
        expiresAt,
        actionRequired,
        actionGuidance,
        author,
        isRead,
        isAcknowledged,
      ];
}
