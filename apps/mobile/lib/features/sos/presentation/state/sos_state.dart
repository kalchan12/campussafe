import 'package:equatable/equatable.dart';

import '../../../../shared/models/incident.dart';

enum SosStatus {
  ready,
  confirming,
  selectingType,
  confirmingLocation,
  sending,
  sent,
  received,
  failed,
}

class SosState extends Equatable {
  final SosStatus status;
  final String? emergencyType;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? campusBlock;
  final String? error;
  final bool isLocationLoading;
  final Incident? createdIncident;

  const SosState({
    this.status = SosStatus.ready,
    this.emergencyType,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.campusBlock,
    this.error,
    this.isLocationLoading = false,
    this.createdIncident,
  });

  SosState copyWith({
    SosStatus? status,
    String? emergencyType,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? campusBlock,
    String? error,
    bool? isLocationLoading,
    Incident? createdIncident,
  }) {
    return SosState(
      status: status ?? this.status,
      emergencyType: emergencyType ?? this.emergencyType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      campusBlock: campusBlock ?? this.campusBlock,
      error: error,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      createdIncident: createdIncident ?? this.createdIncident,
    );
  }

  @override
  List<Object?> get props => [
        status,
        emergencyType,
        latitude,
        longitude,
        locationAddress,
        campusBlock,
        error,
        isLocationLoading,
        createdIncident,
      ];
}

