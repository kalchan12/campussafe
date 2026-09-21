import 'package:equatable/equatable.dart';

/// Cardiac health status detected via PPG (optical) and ECG sensors.
enum CardiacStatus {
  normal,
  tachycardia,
  bradycardia,
  arrhythmia,
  cardiacArrest;

  String get displayName {
    switch (this) {
      case CardiacStatus.normal:
        return 'Normal Sinus Rhythm';
      case CardiacStatus.tachycardia:
        return 'Critical Tachycardia';
      case CardiacStatus.bradycardia:
        return 'Severe Bradycardia';
      case CardiacStatus.arrhythmia:
        return 'Suspected Arrhythmia / AFib';
      case CardiacStatus.cardiacArrest:
        return 'Cardiac Arrest / Asystole';
    }
  }

  bool get isCritical =>
      this == CardiacStatus.tachycardia ||
      this == CardiacStatus.bradycardia ||
      this == CardiacStatus.arrhythmia ||
      this == CardiacStatus.cardiacArrest;
}

/// Respiratory and blood oxygenation status detected via SpO2 pulse oximeter sensor.
enum RespiratoryStatus {
  normal,
  hypoxia,
  criticalHypoxia;

  String get displayName {
    switch (this) {
      case RespiratoryStatus.normal:
        return 'Normal Blood Oxygenation';
      case RespiratoryStatus.hypoxia:
        return 'Mild/Moderate Hypoxia';
      case RespiratoryStatus.criticalHypoxia:
        return 'Critical Hypoxia (Respiratory Failure)';
    }
  }

  bool get isCritical => this == RespiratoryStatus.criticalHypoxia;
}

/// Core body temperature status detected via smartwatch skin temperature sensor.
enum TemperatureStatus {
  normal,
  hypothermia,
  hyperthermia;

  String get displayName {
    switch (this) {
      case TemperatureStatus.normal:
        return 'Normal Core Temperature';
      case TemperatureStatus.hypothermia:
        return 'Hypothermia Warning';
      case TemperatureStatus.hyperthermia:
        return 'Heatstroke / Severe Fever';
    }
  }

  bool get isCritical =>
      this == TemperatureStatus.hypothermia ||
      this == TemperatureStatus.hyperthermia;
}

/// Real-time vital signs and emergency telemetry collected from a paired smartwatch.
///
/// Models inputs from typical smartwatch sensors:
/// - Photoplethysmography (PPG): Heart Rate (BPM), Pulse Oximetry (SpO2), HRV
/// - Electrocardiogram (ECG): Cardiac rhythm and Arrhythmia/AFib detection
/// - Inertial Measurement Unit (IMU): 3-axis Accelerometer & Gyroscope for Hard Fall Detection
/// - Skin Temperature Sensor: Hypothermia & Heatstroke detection
/// - Galvanic Skin Response (GSR) / EDA: Sympathetic nervous system arousal & acute trauma shock
class SmartwatchVitals extends Equatable {
  /// Heart Rate in beats per minute (measured via PPG optical sensor)
  final int heartRateBpm;

  /// Blood Oxygen Saturation percentage (measured via SpO2 pulse oximeter)
  final double bloodOxygenSpO2;

  /// Estimated Core/Skin Temperature in Celsius (measured via thermal sensor)
  final double bodyTemperature;

  /// Heart Rate Variability in milliseconds (RMSSD from PPG)
  final double hrvMs;

  /// Electrodermal Activity / Skin Conductance in microSiemens (GSR / EDA)
  final double skinConductanceUs;

  /// True if high-G impact was detected by the smartwatch IMU
  final bool fallDetected;

  /// True if user remains motionless following an impact (man-down detection)
  final bool isImmobile;

  /// Detected cardiac status from ECG & PPG analysis
  final CardiacStatus cardiacStatus;

  /// Detected respiratory status from SpO2 analysis
  final RespiratoryStatus respiratoryStatus;

  /// Detected temperature status
  final TemperatureStatus temperatureStatus;

  /// Paired smartwatch device model name
  final String deviceModel;

