import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../shared/models/incident.dart';
import '../../../incidents/presentation/state/incidents_provider.dart';
import '../../../incidents/presentation/widgets/incident_map_view.dart';

class IncidentDetailsPage extends ConsumerWidget {
  final String incidentId;

  const IncidentDetailsPage({
    super.key,
    required this.incidentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncidents = ref.watch(incidentsListProvider);
    final incident = allIncidents.firstWhere(
      (i) => i.id == incidentId,
      orElse: () => Incident(
        id: incidentId,
        type: EmergencyType.medical,
        status: IncidentStatus.assigned,
        priority: 1,
        reporterId: 'user',
        latitude: 8.5582,
        longitude: 39.2895,
        campusBlock: 'Engineering Complex Block B',
        description: 'Active emergency dispatch assignment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Incident #${incident.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(incident.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            incident.status.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(incident.status),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Priority ${incident.priority}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      incident.type.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      incident.description ?? 'Emergency dispatched on campus',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Location Card with Real Interactive OpenStreetMap
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live GPS Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            incident.campusBlock ?? incident.locationDescription ?? 'Main Campus',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: IncidentMapView(
                          incidents: [incident],
                          initialSelectedIncident: incident,
                          isCompact: true,
                        ),
                      ),
                    ),
                    if (incident.latitude != null && incident.longitude != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            MapLauncherUtil.openGoogleMapsDirections(
                              latitude: incident.latitude!,
                              longitude: incident.longitude!,
                            );
                          },
                          icon: const Icon(Icons.navigation, color: AppColors.primary, size: 18),
                          label: const Text('Open Turn-by-Turn in Google Maps'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Status Progression',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: incident.status != IncidentStatus.responding && incident.status != IncidentStatus.arrived && incident.status != IncidentStatus.resolved
                          ? () async {
                              await ref
                                  .read(incidentsListProvider.notifier)
                                  .updateIncidentStatus(
                                    incidentId: incident.id,
                                    status: IncidentStatus.responding,
                                  );
                            }
                          : null,
                      icon: const Icon(Icons.directions_car),
                      label: const Text('Mark as En Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusResponding,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: incident.status == IncidentStatus.responding
                          ? () async {
                              await ref
                                  .read(incidentsListProvider.notifier)
                                  .updateIncidentStatus(
                                    incidentId: incident.id,
                                    status: IncidentStatus.arrived,
                                  );
                            }
                          : null,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Mark as Arrived'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusArrived,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: incident.status != IncidentStatus.resolved
                          ? () async {
                              await ref
                                  .read(incidentsListProvider.notifier)
                                  .updateIncidentStatus(
                                    incidentId: incident.id,
                                    status: IncidentStatus.resolved,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Incident marked as resolved!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                context.pop();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Resolved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
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

  Color _getStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.created:
      case IncidentStatus.received:
        return AppColors.warning;
      case IncidentStatus.assigned:
        return AppColors.statusAssigned;
      case IncidentStatus.responding:
        return AppColors.statusResponding;
      case IncidentStatus.arrived:
        return AppColors.statusArrived;
      case IncidentStatus.resolved:
        return AppColors.success;
      case IncidentStatus.cancelled:
      case IncidentStatus.failed:
        return AppColors.error;
    }
  }
}
