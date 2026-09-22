import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final shakeDetectorServiceProvider = Provider<ShakeDetectorService>((ref) {
  final service = ShakeDetectorService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Hands-free emergency trigger service using inertial device sensors (accelerometer).
///
/// Designed to detect sudden critical accidents (assault, physical grab, sudden collapse)
/// where the user is unable to physically look at the screen and hold the SOS button for 3 seconds.
class ShakeDetectorService {
  static const String prefKeyShakeEnabled = 'pref_shake_to_sos_enabled';

  /// Shake detection threshold in m/s² (1G ≈ 9.8 m/s²; 25.0 m/s² ≈ 2.55G)
  final double shakeThreshold;

  /// Required number of direction reversals / acceleration spikes within the window
  final int requiredShakeCount;

  /// Time window to accumulate the required number of spikes (in milliseconds)
  final int shakeWindowMs;

  /// Cooldown period after a trigger before another shake can be detected (in milliseconds)
  final int triggerCooldownMs;

  StreamSubscription<AccelerometerEvent>? _subscription;
  VoidCallback? _onShakeDetected;
  bool _isEnabled = false; // Opt-in default for motion sensor privacy
  int _shakeCount = 0;
  int _lastShakeTimestamp = 0;
  int _lastTriggerTimestamp = 0;

  ShakeDetectorService({
    this.shakeThreshold = 24.0,
    this.requiredShakeCount = 3,
    this.shakeWindowMs = 1200,
    this.triggerCooldownMs = 8000,
  });

  bool get isEnabled => _isEnabled;

  /// Initializes the service and loads the user preference.
  Future<void> initialize({required VoidCallback onShakeDetected}) async {
    _onShakeDetected = onShakeDetected;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(prefKeyShakeEnabled) ?? false;
    } catch (_) {
      _isEnabled = false;
    }

    if (_isEnabled) {
      startListening();
    }
  }

  /// Sets whether hands-free shake detection is active and persists the preference.
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyShakeEnabled, enabled);
    } catch (_) {}

    if (enabled) {
      startListening();
    } else {
      stopListening();
    }
  }

  /// Starts listening to device accelerometer events.
  void startListening() {
    _subscription?.cancel();
    try {
      _subscription = accelerometerEventStream().listen(
        _handleAccelerometerEvent,
        onError: (err) {
          debugPrint('ShakeDetector accelerometer error: $err');
        },
      );
    } catch (e) {
      debugPrint('ShakeDetector failed to subscribe to accelerometer: $e');
    }
  }

  /// Stops listening to accelerometer events.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _shakeCount = 0;
  }

  /// Processes accelerometer events with multi-spike confirmation logic.
  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (!_isEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Guard against re-triggering during cooldown period
    if (now - _lastTriggerTimestamp < triggerCooldownMs) {
      return;
    }

    // Calculate total net acceleration magnitude: sqrt(x² + y² + z²)
    final gForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    if (gForce > shakeThreshold) {
      if (now - _lastShakeTimestamp < shakeWindowMs) {
        _shakeCount++;
      } else {
        _shakeCount = 1;
      }
      _lastShakeTimestamp = now;

      if (_shakeCount >= requiredShakeCount) {
        _shakeCount = 0;
        _lastTriggerTimestamp = now;
        debugPrint('🚨 [ShakeDetectorService] Hands-free emergency shake pattern detected!');
        _onShakeDetected?.call();
      }
    }
  }

  void dispose() {
    stopListening();
  }
}
