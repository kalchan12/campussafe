import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/incident.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../incidents/presentation/state/incidents_provider.dart';
import '../state/responder_duty_provider.dart';

class ResponderHomePage extends ConsumerWidget {
  const ResponderHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = ref.watch(incidentsListProvider);
    final isLoading = ref.watch(incidentsLoadingProvider);
    final authState = ref.watch(authNotifierProvider);
    final isOnDuty = ref.watch(responderDutyProvider);
    final userId = authState.userId;

    final availableIncidents = incidents.where((i) =>
        i.status == IncidentStatus.received ||
        i.status == IncidentStatus.created ||
        (!i.isAssigned && i.isActive)).toList();

    final assignedToMeCount = incidents.where((i) =>
        i.assignedResponderId == userId ||
        (userId == null && i.status == IncidentStatus.assigned)).length;

    final completedCount = incidents.where((i) => i.status == IncidentStatus.resolved).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder Dashboard'),
        actions: [
          Row(
            children: [
              Text(
                isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOnDuty ? AppColors.success : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: isOnDuty,
                activeTrackColor: AppColors.success,
                onChanged: (value) {
                  ref.read(responderDutyProvider.notifier).toggleDuty(value);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(incidentsListProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                color: isOnDuty ? AppColors.success : AppColors.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isOnDuty
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isOnDuty ? Icons.check_circle : Icons.pause_circle_outline,
                          color: isOnDuty ? Colors.white : AppColors.onSurfaceVariant,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOnDuty ? 'On Duty & Available' : 'Off Duty / Standby',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isOnDuty ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOnDuty
                                  ? 'Live dispatch beacon active • Ready for response'
                                  : 'Toggle switch above to receive live campus dispatch alerts',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOnDuty ? Colors.white70 : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Stats
              const Text(
                'Today\'s Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Assigned',
                      value: '$assignedToMeCount',
                      color: AppColors.statusAssigned,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Completed',
                      value: '$completedCount',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Available Incidents
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Incidents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/responder/available'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isLoading && incidents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Fetching live incidents...',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (availableIncidents.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.done_all, size: 36, color: Colors.green.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'No pending incidents to accept',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...availableIncidents.take(3).map((incident) {
                  return _AvailableIncidentCard(
                    incident: incident,
                    onAccept: () async {
                      if (!isOnDuty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please switch ON DUTY before accepting incidents.'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                        return;
                      }

                      await ref.read(incidentsListProvider.notifier).updateIncidentStatus(
                            incidentId: incident.id,
                            status: IncidentStatus.assigned,
                            responderId: userId,
                          );
                      if (context.mounted) {
                        context.push('/responder/incident/${incident.id}');
                      }
                    },
                    onDecline: () {},
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableIncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _AvailableIncidentCard({
    required this.incident,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getEmergencyIcon(incident.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        incident.campusBlock ?? incident.locationDescription ?? 'Campus Location',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'P${incident.priority}',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (incident.description != null && incident.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                incident.description!,
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getEmergencyIcon(EmergencyType type) {
    IconData icon;
    Color color;

    switch (type) {
      case EmergencyType.medical:
        icon = Icons.medical_services;
        color = AppColors.error;
        break;
      case EmergencyType.security:
        icon = Icons.local_police;
        color = const Color(0xFF1E88E5);
        break;
      case EmergencyType.fire:
        icon = Icons.local_fire_department;
        color = const Color(0xFFFF6D00);
        break;
      case EmergencyType.accident:
        icon = Icons.car_crash;
        color = const Color(0xFFFFB300);
        break;
      case EmergencyType.other:
        icon = Icons.warning;
        color = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}
