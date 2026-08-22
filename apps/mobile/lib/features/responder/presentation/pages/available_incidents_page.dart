import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/incident.dart';

class AvailableIncidentsPage extends ConsumerWidget {
  const AvailableIncidentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = [
      Incident(
        id: '1',
        type: EmergencyType.medical,
        status: IncidentStatus.received,
        priority: 1,
        reporterId: 'user1',
        latitude: 0.0,
        longitude: 0.0,
        campusBlock: 'Engineering Block',
        description: 'Student with chest pain',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      ),
      Incident(
        id: '2',
        type: EmergencyType.security,
        status: IncidentStatus.received,
        priority: 2,
        reporterId: 'user2',
        latitude: 0.0,
        longitude: 0.0,
        campusBlock: 'Library',
        description: 'Unauthorized access attempt',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        updatedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Incidents'),
      ),
      body: incidents.isEmpty
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
                    'All incidents have been assigned',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return _AvailableIncidentCard(
                  incident: incident,
                  onAccept: () {
                    // TODO: Accept incident
                  },
                  onDecline: () {
                    // TODO: Decline incident
                  },
                );
              },
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
                  '${incident.createdAt.minute} min ago',
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
                Text(
                  incident.campusBlock ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
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
