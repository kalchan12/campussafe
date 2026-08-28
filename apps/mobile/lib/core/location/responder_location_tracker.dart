import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'location_service.dart';
import '../../features/auth/presentation/state/auth_notifier.dart';
import '../../features/profile/data/repositories/responder_repository.dart';
import '../../shared/models/user.dart';

final responderLocationTrackerProvider = Provider<ResponderLocationTracker>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final responderRepo = ref.watch(responderRepositoryProvider);
  return ResponderLocationTracker(ref, locationService, responderRepo);
});

class ResponderLocationTracker {
  final Ref _ref;
  final LocationService _locationService;
  final ResponderRepository _responderRepo;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _throttleTimer;
  Position? _lastSentPosition;

  ResponderLocationTracker(this._ref, this._locationService, this._responderRepo) {
    _init();
  }

  void _init() {
    // Listen to auth state to only track if the user is a logged-in responder
    _ref.listen(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null && next.user!.role.isResponder) {
        startTracking();
      } else {
        stopTracking();
      }
    }, fireImmediately: true);
  }

  void startTracking() {
    if (_positionSubscription != null) return;

    _positionSubscription = _locationService.getPositionStream().listen((Position position) {
      // Throttle updates to avoid spamming the database
      if (_throttleTimer?.isActive ?? false) return;

      // Only update if moved significantly (e.g. > 10 meters)
      if (_lastSentPosition != null) {
        final distance = _locationService.calculateDistance(
          _lastSentPosition!.latitude,
          _lastSentPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance < 10) return;
      }

      _sendLocationUpdate(position);

      _throttleTimer = Timer(const Duration(seconds: 30), () {});
    });
  }

  Future<void> _sendLocationUpdate(Position position) async {
    final userId = _ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    final result = await _responderRepo.updateLocation(
      userId,
      position.latitude,
      position.longitude,
    );

    result.fold(
      (error) => print('Failed to update responder location: ${error.message}'),
      (_) => _lastSentPosition = position,
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _throttleTimer?.cancel();
  }
}
