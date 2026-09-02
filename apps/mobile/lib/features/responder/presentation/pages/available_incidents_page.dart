import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/incident.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../incidents/presentation/state/incidents_provider.dart';

class AvailableIncidentsPage extends ConsumerWidget {
  const AvailableIncidentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncidents = ref.watch(incidentsListProvider);
    final isLoading = ref.watch(incidentsLoadingProvider);
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.userId;

    final availableIncidents = allIncidents.where((i) =>
        i.status == IncidentStatus.received ||
        i.status == IncidentStatus.created ||
        (!i.isAssigned && i.isActive)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Incidents'),
      ),
      body: isLoading && allIncidents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Fetching available incidents...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : availableIncidents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Available Incidents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All incidents have been assigned or resolved',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(incidentsListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: availableIncidents.length,
                    itemBuilder: (context, index) {
                      final incident = availableIncidents[index];
                      return _AvailableIncidentCard(
                        incident: incident,
                        onAccept: () async {
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
                    },
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sosRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    incident.type.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sosRed,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${DateTime.now().difference(incident.createdAt).inMinutes.abs()}m ago',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident.description ?? incident.type.displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    incident.campusBlock ?? incident.locationDescription ?? 'Campus Location',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/incident/${incident.id}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
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
}
