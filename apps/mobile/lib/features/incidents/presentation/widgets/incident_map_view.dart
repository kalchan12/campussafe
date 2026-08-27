import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../shared/models/incident.dart';
import '../state/incidents_provider.dart';

class IncidentMapView extends ConsumerStatefulWidget {
  final List<Incident> incidents;
  final Incident? initialSelectedIncident;
  final bool isCompact;

  const IncidentMapView({
    super.key,
    required this.incidents,
    this.initialSelectedIncident,
    this.isCompact = false,
  });

  @override
  ConsumerState<IncidentMapView> createState() => _IncidentMapViewState();
}

class _IncidentMapViewState extends ConsumerState<IncidentMapView>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Default campus fallback coordinate
  static const LatLng _defaultCenter = LatLng(37.4275, -122.1697);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.initialSelectedIncident != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedMapIncidentProvider.notifier).state =
            widget.initialSelectedIncident;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMoveTo(LatLng destLocation, double destZoom) {
    _mapController.move(destLocation, destZoom);
  }

  void _recenterOnUser() {
    final livePos = ref.read(userLivePositionProvider).value;
    if (livePos != null) {
      _animatedMoveTo(LatLng(livePos.latitude, livePos.longitude), 16.5);
    } else {
      ref.read(currentUserLocationProvider.future).then((pos) {
        if (pos != null && mounted) {
          _animatedMoveTo(LatLng(pos.latitude, pos.longitude), 16.5);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acquiring GPS location... Please ensure GPS permissions are enabled.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _fitAllMarkers(List<Incident> activeIncidents) {
    final livePos = ref.read(userLivePositionProvider).value;
    final points = <LatLng>[];

    if (livePos != null) {
      points.add(LatLng(livePos.latitude, livePos.longitude));
    }

    for (final inc in activeIncidents) {
      if (inc.latitude != null && inc.longitude != null && inc.latitude != 0.0) {
        points.add(LatLng(inc.latitude!, inc.longitude!));
      }
    }

    if (points.isEmpty) {
      _animatedMoveTo(_defaultCenter, 15.5);
      return;
    }

    if (points.length == 1) {
      _animatedMoveTo(points.first, 16.0);
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    _animatedMoveTo(LatLng(centerLat, centerLng), 15.0);
  }

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
  Widget build(BuildContext context) {
    final livePosAsync = ref.watch(userLivePositionProvider);
    final selectedFilter = ref.watch(selectedEmergencyTypeFilterProvider);
    final selectedIncident = ref.watch(selectedMapIncidentProvider);

    final filteredIncidents = selectedFilter == null
        ? widget.incidents
        : widget.incidents.where((i) => i.type == selectedFilter).toList();

    final userLatLng = livePosAsync.value != null
        ? LatLng(livePosAsync.value!.latitude, livePosAsync.value!.longitude)
        : null;

    final initialCenter = userLatLng ??
        (filteredIncidents.isNotEmpty && filteredIncidents.first.latitude != null && filteredIncidents.first.latitude != 0.0
            ? LatLng(filteredIncidents.first.latitude!, filteredIncidents.first.longitude!)
            : _defaultCenter);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.isCompact ? AppRadius.md : 0),
      child: Stack(
        children: [
          // Main Interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: widget.isCompact ? 15.0 : 16.0,
              minZoom: 4.0,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, __) {
                if (!widget.isCompact && selectedIncident != null) {
                  ref.read(selectedMapIncidentProvider.notifier).state = null;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.campussafe.campussafe_mobile',
                tileProvider: NetworkTileProvider(),
              ),

              if (userLatLng != null && selectedIncident != null && selectedIncident.latitude != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        userLatLng,
                        LatLng(selectedIncident.latitude!, selectedIncident.longitude!),
                      ],
                      strokeWidth: 3.5,
                      color: _getEmergencyColor(selectedIncident.type).withValues(alpha: 0.8),
                      pattern: const StrokePattern.dotted(),
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // User Live GPS Position Marker
                  if (userLatLng != null)
                    Marker(
                      point: userLatLng,
                      width: 64,
                      height: 64,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 52 * _pulseAnimation.value,
                                height: 52 * _pulseAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.22),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  border: Border.all(color: Colors.white, width: 2.8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_pin_circle_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  ...filteredIncidents.map((incident) {
                    if (incident.latitude == null || incident.longitude == null || incident.latitude == 0.0) {
                      return null;
                    }

                    final isSelected = selectedIncident?.id == incident.id;
                    final incColor = _getEmergencyColor(incident.type);
                    final incIcon = _getEmergencyIcon(incident.type);
                    final pos = LatLng(incident.latitude!, incident.longitude!);

                    return Marker(
                      point: pos,
                      width: isSelected ? 68 : 54,
                      height: isSelected ? 68 : 54,
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedMapIncidentProvider.notifier).state = incident;
                          _animatedMoveTo(pos, 16.5);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: isSelected ? 58 : 46,
                                height: isSelected ? 58 : 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: incColor,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3.5 : 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: incColor.withValues(alpha: 0.5),
                                      blurRadius: isSelected ? 14 : 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    incIcon,
                                    size: isSelected ? 30 : 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (incident.priority == 1)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ),

          if (!widget.isCompact)
            Positioned(
              top: AppSpacing.sm,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All (${widget.incidents.length})',
                      isSelected: selectedFilter == null,
                      onSelected: () => ref.read(selectedEmergencyTypeFilterProvider.notifier).state = null,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ...EmergencyType.values.map((type) {
                      final count = widget.incidents.where((i) => i.type == type).length;
                      if (count == 0) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: _buildFilterChip(
                          label: '${type.displayName} ($count)',
                          icon: _getEmergencyIcon(type),
                          color: _getEmergencyColor(type),
                          isSelected: selectedFilter == type,
                          onSelected: () {
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

          Positioned(
            right: AppSpacing.md,
            top: widget.isCompact ? AppSpacing.sm : 68,
            child: Column(
              children: [
                _buildMapToolButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter GPS',
                  onTap: _recenterOnUser,
                  accent: true,
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildMapToolButton(
                  icon: Icons.zoom_in_rounded,
                  tooltip: 'Zoom in',
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                ),
                const SizedBox(height: 4),
                _buildMapToolButton(
                  icon: Icons.zoom_out_rounded,
                  tooltip: 'Zoom out',
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                ),
                if (!widget.isCompact) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _buildMapToolButton(
                    icon: Icons.center_focus_strong_rounded,
                    tooltip: 'Fit all incidents',
                    onTap: () => _fitAllMarkers(filteredIncidents),
                  ),
                ],
              ],
            ),
          ),

          if (selectedIncident != null && !widget.isCompact)
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: _buildIncidentDetailCard(context, selectedIncident, userLatLng),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final activeColor = color ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : activeColor,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent ? AppColors.primary : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 22,
            color: accent ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentDetailCard(
    BuildContext context,
    Incident incident,
    LatLng? userLocation,
  ) {
    final incColor = _getEmergencyColor(incident.type);
    final incIcon = _getEmergencyIcon(incident.type);

    String? distanceText;
    if (userLocation != null && incident.latitude != null && incident.longitude != null) {
      distanceText = formatDistanceBetween(
        userLocation,
        LatLng(incident.latitude!, incident.longitude!),
      );
    }

    return Card(
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: incColor.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: incColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    children: [
                      Icon(incIcon, size: 14, color: incColor),
                      const SizedBox(width: 4),
                      Text(
                        incident.type.displayName.toUpperCase(),
                        style: AppTypography.labelMd.copyWith(
                          color: incColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    incident.status.displayName,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    ref.read(selectedMapIncidentProvider.notifier).state = null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            Text(
              incident.campusBlock ?? 'Campus Location',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (distanceText != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.near_me_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: AppTypography.technicalSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (incident.description != null && incident.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                incident.description!,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (incident.latitude != null && incident.longitude != null) {
                        MapLauncherUtil.openInGoogleMaps(
                          latitude: incident.latitude!,
                          longitude: incident.longitude!,
                          label: '${incident.type.displayName} Incident - ${incident.campusBlock}',
                        );
                      }
                    },
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text(
                      'Google Maps',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/incident/${incident.id}'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: incColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                      ),
                    ),
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
