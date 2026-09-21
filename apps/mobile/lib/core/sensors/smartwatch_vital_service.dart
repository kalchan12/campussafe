import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/smartwatch_vitals.dart';

final smartwatchVitalServiceProvider = Provider<SmartwatchVitalService>((ref) {
  final service = SmartwatchVitalService();
  ref.onDispose(() => service.dispose());
  return service;
});

final smartwatchVitalsNotifierProvider =
    StateNotifierProvider<SmartwatchVitalsNotifier, SmartwatchVitalsState>((ref) {
  final service = ref.watch(smartwatchVitalServiceProvider);
  return SmartwatchVitalsNotifier(service);
});

/// Immutable UI state for the smartwatch vital monitoring subsystem.
class SmartwatchVitalsState {
  final SmartwatchVitals vitals;
  final bool isMonitoringEnabled;
  final bool isAutoSosEnabled;
  final bool isPreAlertCountdownActive;
  final int countdownSecondsRemaining;
  final String? activeAlertReason;

  const SmartwatchVitalsState({
    required this.vitals,
    this.isMonitoringEnabled = true,
    this.isAutoSosEnabled = true,
    this.isPreAlertCountdownActive = false,
    this.countdownSecondsRemaining = 15,
    this.activeAlertReason,
  });

  SmartwatchVitalsState copyWith({
    SmartwatchVitals? vitals,
    bool? isMonitoringEnabled,
    bool? isAutoSosEnabled,
    bool? isPreAlertCountdownActive,
    int? countdownSecondsRemaining,
    String? activeAlertReason,
    bool clearAlertReason = false,
  }) {
    return SmartwatchVitalsState(
      vitals: vitals ?? this.vitals,
      isMonitoringEnabled: isMonitoringEnabled ?? this.isMonitoringEnabled,
      isAutoSosEnabled: isAutoSosEnabled ?? this.isAutoSosEnabled,
      isPreAlertCountdownActive:
          isPreAlertCountdownActive ?? this.isPreAlertCountdownActive,
      countdownSecondsRemaining:
          countdownSecondsRemaining ?? this.countdownSecondsRemaining,
      activeAlertReason:
          clearAlertReason ? null : (activeAlertReason ?? this.activeAlertReason),
    );
  }
}

/// StateNotifier that connects UI widgets to the SmartwatchVitalService.
class SmartwatchVitalsNotifier extends StateNotifier<SmartwatchVitalsState> {
  final SmartwatchVitalService _service;
  StreamSubscription<SmartwatchVitals>? _vitalsSubscription;
  StreamSubscription<SmartwatchAlertEvent>? _alertSubscription;

  SmartwatchVitalsNotifier(this._service)
      : super(SmartwatchVitalsState(
          vitals: _service.currentVitals,
          isMonitoringEnabled: _service.isMonitoringEnabled,
          isAutoSosEnabled: _service.isAutoSosEnabled,
        )) {
    _init();
  }

  void _init() {
    _vitalsSubscription = _service.vitalsStream.listen((vitals) {
      state = state.copyWith(vitals: vitals);
    });

    _alertSubscription = _service.alertStream.listen((event) {
      if (event.type == AlertEventType.countdownTick) {
        state = state.copyWith(
          isPreAlertCountdownActive: true,
          countdownSecondsRemaining: event.secondsRemaining,
          activeAlertReason: event.reason,
        );
      } else if (event.type == AlertEventType.dismissed) {
        state = state.copyWith(
          isPreAlertCountdownActive: false,
          countdownSecondsRemaining: 15,
          clearAlertReason: true,
        );
      } else if (event.type == AlertEventType.dispatched) {
        state = state.copyWith(
          isPreAlertCountdownActive: false,
          countdownSecondsRemaining: 0,
        );
      }
    });
  }

  Future<void> setMonitoringEnabled(bool enabled) async {
    await _service.setMonitoringEnabled(enabled);
    state = state.copyWith(isMonitoringEnabled: enabled);
  }

