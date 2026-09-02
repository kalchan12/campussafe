import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/env.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/maps/campus_map_data.dart';
import '../../../../core/maps/routing_service.dart';
import '../../../../shared/models/incident.dart';
import '../../data/repositories/incident_repository.dart';

enum IncidentsViewMode {
  list,
  map,
}

enum TravelMode {
  walking,
  bicycling,
  driving,
}

/// Provider for the active view mode (List vs Live GPS Map)
final incidentsViewModeProvider = StateProvider<IncidentsViewMode>((ref) {
  return IncidentsViewMode.list;
});

/// Provider for incident filter (null for All)
final selectedEmergencyTypeFilterProvider = StateProvider<EmergencyType?>((ref) {
  return null;
});

/// Provider for currently selected/highlighted incident on the map
final selectedMapIncidentProvider = StateProvider<Incident?>((ref) {
  return null;
});

/// Provider for currently active map tile layer style
final selectedMapStyleProvider = StateProvider<MapStyleOption>((ref) {
  return MapStyleOption.streets;
});

/// Provider for selected multi-modal travel transit mode
final activeTravelModeProvider = StateProvider<TravelMode>((ref) {
  return TravelMode.walking;
});

/// Stream provider for the user's live GPS position
final userLivePositionProvider = StreamProvider<Position?>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getPositionStream().map((pos) => pos).handleError((e) {
    return null;
  });
});

/// Provider for current one-time user location
final currentUserLocationProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final result = await locationService.getCurrentLocation();
  return result.fold(
    (error) => null,
    (position) => position,
  );
});

/// Stream provider for watching a responder's location in realtime.
final responderLocationProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, responderId) {
  final repository = ref.watch(incidentRepositoryProvider);
  return repository.watchResponder(responderId);
});

/// Provider for multi-modal route path between current user/operator position and selected incident
final activeIncidentRouteProvider = FutureProvider<RouteResult?>((ref) async {
  final selectedIncident = ref.watch(selectedMapIncidentProvider);
  if (selectedIncident == null ||
      selectedIncident.latitude == null ||
      selectedIncident.longitude == null) {
    return null;
  }

  final userPosAsync = ref.watch(userLivePositionProvider);
  final livePos = userPosAsync.value;

  // If user GPS is available and inside or near campus, use live GPS; otherwise default to Campus EOC
  final startLatLng = livePos != null
      ? LatLng(livePos.latitude, livePos.longitude)
      : kAdamaCampusCenter;

  final endLatLng = LatLng(
    selectedIncident.latitude!,
    selectedIncident.longitude!,
  );

  final routingService = ref.watch(routingServiceProvider);
  return await routingService.getBestRoute(startLatLng, endLatLng);
});

/// Provider indicating if incidents are actively being fetched/loaded from the backend
final incidentsLoadingProvider = StateProvider<bool>((ref) => true);

/// Provider for active incidents list with real coordinates
final incidentsListProvider = StateNotifierProvider<IncidentsNotifier, List<Incident>>((ref) {
  final repository = ref.watch(incidentRepositoryProvider);
  return IncidentsNotifier(ref, repository);
});

class IncidentsNotifier extends StateNotifier<List<Incident>> {
  final Ref ref;
  final IncidentRepository _repository;
  StreamSubscription<List<Incident>>? _streamSubscription;

  IncidentsNotifier(this.ref, this._repository) : super([]) {
    _init();
  }

  void _init() {
    if (Env.isConfigured) {
      _loadFromBackend();
      _subscribeToRealtime();
    } else {
      state = [];
      Future.microtask(() {
        ref.read(incidentsLoadingProvider.notifier).state = false;
      });
    }
  }

  Future<void> _loadFromBackend() async {
    Future.microtask(() {
      ref.read(incidentsLoadingProvider.notifier).state = true;
    });
    final result = await _repository.getActiveIncidents();
    result.fold(
      (error) {
        if (mounted) {
          state = [];
          ref.read(incidentsLoadingProvider.notifier).state = false;
        }
      },
      (incidents) {
        if (mounted) {
          state = incidents;
          ref.read(incidentsLoadingProvider.notifier).state = false;
        }
      },
    );
  }

  void _subscribeToRealtime() {
    try {
      _streamSubscription?.cancel();
      _streamSubscription = _repository.watchActiveIncidents().listen(
        (updatedIncidents) {
          if (mounted) {
            state = updatedIncidents;
          }
        },
        onError: (e) {
          // Retain state on stream error
        },
      );
    } catch (_) {
      // Realtime subscription optional if offline
    }
  }

  Future<void> refresh() async {
    if (Env.isConfigured) {
      await _loadFromBackend();
    }
  }

  Future<void> updateIncidentStatus({
    required String incidentId,
    required IncidentStatus status,
    String? responderId,
  }) async {
    if (Env.isConfigured) {
      await _repository.updateStatus(
        incidentId: incidentId,
        status: status,
        responderId: responderId,
      );
    }

    state = state.map((inc) {
      if (inc.id == incidentId) {
        return inc.copyWith(
          status: status,
          assignedResponderId: responderId ?? inc.assignedResponderId,
          updatedAt: DateTime.now(),
        );
      }
      return inc;
    }).toList();
  }

  void addIncident(Incident incident) {
    state = [incident, ...state];
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

extension IncidentCopy on Incident {
  Incident copyWith({
    String? id,
    EmergencyType? type,
    IncidentStatus? status,
    int? priority,
    String? reporterId,
    String? assignedResponderId,
    double? latitude,
    double? longitude,
    String? locationDescription,
    String? campusBlock,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? assignedAt,
    DateTime? respondedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
  }) {
    return Incident(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reporterId: reporterId ?? this.reporterId,
      assignedResponderId: assignedResponderId ?? this.assignedResponderId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationDescription: locationDescription ?? this.locationDescription,
      campusBlock: campusBlock ?? this.campusBlock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

String formatDistanceBetween(LatLng userLoc, LatLng destination) {
  const distance = Distance();
  final meters = distance.as(LengthUnit.Meter, userLoc, destination);
  if (meters < 1000) {
    final walkMins = (meters / 80).ceil();
    return '${meters.toInt()} m away • ~$walkMins min walk';
  } else {
    final km = (meters / 1000).toStringAsFixed(1);
    final driveMins = (meters / 500).ceil();
    return '$km km away • ~$driveMins min drive';
  }
}
