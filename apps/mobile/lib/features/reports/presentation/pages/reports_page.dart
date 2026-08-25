import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/safety_report.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_badge.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/reports/new'),
          ),
        ],
      ),
      body: _buildReportList(),
    );
  }

  Widget _buildReportList() {
    final reports = [
      SafetyReport(
        id: '1',
        isAnonymous: true,
        type: ReportType.suspiciousActivity,
        status: ReportStatus.underReview,
        description: 'Suspicious person near engineering block',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
      ),
      SafetyReport(
        id: '2',
        isAnonymous: false,
        type: ReportType.safetyConcern,
        status: ReportStatus.submitted,
        description: 'Broken glass near library entrance',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Reports Yet',
              style: AppTypography.displayLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Submit a safety report to help keep campus safe',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.sm,
        AppSpacing.containerMargin,
        AppSpacing.lg,
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportCard(
          report: report,
        );
      },
    );
  }
}
