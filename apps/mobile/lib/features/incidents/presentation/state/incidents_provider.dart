import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/location_service.dart';
import '../../../../shared/models/incident.dart';

enum IncidentsViewMode {
  list,
  map,
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

/// Provider for active incidents list with real/mock coordinates
final incidentsListProvider = StateNotifierProvider<IncidentsNotifier, List<Incident>>((ref) {
  return IncidentsNotifier(ref);
});

class IncidentsNotifier extends StateNotifier<List<Incident>> {
  final Ref ref;

  IncidentsNotifier(this.ref) : super([]) {
    _loadInitialIncidents();
  }

  void _loadInitialIncidents() {
    final now = DateTime.now();

    state = [
      Incident(
        id: 'CS-1042',
        type: EmergencyType.medical,
        status: IncidentStatus.responding,
        priority: 1,
        reporterId: 'usr_sarah',
        latitude: 37.4282,
        longitude: -122.1688,
        campusBlock: 'Engineering Quad - Building 2',
        locationDescription: '2nd Floor, Room 204 near east stairwell',
        description: 'Student experiencing severe dizziness and shortness of breath. First aid kit requested.',
        createdAt: now.subtract(const Duration(minutes: 8)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
        assignedAt: now.subtract(const Duration(minutes: 6)),
        respondedAt: now.subtract(const Duration(minutes: 4)),
      ),
      Incident(
        id: 'CS-1039',
        type: EmergencyType.security,
        status: IncidentStatus.assigned,
        priority: 2,
        reporterId: 'usr_david',
        latitude: 37.4265,
        longitude: -122.1712,
        campusBlock: 'Main University Library',
        locationDescription: 'South Gate Entrance near bicycle racks',
        description: 'Suspicious unattended package reported by staff.',
        createdAt: now.subtract(const Duration(minutes: 25)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
        assignedAt: now.subtract(const Duration(minutes: 15)),
      ),
      Incident(
        id: 'CS-1035',
        type: EmergencyType.fire,
        status: IncidentStatus.arrived,
        priority: 1,
        reporterId: 'usr_alex',
        latitude: 37.4295,
        longitude: -122.1730,
        campusBlock: 'Chemistry Lab B',
        locationDescription: 'Ground Floor, Ventilation Exhaust Zone',
        description: 'Chemical smoke detector activated. Area evacuated safely.',
        createdAt: now.subtract(const Duration(minutes: 45)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
        assignedAt: now.subtract(const Duration(minutes: 40)),
        respondedAt: now.subtract(const Duration(minutes: 35)),
        arrivedAt: now.subtract(const Duration(minutes: 12)),
      ),
      Incident(
        id: 'CS-1028',
        type: EmergencyType.accident,
        status: IncidentStatus.received,
        priority: 3,
        reporterId: 'usr_emma',
        latitude: 37.4250,
        longitude: -122.1670,
        campusBlock: 'Student Union Hub',
        locationDescription: 'Outdoor cafeteria seating area',
        description: 'Minor bicycle collision near walkway. Needs assessment.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];

    _adaptCoordinatesToUserLocation();
  }

  Future<void> _adaptCoordinatesToUserLocation() async {
    try {
      final userPos = await ref.read(currentUserLocationProvider.future);
      if (userPos != null && mounted) {
        final baseLat = userPos.latitude;
        final baseLng = userPos.longitude;

        state = [
          state[0].copyWith(
            latitude: baseLat + 0.0018,
            longitude: baseLng + 0.0012,
          ),
          state[1].copyWith(
            latitude: baseLat - 0.0015,
            longitude: baseLng - 0.0020,
          ),
          state[2].copyWith(
            latitude: baseLat + 0.0028,
            longitude: baseLng - 0.0016,
          ),
          state[3].copyWith(
            latitude: baseLat - 0.0022,
            longitude: baseLng + 0.0025,
          ),
        ];
      }
    } catch (_) {
      // Keep base coordinates
    }
  }

  void addIncident(Incident incident) {
    state = [incident, ...state];
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
