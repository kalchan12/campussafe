import 'package:equatable/equatable.dart';

class Incident extends Equatable {
  final String id;
  final EmergencyType type;
  final IncidentStatus status;
  final int priority;
  final String? reporterId;
  final String? assignedResponderId;
  final double? latitude;
  final double? longitude;
  final String? locationDescription;
  final String? campusBlock;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? assignedAt;
  final DateTime? respondedAt;
  final DateTime? arrivedAt;
  final DateTime? resolvedAt;

  const Incident({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    this.reporterId,
    this.assignedResponderId,
    this.latitude,
    this.longitude,
    this.locationDescription,
    this.campusBlock,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.assignedAt,
    this.respondedAt,
    this.arrivedAt,
    this.resolvedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      type: EmergencyType.fromString(json['type'] as String),
      status: IncidentStatus.fromString(json['status'] as String),
      priority: json['priority'] as int,
      reporterId: json['reporter_id'] as String?,
      assignedResponderId: json['assigned_responder_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationDescription: json['location_description'] as String?,
      campusBlock: json['campus_block'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'status': status.value,
      'priority': priority,
      'reporter_id': reporterId,
      'assigned_responder_id': assignedResponderId,
      'latitude': latitude,
      'longitude': longitude,
      'location_description': locationDescription,
      'campus_block': campusBlock,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assigned_at': assignedAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'arrived_at': arrivedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  bool get isActive => status != IncidentStatus.resolved &&
      status != IncidentStatus.cancelled;

  bool get isAssigned => assignedResponderId != null;

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        priority,
        reporterId,
        assignedResponderId,
        latitude,
        longitude,
        locationDescription,
        campusBlock,
        description,
        createdAt,
        updatedAt,
        assignedAt,
        respondedAt,
        arrivedAt,
        resolvedAt,
      ];
}

enum EmergencyType {
  medical('medical'),
  security('security'),
  fire('fire'),
  accident('accident'),
  other('other');

  const EmergencyType(this.value);
  final String value;

  factory EmergencyType.fromString(String value) {
    return EmergencyType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EmergencyType.other,
    );
  }

  String get displayName {
    switch (this) {
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.security:
        return 'Security';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.other:
        return 'Other';
    }
  }
}

enum IncidentStatus {
  created('created'),
  received('received'),
  assigned('assigned'),
  responding('responding'),
  arrived('arrived'),
  resolved('resolved'),
  cancelled('cancelled'),
  failed('failed');

  const IncidentStatus(this.value);
  final String value;

  factory IncidentStatus.fromString(String value) {
    return IncidentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => IncidentStatus.created,
    );
  }

  String get displayName {
    switch (this) {
      case IncidentStatus.created:
        return 'Created';
      case IncidentStatus.received:
        return 'Received';
      case IncidentStatus.assigned:
        return 'Assigned';
      case IncidentStatus.responding:
        return 'Responding';
      case IncidentStatus.arrived:
        return 'Arrived';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.cancelled:
        return 'Cancelled';
      case IncidentStatus.failed:
        return 'Failed';
    }
  }
}
