import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/incident.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/navigation.dart';
import '../../../incidents/presentation/state/incidents_provider.dart';
import '../../../incidents/presentation/widgets/incident_map_view.dart';

class ActiveEmergencyPage extends ConsumerStatefulWidget {
  final String incidentId;

  const ActiveEmergencyPage({
    super.key,
    required this.incidentId,
  });

  @override
  ConsumerState<ActiveEmergencyPage> createState() => _ActiveEmergencyPageState();
}

class _ActiveEmergencyPageState extends ConsumerState<ActiveEmergencyPage> {
  @override
  Widget build(BuildContext context) {
    final incidents = ref.watch(incidentsListProvider);
    final incident = incidents.firstWhere(
      (i) => i.id == widget.incidentId,
      orElse: () => Incident(
        id: widget.incidentId,
        type: EmergencyType.medical,
        status: IncidentStatus.responding,
        priority: 1,
        reporterId: 'user',
        latitude: 37.4282,
        longitude: -122.1688,
        campusBlock: 'Engineering Block B',
        description: 'Active Emergency Response',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Emergency Top App Bar
            EmergencyTopAppBar(
              title: 'Help is on the way',
              onCancel: () => _showCancelDialog(context),
              backgroundColor: AppColors.errorContainer,
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.containerMargin,
                  AppSpacing.md,
                  AppSpacing.containerMargin,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    // Urgency Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                        border: const Border(
                          left: BorderSide(color: AppColors.error, width: 4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stay Calm and Safe',
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Campus security and response units have been dispatched to your location at ${incident.campusBlock ?? incident.locationDescription ?? 'Campus'}.',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onErrorContainer.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Real Interactive Tracking Map
                    Container(
                      width: double.infinity,
                      height: 256,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: IncidentMapView(
                          incidents: [incident],
                          initialSelectedIncident: incident,
                          isCompact: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Responder Card
                    ResponderCard(
                      name: incident.assignedResponderId != null
                          ? 'Assigned Responder #${incident.assignedResponderId!.substring(0, incident.assignedResponderId!.length > 6 ? 6 : incident.assignedResponderId!.length)}'
                          : 'Unit 4 - Campus Emergency Team',
                      role: '${incident.type.displayName} Responder',
                      distance: 'Dispatch Active',
                      status: incident.status.displayName,
                      avatarUrl: null,
                      onContact: () {},
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Timeline Status
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Response Status',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTimeline(incident),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Secondary Actions
                    Column(
                      children: [
                        SecondaryButton(
                          label: 'Return to Home',
                          onPressed: () => context.go('/home'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => _showFalseAlarmDialog(context),
                          child: Text(
                            'False Alarm? Cancel Emergency',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(Incident incident) {
    final status = incident.status;

    final steps = [
      {
        'title': 'SOS Broadcast Sent',
        'time': 'Logged',
        'status': TimelineStatus.completed,
      },
      {
        'title': 'Alert Received by Dispatch',
        'time': '',
        'status': status == IncidentStatus.created
            ? TimelineStatus.active
            : TimelineStatus.completed,
      },
      {
        'title': 'Responder Assigned',
        'time': incident.assignedResponderId != null ? 'Assigned' : '',
        'status': incident.isAssigned
            ? (status == IncidentStatus.assigned
                ? TimelineStatus.active
                : TimelineStatus.completed)
            : TimelineStatus.pending,
      },
      {
        'title': 'Responder En Route',
        'time': status == IncidentStatus.responding ? 'In transit' : '',
        'status': status == IncidentStatus.responding
            ? TimelineStatus.active
            : (status == IncidentStatus.arrived || status == IncidentStatus.resolved
                ? TimelineStatus.completed
                : TimelineStatus.pending),
      },
      {
        'title': 'Arrived on Scene',
        'time': status == IncidentStatus.arrived ? 'Arrived' : '',
        'status': status == IncidentStatus.arrived
            ? TimelineStatus.active
            : (status == IncidentStatus.resolved
                ? TimelineStatus.completed
                : TimelineStatus.pending),
      },
      {
        'title': 'Resolved',
        'time': status == IncidentStatus.resolved ? 'Completed' : '',
        'status': status == IncidentStatus.resolved
            ? TimelineStatus.completed
            : TimelineStatus.pending,
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return _TimelineStep(
          title: step['title'] as String,
          time: step['time'] as String,
          status: step['status'] as TimelineStatus,
          isLast: isLast,
        );
      }).toList(),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Emergency', style: AppTypography.headlineMd),
        content: Text(
          'Are you sure you want to cancel this emergency? This will notify responders that help is no longer needed.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep Active', style: TextStyle(color: AppColors.primary)),
          ),
          PrimaryButton(
            label: 'Yes, Cancel',
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onError,
          ),
        ],
      ),
    );
  }

  void _showFalseAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as False Alarm', style: AppTypography.headlineMd),
        content: Text(
          'This will mark the emergency as a false alarm and notify responders. Only use this if you accidentally triggered the SOS.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          PrimaryButton(
            label: 'Mark False Alarm',
            onPressed: () {
              Navigator.pop(context);
              ref.read(incidentsListProvider.notifier).updateIncidentStatus(
                    incidentId: widget.incidentId,
                    status: IncidentStatus.cancelled,
                  );
              context.go('/home');
            },
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onError,
          ),
        ],
      ),
    );
  }
}

enum TimelineStatus {
  completed,
  active,
  pending,
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String time;
  final TimelineStatus status;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.time,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color lineColor;
    double dotSize = 20;

    switch (status) {
      case TimelineStatus.completed:
        dotColor = AppColors.primary;
        lineColor = AppColors.primary;
        break;
      case TimelineStatus.active:
        dotColor = AppColors.primary;
        lineColor = AppColors.primary;
        break;
      case TimelineStatus.pending:
        dotColor = AppColors.surfaceContainerLowest;
        lineColor = AppColors.outlineVariant;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == TimelineStatus.pending
                      ? AppColors.surfaceContainerLowest
                      : dotColor,
                  border: status == TimelineStatus.pending
                      ? Border.all(color: AppColors.outlineVariant, width: 2)
                      : status == TimelineStatus.active
                          ? Border.all(color: AppColors.primary, width: 3)
                          : null,
                ),
                child: status == TimelineStatus.completed
                    ? Icon(Icons.check, size: 12, color: AppColors.onPrimary)
                    : status == TimelineStatus.active
                        ? Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMd.copyWith(
                      color: status == TimelineStatus.active
                          ? AppColors.primary
                          : status == TimelineStatus.pending
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                      fontWeight: status == TimelineStatus.active
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: AppTypography.technicalSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
