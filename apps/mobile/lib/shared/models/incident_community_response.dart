import 'package:equatable/equatable.dart';

enum CommunityResponseType {
  offeringAssistance('offering_assistance'),
  escortingToSafety('escorting_to_safety'),
  firstAidProvided('first_aid_provided'),
  eyewitnessReport('eyewitness_report'),
  otherAssistance('other_assistance');

  final String value;
  const CommunityResponseType(this.value);

  factory CommunityResponseType.fromString(String val) {
    return CommunityResponseType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => CommunityResponseType.otherAssistance,
    );
  }

  String get displayName {
    switch (this) {
      case CommunityResponseType.offeringAssistance:
        return 'Assistance Offered';
      case CommunityResponseType.escortingToSafety:
        return 'Escorting to Safety';
      case CommunityResponseType.firstAidProvided:
        return 'First Aid Applied';
      case CommunityResponseType.eyewitnessReport:
        return 'Eyewitness Report';
      case CommunityResponseType.otherAssistance:
        return 'Community Note';
    }
  }
}

class IncidentCommunityResponse extends Equatable {
  final String id;
  final String incidentId;
  final String? responderId;
  final String responderName;
  final CommunityResponseType responseType;
  final String message;
  final DateTime createdAt;

  const IncidentCommunityResponse({
    required this.id,
    required this.incidentId,
    this.responderId,
    required this.responderName,
    required this.responseType,
    required this.message,
    required this.createdAt,
  });

  factory IncidentCommunityResponse.fromJson(Map<String, dynamic> json) {
    return IncidentCommunityResponse(
      id: json['id'] as String,
      incidentId: json['incident_id'] as String,
      responderId: json['responder_id'] as String?,
      responderName: json['responder_name'] as String? ?? 'Community Member',
      responseType: CommunityResponseType.fromString(
          json['response_type'] as String? ?? 'other_assistance'),
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incident_id': incidentId,
      'responder_id': responderId,
      'responder_name': responderName,
      'response_type': responseType.value,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        incidentId,
        responderId,
        responderName,
        responseType,
        message,
        createdAt,
      ];
}
