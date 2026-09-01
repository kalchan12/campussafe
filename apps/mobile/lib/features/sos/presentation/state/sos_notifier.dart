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
    state = state.copyWith(isLocationLoading: true);
    final result = await _locationService.getCurrentLocation();
    result.fold(
      (error) {
        state = state.copyWith(
          isLocationLoading: false,
          locationAddress: 'Location unavailable (${error.message})',
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

    final payload = {
      'reporterId': userId,
      'type': emergencyType.value,
      'priority': priority,
      'latitude': state.latitude,
      'longitude': state.longitude,
      'locationDescription': state.locationAddress,
      'campusBlock': campusBlock ?? state.campusBlock,
      'description': description ?? 'Emergency SOS Alert triggered via Mobile App',
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
        latitude: state.latitude ?? 8.5565,
        longitude: state.longitude ?? 39.2910,
        locationDescription: state.locationAddress ?? 'Campus Central Zone',
        campusBlock: campusBlock ?? 'Administration Block & EOC',
        description: description ?? 'Emergency SOS Alert triggered via Mobile App',
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
