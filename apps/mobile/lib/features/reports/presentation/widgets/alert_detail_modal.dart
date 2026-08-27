import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/campus_alert.dart';
import '../state/alerts_provider.dart';

class AlertDetailModal extends ConsumerWidget {
  final CampusAlert alert;

  const AlertDetailModal({
    super.key,
    required this.alert,
  });

  static void show(BuildContext context, CampusAlert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailModal(alert: alert),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.critical;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.advisory:
        return AppColors.information;
      case AlertSeverity.info:
        return const Color(0xFF5C6BC0);
      case AlertSeverity.resolved:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getSeverityColor(alert.severity);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Severity Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    alert.severity.displayName.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              alert.title,
              style: AppTypography.headlineMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            // Time & Author
            Text(
              'Issued on ${DateFormat('MMMM d, yyyy • h:mm a').format(alert.issuedAt)} by ${alert.author}',
              style: AppTypography.technicalSm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.md),

            // Message Body
            Text(
              'Official Broadcast Advisory',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alert.message,
              style: AppTypography.bodyMd.copyWith(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Required Guidance Box
            if (alert.actionRequired && alert.actionGuidance != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_rounded, color: color, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Required Safety Action',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.actionGuidance!,
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Affected Locations
            if (alert.affectedLocations.isNotEmpty) ...[
              Text(
                'Affected Campus Zones',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: alert.affectedLocations.map((loc) {
                  return Chip(
                    avatar: const Icon(Icons.location_pin, size: 16, color: AppColors.primary),
                    label: Text(loc, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.surfaceContainerLow,
                    side: const BorderSide(color: AppColors.outlineVariant),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Actions: Acknowledge & Helpline Call
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('tel:911');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text('Campus Security', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.critical,
                      side: const BorderSide(color: AppColors.critical),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(campusAlertsListProvider.notifier).acknowledgeAlert(alert.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alert acknowledged and saved to records.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Acknowledge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
