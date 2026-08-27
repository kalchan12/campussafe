import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../shared/models/incident.dart';
import '../../../../shared/widgets/cards.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Campus Incidents',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${incidents.length} active emergency events',
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          // View Mode Switcher: List vs Live GPS Map
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SegmentedButton<IncidentsViewMode>(
              segments: [
                ButtonSegment<IncidentsViewMode>(
                  value: IncidentsViewMode.list,
                  icon: Icon(
                    Icons.view_list_rounded,
                    size: 18,
                    color: viewMode == IncidentsViewMode.list ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  label: Text(
                    'List',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: viewMode == IncidentsViewMode.list ? FontWeight.bold : FontWeight.w500,
                      color: viewMode == IncidentsViewMode.list ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                ButtonSegment<IncidentsViewMode>(
                  value: IncidentsViewMode.map,
                  icon: Icon(
                    Icons.map_rounded,
                    size: 18,
                    color: viewMode == IncidentsViewMode.map ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  label: Text(
                    'Map',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: viewMode == IncidentsViewMode.map ? FontWeight.bold : FontWeight.w500,
                      color: viewMode == IncidentsViewMode.map ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              selected: {viewMode},
              onSelectionChanged: (newSelection) {
                ref.read(incidentsViewModeProvider.notifier).state =
                    newSelection.first;
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return AppColors.surfaceContainerLow;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppColors.onSurfaceVariant;
                }),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: viewMode == IncidentsViewMode.map
          ? IncidentMapView(incidents: incidents)
          : _buildIncidentList(context, ref, filteredIncidents),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new'),
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Report Incident'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildIncidentList(
    BuildContext context,
    WidgetRef ref,
    List<Incident> incidents,
  ) {
    final selectedFilter = ref.watch(selectedEmergencyTypeFilterProvider);
    final allIncidents = ref.watch(incidentsListProvider);

    return Column(
      children: [
        // Filter Chips Row
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(
                    'All (${allIncidents.length})',
                    style: TextStyle(
                      color: selectedFilter == null ? Colors.white : AppColors.onSurface,
                      fontWeight: selectedFilter == null ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  selected: selectedFilter == null,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: AppColors.surfaceContainerLow,
                  side: BorderSide(
                    color: selectedFilter == null
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  onSelected: (_) {
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
                    child: FilterChip(
                      label: Text(
                        '${type.displayName} ($count)',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant.withValues(alpha: 0.6),
                      ),
                      onSelected: (_) {
                        ref.read(selectedEmergencyTypeFilterProvider.notifier).state =
                            selectedFilter == type ? null : type;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // List Content
        Expanded(
          child: incidents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Incidents Found',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'No matching active emergencies for this filter.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.containerMargin,
                    AppSpacing.xs,
                    AppSpacing.containerMargin,
                    80 + AppSpacing.safeAreaBottom,
                  ),
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Column(
                        children: [
                          IncidentCard(
                            id: incident.id,
                            type: incident.type.value,
                            status: incident.status.value,
                            description: incident.description,
                            location: incident.campusBlock,
                            createdAt: incident.createdAt,
                            priority: incident.priority,
                            onTap: () => context.push('/incident/${incident.id}'),
                          ),
                          // Quick Map Action Bar under card
                          if (incident.latitude != null && incident.longitude != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      foregroundColor: AppColors.primary,
                                    ),
                                    onPressed: () {
                                      ref.read(selectedMapIncidentProvider.notifier).state = incident;
                                      ref.read(incidentsViewModeProvider.notifier).state = IncidentsViewMode.map;
                                    },
                                    icon: const Icon(Icons.map_rounded, size: 16),
                                    label: const Text('View on Live Map', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      foregroundColor: AppColors.onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      MapLauncherUtil.openInGoogleMaps(
                                        latitude: incident.latitude!,
                                        longitude: incident.longitude!,
                                        label: '${incident.type.displayName} - ${incident.campusBlock}',
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                                    label: const Text('Google Maps', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
