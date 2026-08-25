import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/incident.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_badge.dart';

class IncidentsPage extends ConsumerWidget {
  const IncidentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
      ),
      body: _buildIncidentList(),
    );
  }

  Widget _buildIncidentList() {
    // Mock data for now
    final incidents = [
      Incident(
        id: '1',
        type: EmergencyType.medical,
        status: IncidentStatus.responding,
        priority: 1,
        reporterId: 'user1',
        latitude: 0.0,
        longitude: 0.0,
        campusBlock: 'Engineering Block',
        description: 'Student feeling dizzy',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        updatedAt: DateTime.now(),
      ),
      Incident(
        id: '2',
        type: EmergencyType.security,
        status: IncidentStatus.assigned,
        priority: 2,
        reporterId: 'user2',
        latitude: 0.0,
        longitude: 0.0,
        campusBlock: 'Library',
        description: 'Suspicious activity reported',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
      ),
    ];

    if (incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Active Incidents',
              style: AppTypography.displayLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'All clear! No active emergencies.',
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
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return IncidentCard(
          incident: incident,
          onTap: () => context.push('/incident/${incident.id}'),
        );
      },
    );
  }
}
