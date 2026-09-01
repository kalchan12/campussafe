import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/incident.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../state/incidents_provider.dart';
import '../widgets/incident_map_view.dart';

class IncidentsPage extends ConsumerWidget {
  const IncidentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = ref.watch(incidentsListProvider);
    final viewMode = ref.watch(incidentsViewModeProvider);
    final selectedFilter = ref.watch(selectedEmergencyTypeFilterProvider);

    final filteredIncidents = selectedFilter == null
        ? incidents
        : incidents.where((i) => i.type == selectedFilter).toList();

    final activeCount = incidents.where((i) => i.status != IncidentStatus.resolved && i.status != IncidentStatus.cancelled).length;
    final criticalCount = incidents.where((i) => i.priority == 1 && i.status != IncidentStatus.resolved).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Campus Emergencies',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '$activeCount active events across campus',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // View Mode Switcher Pill (List vs Live Map)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewModeOption(
                    icon: Icons.list_alt_rounded,
                    label: 'List',
                    isSelected: viewMode == IncidentsViewMode.list,
                    onTap: () {
                      ref.read(incidentsViewModeProvider.notifier).state =
                          IncidentsViewMode.list;
                    },
                  ),
                  _ViewModeOption(
                    icon: Icons.map_outlined,
                    label: 'Map',
                    isSelected: viewMode == IncidentsViewMode.map,
                    onTap: () {
                      ref.read(incidentsViewModeProvider.notifier).state =
                          IncidentsViewMode.map;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: viewMode == IncidentsViewMode.map
          ? IncidentMapView(incidents: incidents)
          : _buildIncidentList(context, ref, filteredIncidents, incidents, criticalCount),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new'),
        icon: const Icon(Icons.add_alert_rounded, size: 20),
        label: const Text(
          'Report Incident',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
    );
  }

  Widget _buildIncidentList(
    BuildContext context,
    WidgetRef ref,
    List<Incident> filteredIncidents,
    List<Incident> allIncidents,
    int criticalCount,
  ) {
    final selectedFilter = ref.watch(selectedEmergencyTypeFilterProvider);

    return Column(
      children: [
        // Category Filter Chips
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                  label: 'All (${allIncidents.length})',
                  isSelected: selectedFilter == null,
                  onTap: () {
                    ref.read(selectedEmergencyTypeFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ...EmergencyType.values.map((type) {
                  final count = allIncidents.where((i) => i.type == type).length;
                  if (count == 0) return const SizedBox.shrink();

                  final isSelected = selectedFilter == type;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterPill(
                      label: '${type.displayName} ($count)',
                      isSelected: isSelected,
                      icon: type.value.typeIcon,
                      onTap: () {
                        ref.read(selectedEmergencyTypeFilterProvider.notifier).state =
                            isSelected ? null : type;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const Divider(height: 1, color: AppColors.outlineVariant),

        // Incident Cards List
        Expanded(
          child: filteredIncidents.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 40,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Emergencies',
                          style: AppTypography.headlineMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Campus is currently secure. No incidents match your active filter.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
                  itemCount: filteredIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = filteredIncidents[index];
                    return IncidentCard(
                      id: incident.id,
                      type: incident.type.value,
                      status: incident.status.value,
                      description: incident.description,
                      location: incident.campusBlock,
                      createdAt: incident.createdAt,
                      priority: incident.priority,
                      onTap: () => context.push('/incident/${incident.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ViewModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