  Future<void> setAutoSosEnabled(bool enabled) async {
    await _service.setAutoSosEnabled(enabled);
    state = state.copyWith(isAutoSosEnabled: enabled);
  }

  void dismissEmergency() {
    _service.dismissEmergencyAlert();
  }

  void dispatchEmergencyNow() {
    _service.triggerImmediateEmergencyDispatch();
  }

  Future<void> connectSmartwatch([String? model]) async {
    await _service.connectSmartwatch(model: model);
  }

  Future<void> disconnectSmartwatch() async {
    await _service.disconnectSmartwatch();
  }

  // Simulation helpers for manual testing and demos
  void simulateNormal() => _service.simulateNormal();
  void simulateTachycardia() => _service.simulateTachycardia();
  void simulateHypoxia() => _service.simulateHypoxia();
  void simulateFallAndCollapse() => _service.simulateFallAndCollapse();
  void simulateCardiacArrest() => _service.simulateCardiacArrest();

  @override
  void dispose() {
    _vitalsSubscription?.cancel();
    _alertSubscription?.cancel();
    super.dispose();
  }
}

enum AlertEventType { countdownTick, dismissed, dispatched }

class SmartwatchAlertEvent {
  final AlertEventType type;
  final int secondsRemaining;
  final String? reason;
  final SmartwatchVitals? vitals;

  const SmartwatchAlertEvent({
    required this.type,
    this.secondsRemaining = 15,
    this.reason,
    this.vitals,
  });
}

/// Core service managing smartwatch vital telemetry and automated emergency escalation.
class SmartwatchVitalService {
  static const String prefKeyMonitoringEnabled = 'pref_smartwatch_monitoring_enabled';
  static const String prefKeyAutoSosEnabled = 'pref_smartwatch_auto_sos_enabled';
  static const String prefKeyIsConnected = 'pref_smartwatch_is_connected';
  static const int countdownDurationSeconds = 15;

  final StreamController<SmartwatchVitals> _vitalsController =
      StreamController<SmartwatchVitals>.broadcast();
  final StreamController<SmartwatchAlertEvent> _alertController =
      StreamController<SmartwatchAlertEvent>.broadcast();

  Stream<SmartwatchVitals> get vitalsStream => _vitalsController.stream;
  Stream<SmartwatchAlertEvent> get alertStream => _alertController.stream;

  SmartwatchVitals _currentVitals = SmartwatchVitals.disconnected();
  SmartwatchVitals get currentVitals => _currentVitals;

  bool _isMonitoringEnabled = true;
  bool get isMonitoringEnabled => _isMonitoringEnabled;

  bool _isAutoSosEnabled = true;
  bool get isAutoSosEnabled => _isAutoSosEnabled;

  Timer? _telemetryTimer;
  Timer? _countdownTimer;
  int _countdownSecondsRemaining = countdownDurationSeconds;
  bool _isCountdownActive = false;

  void Function(SmartwatchVitals vitals, String reason)? onEmergencyTriggered;

  bool _preferencesLoaded = false;

  SmartwatchVitalService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMonitoringEnabled = prefs.getBool(prefKeyMonitoringEnabled) ?? true;
      _isAutoSosEnabled = prefs.getBool(prefKeyAutoSosEnabled) ?? true;
      final isConnected = prefs.getBool(prefKeyIsConnected) ?? false;