  /// Smartwatch battery level percentage (0 - 100)
  final int batteryLevel;

  /// Bluetooth Low Energy (BLE) connection status with smartwatch
  final bool isConnected;

  /// Timestamp of the latest telemetry sample
  final DateTime timestamp;

  const SmartwatchVitals({
    this.heartRateBpm = 74,
    this.bloodOxygenSpO2 = 98.0,
    this.bodyTemperature = 36.6,
    this.hrvMs = 45.0,
    this.skinConductanceUs = 2.5,
    this.fallDetected = false,
    this.isImmobile = false,
    this.cardiacStatus = CardiacStatus.normal,
    this.respiratoryStatus = RespiratoryStatus.normal,
    this.temperatureStatus = TemperatureStatus.normal,
    this.deviceModel = 'CampusSafe Wear Sentinel (BLE)',
    this.batteryLevel = 92,
    this.isConnected = true,
    required this.timestamp,
  });

  /// Factory constructor for a healthy baseline vitals reading
  factory SmartwatchVitals.healthy() {
    return SmartwatchVitals(
      timestamp: DateTime.now(),
    );
  }

  /// Evaluates whether the current vitals breach emergency life-safety thresholds.
  bool get isCriticalEmergency {
    // 1. Critical cardiac distress
    if (heartRateBpm > 150 || heartRateBpm < 40) return true;
    if (cardiacStatus.isCritical) return true;

    // 2. Critical respiratory distress / hypoxia
    if (bloodOxygenSpO2 < 88.0) return true;
    if (respiratoryStatus == RespiratoryStatus.criticalHypoxia) return true;

    // 3. Severe thermal shock
    if (bodyTemperature < 35.0 || bodyTemperature > 39.5) return true;

    // 4. Hard fall accompanied by immobility
    if (fallDetected && isImmobile) return true;

    return false;
  }

  /// List of specific clinical anomaly reasons detected in this vitals sample
  List<String> get criticalReasons {
    final reasons = <String>[];

    if (cardiacStatus == CardiacStatus.cardiacArrest) {
      reasons.add('Suspected Cardiac Arrest / Loss of Pulse');
    } else if (cardiacStatus == CardiacStatus.arrhythmia) {
      reasons.add('Suspected Arrhythmia / Ventricular Irregularity');
    } else if (heartRateBpm > 150) {
      reasons.add('Critical Tachycardia ($heartRateBpm BPM > 150)');
    } else if (heartRateBpm < 40) {
      reasons.add('Severe Bradycardia ($heartRateBpm BPM < 40)');
    }

    if (bloodOxygenSpO2 < 88.0) {
      reasons.add('Critical Hypoxia (${bloodOxygenSpO2.toStringAsFixed(1)}% SpO2 < 88%)');
    } else if (bloodOxygenSpO2 < 92.0) {
      reasons.add('Mild Hypoxia (${bloodOxygenSpO2.toStringAsFixed(1)}% SpO2)');
    }

    if (bodyTemperature < 35.0) {
      reasons.add('Severe Hypothermia (${bodyTemperature.toStringAsFixed(1)}°C)');
    } else if (bodyTemperature > 39.5) {
      reasons.add('Heatstroke / Hyperthermia (${bodyTemperature.toStringAsFixed(1)}°C)');
    }

    if (fallDetected && isImmobile) {
      reasons.add('Hard Fall Detected with Prolonged Immobility');
    } else if (fallDetected) {
      reasons.add('Hard Impact Fall Detected');
    }

    return reasons;
  }

  /// Compact clinical diagnostic string suitable for incident dispatch notes
  String toClinicalSummary() {
    final anomalies = criticalReasons;
    final statusNote = anomalies.isEmpty ? 'Vitals Stable' : anomalies.join('; ');
    return 'HR: $heartRateBpm BPM | SpO2: ${bloodOxygenSpO2.toStringAsFixed(1)}% | Temp: ${bodyTemperature.toStringAsFixed(1)}°C | Fall: ${fallDetected ? "YES" : "NO"} | Status: $statusNote';
  }

