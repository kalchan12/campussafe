import 'package:equatable/equatable.dart';

class Responder extends Equatable {
  final String id;
  final String userId;
  final ResponderType type;
  final ResponderAvailability availability;
  final String? currentIncidentId;
  final double? latitude;
  final double? longitude;
  final DateTime lastLocationUpdate;
  final DateTime createdAt;

  const Responder({
    required this.id,
    required this.userId,
    required this.type,
    required this.availability,
    this.currentIncidentId,
    this.latitude,
    this.longitude,
    required this.lastLocationUpdate,
    required this.createdAt,
  });

  factory Responder.fromJson(Map<String, dynamic> json) {
    return Responder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: ResponderType.fromString(json['type'] as String),
      availability: ResponderAvailability.fromString(
        json['availability'] as String,
      ),
      currentIncidentId: json['current_incident_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      lastLocationUpdate: DateTime.parse(json['last_location_update'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'availability': availability.value,
      'current_incident_id': currentIncidentId,
      'latitude': latitude,
      'longitude': longitude,
      'last_location_update': lastLocationUpdate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAvailable =>
      availability == ResponderAvailability.available &&
      currentIncidentId == null;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        availability,
        currentIncidentId,
        latitude,
        longitude,
        lastLocationUpdate,
        createdAt,
      ];
}

enum ResponderType {
  medical('medical'),
  security('security');

  const ResponderType(this.value);
  final String value;

  factory ResponderType.fromString(String value) {
    return ResponderType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ResponderType.security,
    );
  }
}

enum ResponderAvailability {
  available('available'),
  busy('busy'),
  offline('offline');

  const ResponderAvailability(this.value);
  final String value;

  factory ResponderAvailability.fromString(String value) {
    return ResponderAvailability.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ResponderAvailability.offline,
    );
  }
}