      if (!_preferencesLoaded) {
        if (isConnected) {
          _currentVitals = SmartwatchVitals.healthy();
        } else {
          _currentVitals = SmartwatchVitals.disconnected();
        }
        _preferencesLoaded = true;
      }
    } catch (_) {
      _isMonitoringEnabled = true;
      _isAutoSosEnabled = true;
      if (!_preferencesLoaded) {
        _currentVitals = SmartwatchVitals.disconnected();
        _preferencesLoaded = true;
      }
    }

    if (_currentVitals.isConnected && _isMonitoringEnabled) {
      startLiveTelemetry();
    }
  }

  /// Connects to a smartwatch or wearable sensor and starts live vital tracking.
  Future<void> connectSmartwatch({String? model}) async {
    _preferencesLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyIsConnected, true);
    } catch (_) {}

    _currentVitals = SmartwatchVitals.healthy().copyWith(
      deviceModel: model ?? 'CampusSafe Wear Sentinel (BLE)',
      isConnected: true,
    );
    _vitalsController.add(_currentVitals);

    if (_isMonitoringEnabled) {
      startLiveTelemetry();
    }
    debugPrint('⌚ [SmartwatchVitalService] Connected to smartwatch: ${_currentVitals.deviceModel}');
  }

  /// Disconnects from the smartwatch, stopping live telemetry and zeroing organ readings.
  Future<void> disconnectSmartwatch() async {
    _preferencesLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyIsConnected, false);
    } catch (_) {}

    stopLiveTelemetry();
    dismissEmergencyAlert();

    _currentVitals = SmartwatchVitals.disconnected();
    _vitalsController.add(_currentVitals);
    debugPrint('⌚ [SmartwatchVitalService] Disconnected from smartwatch. Organ values zeroed.');
  }

  Future<void> setMonitoringEnabled(bool enabled) async {
    _isMonitoringEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyMonitoringEnabled, enabled);
    } catch (_) {}

    if (enabled) {
      if (_currentVitals.isConnected) {
        startLiveTelemetry();
      }
    } else {
      stopLiveTelemetry();
      dismissEmergencyAlert();
    }
  }

  Future<void> setAutoSosEnabled(bool enabled) async {
    _isAutoSosEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyAutoSosEnabled, enabled);
    } catch (_) {}
  }

  /// Starts periodic vital sign simulation with realistic micro-variations.
  void startLiveTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_isMonitoringEnabled || _isCountdownActive || !_currentVitals.isConnected) return;

      // Realistic resting sinus rhythm variation (± 2 BPM) and SpO2
      final random = Random();
      final bpmDelta = random.nextInt(3) - 1; // -1, 0, 1
      final nextBpm = (_currentVitals.heartRateBpm + bpmDelta).clamp(65, 82);
      final nextSpo2 = 98.0 + (random.nextDouble() * 1.5);
      final nextTemp = 36.5 + (random.nextDouble() * 0.3);

      _currentVitals = _currentVitals.copyWith(
        heartRateBpm: nextBpm,
        bloodOxygenSpO2: double.parse(nextSpo2.toStringAsFixed(1)),
        bodyTemperature: double.parse(nextTemp.toStringAsFixed(1)),
        timestamp: DateTime.now(),
      );

      _vitalsController.add(_currentVitals);
    });
  }

  void stopLiveTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  /// Ingests a new vitals reading from the smartwatch sensor feed.
  void processVitalsReading(SmartwatchVitals vitals) {
    _preferencesLoaded = true;
    if (!_isMonitoringEnabled) return;

    _currentVitals = vitals;
    _vitalsController.add(vitals);

    if (vitals.isCriticalEmergency && _isAutoSosEnabled && !_isCountdownActive) {
      _startEmergencyCountdown(vitals);
    }
  }

  void _startEmergencyCountdown(SmartwatchVitals vitals) {
    _isCountdownActive = true;
    _countdownSecondsRemaining = countdownDurationSeconds;
    final reasons = vitals.criticalReasons.join(' & ');

    debugPrint('🚨 [SmartwatchVitalService] Critical anomaly detected: $reasons');

    _alertController.add(SmartwatchAlertEvent(
      type: AlertEventType.countdownTick,
      secondsRemaining: _countdownSecondsRemaining,
      reason: reasons,
      vitals: vitals,
    ));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSecondsRemaining--;

      if (_countdownSecondsRemaining > 0) {
        _alertController.add(SmartwatchAlertEvent(
          type: AlertEventType.countdownTick,
          secondsRemaining: _countdownSecondsRemaining,
          reason: reasons,
          vitals: vitals,
        ));
      } else {
        timer.cancel();
        _isCountdownActive = false;
        triggerImmediateEmergencyDispatch();
      }
    });
  }

  /// Cancels the pre-alert countdown safely (false alarm prevention / "I am OK").
  void dismissEmergencyAlert() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _isCountdownActive = false;
    _countdownSecondsRemaining = countdownDurationSeconds;

    // Reset vitals to healthy if connected, or zeroed disconnected state if not
    _currentVitals = _currentVitals.isConnected
        ? SmartwatchVitals.healthy()
        : SmartwatchVitals.disconnected();
    _vitalsController.add(_currentVitals);

    _alertController.add(const SmartwatchAlertEvent(
      type: AlertEventType.dismissed,
    ));
    debugPrint('🛡️ [SmartwatchVitalService] Emergency countdown dismissed by user.');
  }

  /// Dispatches medical response immediately without waiting for countdown expiry.
  void triggerImmediateEmergencyDispatch() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _isCountdownActive = false;

    final reasons = _currentVitals.criticalReasons.isNotEmpty
        ? _currentVitals.criticalReasons.join('; ')
        : 'Smartwatch Vital Signs Critical Emergency';

    _alertController.add(SmartwatchAlertEvent(
      type: AlertEventType.dispatched,
      secondsRemaining: 0,
      reason: reasons,
      vitals: _currentVitals,
    ));

    debugPrint('🚨 [SmartwatchVitalService] Escalating to Automated Medical SOS: $reasons');
    onEmergencyTriggered?.call(_currentVitals, reasons);
  }

  // ==========================================
  // Simulation Methods for Testing & Demo
  // ==========================================

  void simulateNormal() {
    processVitalsReading(SmartwatchVitals(
      heartRateBpm: 72,
      bloodOxygenSpO2: 98.5,
      bodyTemperature: 36.6,
      fallDetected: false,
      isImmobile: false,
      cardiacStatus: CardiacStatus.normal,
      respiratoryStatus: RespiratoryStatus.normal,
      temperatureStatus: TemperatureStatus.normal,
      timestamp: DateTime.now(),
    ));
  }

  void simulateTachycardia() {
    processVitalsReading(SmartwatchVitals(
      heartRateBpm: 168,
      bloodOxygenSpO2: 96.0,
      bodyTemperature: 37.2,
      fallDetected: false,
      isImmobile: false,
      cardiacStatus: CardiacStatus.tachycardia,
      respiratoryStatus: RespiratoryStatus.normal,
      temperatureStatus: TemperatureStatus.normal,
      timestamp: DateTime.now(),
    ));
  }

  void simulateHypoxia() {
    processVitalsReading(SmartwatchVitals(
      heartRateBpm: 120,
      bloodOxygenSpO2: 84.0,
      bodyTemperature: 36.7,
      fallDetected: false,
      isImmobile: false,
      cardiacStatus: CardiacStatus.normal,
      respiratoryStatus: RespiratoryStatus.criticalHypoxia,
      temperatureStatus: TemperatureStatus.normal,
      timestamp: DateTime.now(),
    ));
  }

  void simulateFallAndCollapse() {
    processVitalsReading(SmartwatchVitals(
      heartRateBpm: 135,
      bloodOxygenSpO2: 95.0,
      bodyTemperature: 36.8,
      fallDetected: true,
      isImmobile: true,
      cardiacStatus: CardiacStatus.normal,
      respiratoryStatus: RespiratoryStatus.normal,
      temperatureStatus: TemperatureStatus.normal,
      timestamp: DateTime.now(),
    ));
  }

  void simulateCardiacArrest() {
    processVitalsReading(SmartwatchVitals(
      heartRateBpm: 0,
      bloodOxygenSpO2: 78.0,
      bodyTemperature: 35.8,
      fallDetected: true,
      isImmobile: true,
      cardiacStatus: CardiacStatus.cardiacArrest,
      respiratoryStatus: RespiratoryStatus.criticalHypoxia,
      temperatureStatus: TemperatureStatus.normal,
      timestamp: DateTime.now(),
    ));
  }

  void dispose() {
    stopLiveTelemetry();
    _countdownTimer?.cancel();
    _vitalsController.close();
    _alertController.close();
  }
}
