import 'package:equatable/equatable.dart';

class SafetyReport extends Equatable {
  final String id;
  final String? reporterId;
  final bool isAnonymous;
  final ReportType type;
  final ReportStatus status;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? locationDescription;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SafetyReport({
    required this.id,
    this.reporterId,
    required this.isAnonymous,
    required this.type,
    required this.status,
    required this.description,
    this.latitude,
    this.longitude,
    this.locationDescription,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafetyReport.fromJson(Map<String, dynamic> json) {
    return SafetyReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String?,
      isAnonymous: json['is_anonymous'] as bool,
      type: ReportType.fromString(json['type'] as String),
      status: ReportStatus.fromString(json['status'] as String),
      description: json['description'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationDescription: json['location_description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'is_anonymous': isAnonymous,
      'type': type.value,
      'status': status.value,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location_description': locationDescription,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        isAnonymous,
        type,
        status,
        description,
        latitude,
        longitude,
        locationDescription,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}

enum ReportType {
  suspiciousActivity('suspicious_activity'),
  securityConcern('security_concern'),
  fireHazard('fire_hazard'),
  safetyConcern('safety_concern'),
  other('other');

  const ReportType(this.value);
  final String value;

  factory ReportType.fromString(String value) {
    return ReportType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReportType.other,
    );
  }

  String get displayName {
    switch (this) {
      case ReportType.suspiciousActivity:
        return 'Suspicious Activity';
      case ReportType.securityConcern:
        return 'Security Concern';
      case ReportType.fireHazard:
        return 'Fire/Hazard';
      case ReportType.safetyConcern:
        return 'Safety Concern';
      case ReportType.other:
        return 'Other';
    }
  }
}

enum ReportStatus {
  submitted('submitted'),
  underReview('under_review'),
  resolved('resolved'),
  dismissed('dismissed');

  const ReportStatus(this.value);
  final String value;

  factory ReportStatus.fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.submitted,
    );
  }

  String get displayName {
    switch (this) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }
}
