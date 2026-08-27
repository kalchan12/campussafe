import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/safety_report.dart';

class SafetyReportCardView extends StatelessWidget {
  final SafetyReport report;

  const SafetyReportCardView({
    super.key,
    required this.report,
  });

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return const Color(0xFF005FAF);
      case ReportStatus.underReview:
        return AppColors.warning;
      case ReportStatus.resolved:
        return AppColors.success;
      case ReportStatus.dismissed:
        return AppColors.inactive;
    }
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.suspiciousActivity:
        return Icons.visibility_outlined;
      case ReportType.securityConcern:
        return Icons.security_rounded;
      case ReportType.fireHazard:
        return Icons.local_fire_department_rounded;
      case ReportType.safetyConcern:
        return Icons.warning_amber_rounded;
      case ReportType.other:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    final typeIcon = _getTypeIcon(report.type);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status Badge + Anonymous Shield + Report ID
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.status.displayName.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (report.isAnonymous)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 12, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4),
                        Text(
                          'Anonymous',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  report.id,
                  style: AppTypography.technicalSm.copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Report Type Header
            Row(
              children: [
                Icon(typeIcon, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  report.type.displayName,
                  style: AppTypography.labelMd.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              report.description,
              style: AppTypography.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),

            // Location
            if (report.locationDescription != null)
              Container(
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
                    Flexible(
                      child: Text(
                        report.locationDescription!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: 8),

            // Footer Timeline Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submitted ${DateFormat('MMM d, h:mm a').format(report.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
                _buildProgressMiniIndicator(report.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMiniIndicator(ReportStatus status) {
    const step1 = true;
    final step2 = status == ReportStatus.underReview || status == ReportStatus.resolved;
    final step3 = status == ReportStatus.resolved;

    return Row(
      children: [
        _buildDot(step1, const Color(0xFF005FAF)),
        _buildLine(step2, AppColors.warning),
        _buildDot(step2, AppColors.warning),
        _buildLine(step3, AppColors.success),
        _buildDot(step3, AppColors.success),
      ],
    );
  }

  Widget _buildDot(bool active, Color color) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? color : AppColors.outlineVariant,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLine(bool active, Color color) {
    return Container(
      width: 14,
      height: 2,
      color: active ? color : AppColors.outlineVariant,
    );
  }
}
