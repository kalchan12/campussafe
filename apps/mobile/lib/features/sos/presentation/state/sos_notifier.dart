import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env.dart';
import '../../../../core/local/incident_queue_db.dart';
import '../../../../core/network/sync_service.dart';
import '../../../../core/location/location_service.dart';
import '../../../../shared/models/incident.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../incidents/data/repositories/incident_repository.dart';
import '../../../incidents/presentation/state/incidents_provider.dart';
import 'sos_state.dart';

final sosNotifierProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final incidentRepository = ref.watch(incidentRepositoryProvider);
  final queueDb = ref.watch(incidentQueueDbProvider);
  // Watch sync service to ensure it initializes and listens
  ref.watch(syncServiceProvider);
  
  return SosNotifier(ref, locationService, incidentRepository, queueDb);
});

class SosNotifier extends StateNotifier<SosState> {
  final Ref _ref;
  final LocationService _locationService;
  final IncidentRepository _incidentRepository;
  final IncidentQueueDb _queueDb;

  SosNotifier(this._ref, this._locationService, this._incidentRepository, this._queueDb)
      : super(const SosState());

  void startConfirmation() {
    state = state.copyWith(status: SosStatus.confirming, error: null);
  }

  void startTypeSelection() {
    state = state.copyWith(status: SosStatus.selectingType, error: null);
  }

  void selectType(String type) {
    state = state.copyWith(
      status: SosStatus.confirmingLocation,
      emergencyType: type.toLowerCase(),
      error: null,
    );
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    state = state.copyWith(isLocationLoading: true, error: null);
    final result = await _locationService.getCurrentLocation();
    result.fold(
      (error) {
        state = state.copyWith(
          isLocationLoading: false,
          latitude: null,
          longitude: null,
          locationAddress: 'GPS unavailable (${error.message}) - Campus fallback active',
        );
      },
      (position) {
        state = state.copyWith(
          isLocationLoading: false,
          latitude: position.latitude,
          longitude: position.longitude,
          locationAddress:
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
        );
      },
    );
  }

  Future<void> sendSOS({String? campusBlock, String? description}) async {
    state = state.copyWith(status: SosStatus.sending, error: null);

    final emergencyType = EmergencyType.fromString(state.emergencyType ?? 'other');
    final authState = _ref.read(authNotifierProvider);
    final userId = authState.userId;
    final isGuest = authState.isGuest || !authState.isAuthenticated;

    // Determine priority based on type
    int priority = 1; // High priority for SOS
    if (emergencyType == EmergencyType.other) {
      priority = 2;
    }

    final hasExactGps = state.latitude != null && state.longitude != null;
    final effectiveLat = state.latitude ?? 8.5582;
    final effectiveLng = state.longitude ?? 39.2895;
    final effectiveDesc = description ?? (hasExactGps
        ? 'Emergency SOS Alert triggered via Mobile App'
        : 'Emergency SOS Alert triggered via Mobile App (Exact GPS unavailable - dispatched to ASTU campus central zone)');
    final effectiveLocationDesc = state.locationAddress ??
        (hasExactGps
            ? 'Lat: ${effectiveLat.toStringAsFixed(4)}, Lng: ${effectiveLng.toStringAsFixed(4)}'
            : 'ASTU Campus Central (GPS unavailable)');

    final payload = {
      'reporterId': userId,
      'type': emergencyType.value,
      'priority': priority,
      'latitude': effectiveLat,
      'longitude': effectiveLng,
      'locationDescription': effectiveLocationDesc,
      'campusBlock': campusBlock ?? state.campusBlock ?? 'ASTU Campus Grounds',
      'description': effectiveDesc,
      'source': isGuest ? 'guest_report' : 'mobile',
    };

    if (Env.isConfigured) {
      final result = await _incidentRepository.createIncident(
        reporterId: payload['reporterId'] as String?,
        type: emergencyType,
        priority: payload['priority'] as int,
        latitude: payload['latitude'] as double?,
        longitude: payload['longitude'] as double?,
        locationDescription: payload['locationDescription'] as String?,
        campusBlock: payload['campusBlock'] as String?,
        description: payload['description'] as String?,
        source: payload['source'] as String,
      );

      result.fold(
        (error) async {
          // If network failed, enqueue it!
          await _queueDb.enqueueIncident(payload);
          state = state.copyWith(
            status: SosStatus.sent, // Pretend success for the user so they don't panic
            error: 'You are offline. SOS queued and will be sent when connection is restored.',
          );
        },
        (incident) {
          _ref.read(incidentsListProvider.notifier).addIncident(incident);
          state = state.copyWith(
            status: SosStatus.sent,
            createdIncident: incident,
          );
        },
      );
    } else {
      // Dev mode fallback
      await Future.delayed(const Duration(seconds: 1));
      final fakeIncident = Incident(
        id: 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        type: emergencyType,
        status: IncidentStatus.created,
        priority: priority,
        reporterId: userId ?? 'guest_user',
        latitude: effectiveLat,
        longitude: effectiveLng,
        locationDescription: effectiveLocationDesc,
        campusBlock: campusBlock ?? 'Administration Block & EOC',
        description: effectiveDesc,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _ref.read(incidentsListProvider.notifier).addIncident(fakeIncident);
      state = state.copyWith(
        status: SosStatus.sent,
        createdIncident: fakeIncident,
      );
    }
  }

  void reset() {
    state = const SosState();
  }
}
