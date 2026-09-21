import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/sensors/smartwatch_vital_service.dart';

/// Card widget displayed on the HomePage showing real-time smartwatch vital organ telemetry,
/// sensor connection status, and automated emergency testing controls.
class SmartwatchVitalCard extends ConsumerStatefulWidget {
  const SmartwatchVitalCard({super.key});

  @override
  ConsumerState<SmartwatchVitalCard> createState() => _SmartwatchVitalCardState();
}

class _SmartwatchVitalCardState extends ConsumerState<SmartwatchVitalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vitalsState = ref.watch(smartwatchVitalsNotifierProvider);
    final vitals = vitalsState.vitals;

    if (!vitalsState.isMonitoringEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: vitalsState.isPreAlertCountdownActive
              ? AppColors.critical
              : AppColors.outlineVariant.withValues(alpha: 0.6),
          width: vitalsState.isPreAlertCountdownActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: vitalsState.isPreAlertCountdownActive
                ? AppColors.critical.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pre-Alert Emergency Countdown Banner (if anomaly detected)
          if (vitalsState.isPreAlertCountdownActive)
            _buildEmergencyCountdownBanner(context, ref, vitalsState),

          // Main Vital Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.watch_rounded,
                    color: Color(0xFFDC2626),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smartwatch Vital Sentinel',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        vitals.deviceModel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bluetooth_connected_rounded,
                          size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.outlineVariant),

          // Vital Telemetry Metrics Grid
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Heart Rate (PPG)
                Expanded(
                  child: _buildMetricTile(
                    label: 'Heart Rate',
                    value: '${vitals.heartRateBpm}',
                    unit: 'BPM',
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFE11D48),
                    statusText: vitals.cardiacStatus.displayName,
                    isPulsing: true,
                    isCritical: vitals.cardiacStatus.isCritical ||
                        vitals.heartRateBpm > 140 ||
                        vitals.heartRateBpm < 45,
                  ),
                ),
                const SizedBox(width: 10),
                // Blood Oxygen (SpO2)
                Expanded(
                  child: _buildMetricTile(
                    label: 'Blood Oxygen',
                    value: vitals.bloodOxygenSpO2.toStringAsFixed(1),
                    unit: '%',
                    icon: Icons.air_rounded,
                    iconColor: const Color(0xFF0284C7),
                    statusText: vitals.bloodOxygenSpO2 < 90 ? 'Hypoxia' : 'Optimal',
                    isCritical: vitals.bloodOxygenSpO2 < 88,
                  ),
                ),
                const SizedBox(width: 10),
                // Skin/Core Temp
                Expanded(
                  child: _buildMetricTile(
                    label: 'Temperature',
                    value: vitals.bodyTemperature.toStringAsFixed(1),
                    unit: '°C',
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFD97706),
                    statusText: vitals.bodyTemperature > 38.5
                        ? 'Fever'
                        : (vitals.bodyTemperature < 35.0 ? 'Cold' : 'Normal'),
                    isCritical: vitals.bodyTemperature > 39.5 ||
                        vitals.bodyTemperature < 35.0,
                  ),
                ),
              ],
            ),
          ),

          // Fall & Anomaly Status Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      vitals.fallDetected
                          ? Icons.warning_rounded
                          : Icons.health_and_safety_rounded,
                      size: 15,
                      color: vitals.fallDetected
                          ? AppColors.critical
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vitals.fallDetected
                          ? 'FALL DETECTED'
                          : 'Hard Fall & Collapse Sentinel: Armed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: vitals.fallDetected
                            ? AppColors.critical
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showVitalSimulationSheet(context, ref),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 13, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Test Sensors',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCountdownBanner(
    BuildContext context,
    WidgetRef ref,
    SmartwatchVitalsState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.critical,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(19),
          topRight: Radius.circular(19),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_share_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CRITICAL VITAL ANOMALY (${state.countdownSecondsRemaining}s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          if (state.activeAlertReason != null) ...[
            const SizedBox(height: 4),
            Text(
              state.activeAlertReason!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(smartwatchVitalsNotifierProvider.notifier)
                        .dismissEmergency();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "I'm OK (Dismiss)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(smartwatchVitalsNotifierProvider.notifier)
                        .dispatchEmergencyNow();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.critical,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Dispatch Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required String statusText,
    bool isPulsing = false,
    bool isCritical = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.critical.withValues(alpha: 0.08)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? AppColors.critical.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPulsing)
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Icon(icon, color: iconColor, size: 14),
                )
              else
                Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isCritical ? AppColors.critical : AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: isCritical ? AppColors.critical : AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showVitalSimulationSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Smartwatch Vital Anomaly Testing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Text(
                'Simulate real sensor inputs from PPG, ECG, SpO2, and IMU to verify automated emergency escalation protocols:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildSimOption(
                title: 'Normal Sinus Rhythm',
                subtitle: '72 BPM • 98.5% SpO2 • 36.6°C (Healthy resting baseline)',
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
                onTap: () {
                  ref
                      .read(smartwatchVitalsNotifierProvider.notifier)
                      .simulateNormal();
                  Navigator.pop(ctx);
                },
              ),
              _buildSimOption(
                title: 'Critical Tachycardia Spike',
                subtitle: '168 BPM resting (Breaches 150 BPM cardiac emergency threshold)',
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFE11D48),
                onTap: () {
                  ref
                      .read(smartwatchVitalsNotifierProvider.notifier)
                      .simulateTachycardia();
                  Navigator.pop(ctx);
                },
              ),
              _buildSimOption(
                title: 'Severe Respiratory Hypoxia',
                subtitle: '84.0% SpO2 (Critical oxygen saturation failure < 88%)',
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF0284C7),
                onTap: () {
                  ref
                      .read(smartwatchVitalsNotifierProvider.notifier)
                      .simulateHypoxia();
                  Navigator.pop(ctx);
                },
              ),
              _buildSimOption(
                title: 'Hard Fall & Physical Collapse',
                subtitle: 'IMU high-G impact detected + 30s unresponsive immobility',
                icon: Icons.personal_injury_rounded,
                iconColor: const Color(0xFFD97706),
                onTap: () {
                  ref
                      .read(smartwatchVitalsNotifierProvider.notifier)
                      .simulateFallAndCollapse();
                  Navigator.pop(ctx);
                },
              ),
              _buildSimOption(
                title: 'Cardiac Arrest / Loss of Pulse',
                subtitle: '0 BPM Asystole detected via ECG + critical hypoxia',
                icon: Icons.heart_broken_rounded,
                iconColor: AppColors.critical,
                onTap: () {
                  ref
                      .read(smartwatchVitalsNotifierProvider.notifier)
                      .simulateCardiacArrest();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_arrow_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
