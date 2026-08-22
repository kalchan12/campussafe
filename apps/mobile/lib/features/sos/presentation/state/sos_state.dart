import 'package:equatable/equatable.dart';

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
  final String? error;
  final bool isLocationLoading;

  const SosState({
    this.status = SosStatus.ready,
    this.emergencyType,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.error,
    this.isLocationLoading = false,
  });

  SosState copyWith({
    SosStatus? status,
    String? emergencyType,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? error,
    bool? isLocationLoading,
  }) {
    return SosState(
      status: status ?? this.status,
      emergencyType: emergencyType ?? this.emergencyType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      error: error,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        emergencyType,
        latitude,
        longitude,
        locationAddress,
        error,
        isLocationLoading,
      ];
}
