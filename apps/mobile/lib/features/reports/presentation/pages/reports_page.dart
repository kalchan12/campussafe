import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/campus_alert.dart';
import '../../../../shared/models/safety_report.dart';
import '../state/alerts_provider.dart';
import '../widgets/campus_broadcast_card.dart';
import '../widgets/safety_guide_view.dart';
import '../widgets/safety_report_card_view.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final mode = _tabController.index == 0
            ? AlertsTabMode.broadcasts
            : _tabController.index == 1
                ? AlertsTabMode.myReports
                : AlertsTabMode.safetyGuide;
        ref.read(alertsTabSegmentProvider.notifier).state = mode;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(alertsTabSegmentProvider);
    final alerts = ref.watch(campusAlertsListProvider);
    final reports = ref.watch(userSafetyReportsListProvider);
    final searchQuery = ref.watch(alertsSearchQueryProvider).toLowerCase();
    final selectedCategory = ref.watch(selectedAlertCategoryFilterProvider);
    final selectedReportStatus = ref.watch(selectedReportStatusFilterProvider);

    // Filtered Broadcasts
    final filteredAlerts = alerts.where((alert) {
      final matchesSearch = searchQuery.isEmpty ||
          alert.title.toLowerCase().contains(searchQuery) ||
          alert.message.toLowerCase().contains(searchQuery) ||
          alert.affectedLocations.any((loc) => loc.toLowerCase().contains(searchQuery));
      final matchesCategory = selectedCategory == null || alert.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Filtered Reports
    final filteredReports = reports.where((report) {
      final matchesSearch = searchQuery.isEmpty ||
          report.description.toLowerCase().contains(searchQuery) ||
          (report.locationDescription?.toLowerCase().contains(searchQuery) ?? false);
      final matchesStatus = selectedReportStatus == null || report.status == selectedReportStatus;
      return matchesSearch && matchesStatus;
    }).toList();

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
              'Alerts & Safety Hub',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Campus Broadcast Live',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: [
                Tab(text: 'Broadcasts (${alerts.length})'),
                Tab(text: 'Reports (${reports.length})'),
                const Tab(text: 'Safety Guides'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(alertsSearchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: activeTab == AlertsTabMode.broadcasts
                      ? 'Search campus broadcasts & alerts...'
                      : activeTab == AlertsTabMode.myReports
                          ? 'Search your submitted reports...'
                          : 'Search emergency protocols...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(alertsSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
          ),

          // Sub-filters for active tab
          if (activeTab == AlertsTabMode.broadcasts)
            _buildBroadcastFilters(ref, selectedCategory, alerts)
          else if (activeTab == AlertsTabMode.myReports)
            _buildReportFilters(ref, selectedReportStatus, reports),

          const Divider(height: 1, color: AppColors.outlineVariant),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBroadcastsList(filteredAlerts),
                _buildReportsList(context, filteredReports),
                const SafetyGuideView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new'),
        icon: const Icon(Icons.add_moderator_rounded, size: 20),
        label: const Text(
          'Report Hazard',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
    );
  }

  Widget _buildBroadcastFilters(
    WidgetRef ref,
    AlertCategory? selectedCategory,
    List<CampusAlert> allAlerts,
  ) {
    final isAllSelected = selectedCategory == null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: Text(
              'All (${allAlerts.length})',
              style: TextStyle(
                color: isAllSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isAllSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            selected: isAllSelected,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            backgroundColor: AppColors.surfaceContainerLow,
            side: BorderSide(
              color: isAllSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
            onSelected: (_) {
              ref.read(selectedAlertCategoryFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          ...AlertCategory.values.map((cat) {
            final count = allAlerts.where((a) => a.category == cat).length;
            if (count == 0) return const SizedBox.shrink();

            final isSelected = selectedCategory == cat;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${cat.displayName} ($count)',
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
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
                onSelected: (_) {
                  ref.read(selectedAlertCategoryFilterProvider.notifier).state =
                      isSelected ? null : cat;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReportFilters(
    WidgetRef ref,
    ReportStatus? selectedStatus,
    List<SafetyReport> allReports,
  ) {
    final isAllSelected = selectedStatus == null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: Text(
              'All (${allReports.length})',
              style: TextStyle(
                color: isAllSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isAllSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            selected: isAllSelected,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            backgroundColor: AppColors.surfaceContainerLow,
            side: BorderSide(
              color: isAllSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
            onSelected: (_) {
              ref.read(selectedReportStatusFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          ...ReportStatus.values.map((status) {
            final count = allReports.where((r) => r.status == status).length;
            if (count == 0) return const SizedBox.shrink();

            final isSelected = selectedStatus == status;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${status.displayName} ($count)',
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
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
                onSelected: (_) {
                  ref.read(selectedReportStatusFilterProvider.notifier).state =
                      isSelected ? null : status;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBroadcastsList(List<CampusAlert> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Broadcasts Found',
              style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'There are no active broadcasts matching your filter.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.sm,
        AppSpacing.containerMargin,
        80 + AppSpacing.safeAreaBottom,
      ),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return CampusBroadcastCard(alert: alerts[index]);
      },
    );
  }

  Widget _buildReportsList(BuildContext context, List<SafetyReport> reports) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.sm,
        AppSpacing.containerMargin,
        80 + AppSpacing.safeAreaBottom,
      ),
      children: [
        // Call-to-action banner for submitting new report
        Card(
          elevation: 1,
          color: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report a Safety Concern',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '100% confidential or anonymous hazard reporting for all students and staff.',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.push('/reports/new'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (reports.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.task_alt, size: 48, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No Submitted Reports',
                    style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All your submitted safety concerns and status updates appear here.',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...reports.map((report) => SafetyReportCardView(report: report)),
      ],
    );
  }
}
