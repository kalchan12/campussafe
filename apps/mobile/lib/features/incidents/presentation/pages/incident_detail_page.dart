import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../shared/models/incident.dart';
import '../state/incidents_provider.dart';
import '../widgets/incident_map_view.dart';

class IncidentDetailPage extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailPage({
    super.key,
    required this.incidentId,
  });

  Color _getEmergencyColor(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return AppColors.error;
      case EmergencyType.security:
        return const Color(0xFF1E88E5);
      case EmergencyType.fire:
        return const Color(0xFFFF6D00);
      case EmergencyType.accident:
        return const Color(0xFFFFB300);
      case EmergencyType.other:
        return AppColors.primary;
    }
  }

  IconData _getEmergencyIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return Icons.medical_services_rounded;
      case EmergencyType.security:
        return Icons.local_police_rounded;
      case EmergencyType.fire:
        return Icons.local_fire_department_rounded;
      case EmergencyType.accident:
        return Icons.car_crash_rounded;
      case EmergencyType.other:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = ref.watch(incidentsListProvider);
    final userPos = ref.watch(userLivePositionProvider).value;

    final incident = incidents.firstWhere(
      (inc) => inc.id == incidentId,
      orElse: () => Incident(
        id: incidentId,
        type: EmergencyType.medical,
        status: IncidentStatus.responding,
        priority: 1,
        reporterId: 'user1',
        latitude: 8.5582,
        longitude: 39.2895,
        campusBlock: 'Engineering Complex Block B',
        locationDescription: 'Room 204 near east staircase',
        description: 'Student feeling dizzy and experiencing shortness of breath.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        updatedAt: DateTime.now(),
      ),
    );

    final incColor = _getEmergencyColor(incident.type);
    final incIcon = _getEmergencyIcon(incident.type);

    String? distanceText;
    if (userPos != null && incident.latitude != null && incident.longitude != null) {
      distanceText = formatDistanceBetween(
        LatLng(userPos.latitude, userPos.longitude),
        LatLng(incident.latitude!, incident.longitude!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Incident #${incident.id}'),
        actions: [
          if (incident.isActive)
            TextButton.icon(
              onPressed: () => _showResolveConfirmation(context, ref, incident),
              icon: const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
              label: const Text(
                'Resolve',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          if (incident.latitude != null && incident.longitude != null)
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Open in Google Maps',
              onPressed: () {
                MapLauncherUtil.openInGoogleMaps(
                  latitude: incident.latitude!,
                  longitude: incident.longitude!,
                  label: '${incident.type.displayName} - ${incident.campusBlock}',
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resolved Status Banner if Incident is already resolved
            if (!incident.isActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Resolved',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Removed from active live map • Archived in campus safety history',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Status & Priority Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: incColor.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: incColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(incIcon, size: 16, color: incColor),
                              const SizedBox(width: 6),
                              Text(
                                incident.type.displayName.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: incColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            incident.status.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: incident.priority == 1
                                ? AppColors.error.withValues(alpha: 0.12)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Priority ${incident.priority}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: incident.priority == 1 ? AppColors.error : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      incident.campusBlock ?? 'Campus Emergency',
                      style: AppTypography.displayLgMobile.copyWith(
                        fontSize: 22,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (incident.description != null && incident.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        incident.description!,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Realtime Interactive Map Card with Google Maps Navigation
            Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: const BorderSide(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padded Card Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Location & GPS Map',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            if (distanceText != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.near_me_rounded, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      distanceText,
                                      style: AppTypography.technicalSm.copyWith(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          incident.locationDescription ?? incident.campusBlock ?? 'Campus Area',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Full-Width Interactive Map (Spanning 100% full width of the card edge-to-edge!)
                  SizedBox(
                    height: 380,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        IncidentMapView(
                          incidents: [incident],
                          initialSelectedIncident: incident,
                          isCompact: true,
                        ),
                        // Expand to Fullscreen button overlay on top-left of the map
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog.fullscreen(
                                    child: Scaffold(
                                      appBar: AppBar(
                                        title: Text('${incident.type.displayName} - ${incident.campusBlock}'),
                                        leading: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => Navigator.of(ctx).pop(),
                                        ),
                                      ),
                                      body: IncidentMapView(
                                        incidents: [incident],
                                        initialSelectedIncident: incident,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fullscreen_rounded, size: 16, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Fullscreen Map',
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
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Padded Card Footer (Action buttons)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                              ),
                            ),
                            onPressed: () {
                              final lat = incident.latitude ?? 8.5582;
                              final lng = incident.longitude ?? 39.2895;
                              MapLauncherUtil.openInGoogleMaps(
                                latitude: lat,
                                longitude: lng,
                                label: '${incident.type.displayName} - ${incident.campusBlock ?? "Campus"}',
                              );
                            },
                            icon: const Icon(Icons.map_rounded, size: 18),
                            label: const Text(
                              'Open in Maps',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                              ),
                            ),
                            onPressed: () {
                              final lat = incident.latitude ?? 8.5582;
                              final lng = incident.longitude ?? 39.2895;
                              MapLauncherUtil.openGoogleMapsDirections(
                                latitude: lat,
                                longitude: lng,
                              );
                            },
                            icon: const Icon(Icons.directions_rounded, size: 18),
                            label: const Text(
                              'Start Navigation',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Incident Timeline Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: const BorderSide(color: AppColors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incident Timeline',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _TimelineItem(
                      title: 'Incident Reported',
                      subtitle: 'Alert triggered by ${incident.reporterId}',
                      time: incident.createdAt,
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Received by Operations',
                      subtitle: 'Incident verified and logged in central dashboard',
                      time: incident.createdAt.add(const Duration(minutes: 1)),
                      isCompleted: incident.status != IncidentStatus.created,
                    ),
                    _TimelineItem(
                      title: 'Responder Assigned',
                      subtitle: incident.assignedResponderId != null
                          ? 'Assigned to ${incident.assignedResponderId}'
                          : 'Awaiting responder dispatch',
                      time: incident.assignedAt ?? incident.createdAt.add(const Duration(minutes: 4)),
                      isCompleted: incident.isAssigned,
                    ),
                    _TimelineItem(
                      title: 'Responder En Route',
                      subtitle: 'GPS tracking active and responding to scene',
                      time: incident.respondedAt ?? incident.createdAt.add(const Duration(minutes: 7)),
                      isCompleted: incident.status == IncidentStatus.responding ||
                          incident.status == IncidentStatus.arrived ||
                          incident.status == IncidentStatus.resolved,
                    ),
                    _TimelineItem(
                      title: 'On-Scene Arrival',
                      subtitle: 'Responder arrived at ${incident.campusBlock}',
                      time: incident.arrivedAt ?? incident.createdAt.add(const Duration(minutes: 12)),
                      isCompleted: incident.status == IncidentStatus.arrived ||
                          incident.status == IncidentStatus.resolved,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // User Resolution Action
            if (incident.isActive) ...[
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showResolveConfirmation(context, ref, incident),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'I am Safe • Mark Incident as Resolved',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Marking as resolved removes the emergency pin from the active map and archives it in safety history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ] else ...[
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'Return to Emergencies & History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showResolveConfirmation(BuildContext context, WidgetRef ref, Incident incident) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppColors.success,
            size: 28,
          ),
        ),
        title: const Text(
          'Mark Emergency as Resolved?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you safe and would like to resolve this incident? It will immediately disappear from active campus maps and stay archived in your incident history.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.8),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Keep Active',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await ref.read(incidentsListProvider.notifier).updateIncidentStatus(
                          incidentId: incident.id,
                          status: IncidentStatus.resolved,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Incident #${incident.id} marked as resolved & archived.'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Yes, Resolve',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final DateTime time;
  final bool isCompleted;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    this.subtitle,
    required this.time,
    this.isCompleted = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.success : AppColors.surfaceContainerHigh,
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Center(
                      child: Icon(Icons.check, size: 8, color: Colors.white),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? AppColors.success.withValues(alpha: 0.4) : AppColors.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                        color: isCompleted ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      timeFormat.format(time),
                      style: AppTypography.technicalSm.copyWith(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
