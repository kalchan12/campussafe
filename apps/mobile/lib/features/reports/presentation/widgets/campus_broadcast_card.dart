import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/campus_alert.dart';
import '../state/alerts_provider.dart';
import 'alert_detail_modal.dart';

class CampusBroadcastCard extends ConsumerWidget {
  final CampusAlert alert;

  const CampusBroadcastCard({
    super.key,
    required this.alert,
  });

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.critical;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.advisory:
        return const Color(0xFF005FAF);
      case AlertSeverity.info:
        return const Color(0xFF3F51B5);
      case AlertSeverity.resolved:
        return AppColors.success;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.emergency_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.advisory:
        return Icons.campaign_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
      case AlertSeverity.resolved:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final severityColor = _getSeverityColor(alert.severity);
    final severityIcon = _getSeverityIcon(alert.severity);

    return Card(
      elevation: alert.severity == AlertSeverity.critical ? 3 : 1.5,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: alert.severity == AlertSeverity.critical
              ? severityColor
              : severityColor.withValues(alpha: 0.3),
          width: alert.severity == AlertSeverity.critical ? 1.8 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(campusAlertsListProvider.notifier).markAsRead(alert.id);
          AlertDetailModal.show(context, alert);
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Severity Badge + Category Badge + Time (well spaced)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Severity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(severityIcon, size: 14, color: severityColor),
                        const SizedBox(width: 5),
                        Text(
                          alert.severity.displayName.toUpperCase(),
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      alert.category.displayName,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Time Badge
                  Text(
                    _formatTime(alert.issuedAt),
                    style: AppTypography.technicalSm.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Broadcast Title
              Text(
                alert.title,
                style: AppTypography.headlineMd.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Broadcast Message Body (Generous line height)
              Text(
                alert.message,
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Action Guidance Banner if required (clean spacing)
              if (alert.actionRequired && alert.actionGuidance != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: severityColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(Icons.shield_outlined, size: 16, color: severityColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.actionGuidance!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: severityColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Affected Zones Chips
              if (alert.affectedLocations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: alert.affectedLocations.map((loc) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            loc,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 10),

              // Bottom Info & Action Bar (Separated so text never squishes or overlaps)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Source: ${alert.author}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (alert.isAcknowledged)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 13, color: AppColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Acknowledged',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: severityColor,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      onPressed: () {
                        ref.read(campusAlertsListProvider.notifier).acknowledgeAlert(alert.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Acknowledged: ${alert.title}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 13, color: Colors.white),
                      label: const Text(
                        'Acknowledge',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20, color: AppColors.onSurfaceVariant),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ref.read(campusAlertsListProvider.notifier).markAsRead(alert.id);
                      AlertDetailModal.show(context, alert);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