  SmartwatchVitals copyWith({
    int? heartRateBpm,
    double? bloodOxygenSpO2,
    double? bodyTemperature,
    double? hrvMs,
    double? skinConductanceUs,
    bool? fallDetected,
    bool? isImmobile,
    CardiacStatus? cardiacStatus,
    RespiratoryStatus? respiratoryStatus,
    TemperatureStatus? temperatureStatus,
    String? deviceModel,
    int? batteryLevel,
    bool? isConnected,
    DateTime? timestamp,
  }) {
    return SmartwatchVitals(
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      bloodOxygenSpO2: bloodOxygenSpO2 ?? this.bloodOxygenSpO2,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      hrvMs: hrvMs ?? this.hrvMs,
      skinConductanceUs: skinConductanceUs ?? this.skinConductanceUs,
      fallDetected: fallDetected ?? this.fallDetected,
      isImmobile: isImmobile ?? this.isImmobile,
      cardiacStatus: cardiacStatus ?? this.cardiacStatus,
      respiratoryStatus: respiratoryStatus ?? this.respiratoryStatus,
      temperatureStatus: temperatureStatus ?? this.temperatureStatus,
      deviceModel: deviceModel ?? this.deviceModel,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isConnected: isConnected ?? this.isConnected,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heart_rate_bpm': heartRateBpm,
      'blood_oxygen_spo2': bloodOxygenSpO2,
      'body_temperature_celsius': bodyTemperature,
      'hrv_ms': hrvMs,
      'skin_conductance_us': skinConductanceUs,
      'fall_detected': fallDetected,
      'is_immobile': isImmobile,
      'cardiac_status': cardiacStatus.name,
      'respiratory_status': respiratoryStatus.name,
      'temperature_status': temperatureStatus.name,
      'device_model': deviceModel,
      'battery_level': batteryLevel,
      'is_connected': isConnected,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SmartwatchVitals.fromJson(Map<String, dynamic> json) {
    return SmartwatchVitals(
      heartRateBpm: (json['heart_rate_bpm'] as num?)?.toInt() ?? 72,
      bloodOxygenSpO2: (json['blood_oxygen_spo2'] as num?)?.toDouble() ?? 98.0,
      bodyTemperature: (json['body_temperature_celsius'] as num?)?.toDouble() ?? 36.6,
      hrvMs: (json['hrv_ms'] as num?)?.toDouble() ?? 45.0,
      skinConductanceUs: (json['skin_conductance_us'] as num?)?.toDouble() ?? 2.5,
      fallDetected: json['fall_detected'] as bool? ?? false,
      isImmobile: json['is_immobile'] as bool? ?? false,
      cardiacStatus: json['cardiac_status'] != null
          ? CardiacStatus.values.firstWhere(
              (e) => e.name == json['cardiac_status'],
              orElse: () => CardiacStatus.normal,
            )
          : CardiacStatus.normal,
      respiratoryStatus: json['respiratory_status'] != null
          ? RespiratoryStatus.values.firstWhere(
              (e) => e.name == json['respiratory_status'],
              orElse: () => RespiratoryStatus.normal,
            )
          : RespiratoryStatus.normal,
      temperatureStatus: json['temperature_status'] != null
          ? TemperatureStatus.values.firstWhere(
              (e) => e.name == json['temperature_status'],
              orElse: () => TemperatureStatus.normal,
            )
          : TemperatureStatus.normal,
      deviceModel: json['device_model'] as String? ?? 'CampusSafe Wear Sentinel (BLE)',
      batteryLevel: (json['battery_level'] as num?)?.toInt() ?? 100,
      isConnected: json['is_connected'] as bool? ?? true,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        heartRateBpm,
        bloodOxygenSpO2,
        bodyTemperature,
        hrvMs,
        skinConductanceUs,
        fallDetected,
        isImmobile,
        cardiacStatus,
        respiratoryStatus,
        temperatureStatus,
        deviceModel,
        batteryLevel,
        isConnected,
        timestamp,
      ];
}
