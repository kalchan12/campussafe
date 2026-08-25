import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_badge.dart';

class ActiveEmergencyPage extends ConsumerStatefulWidget {
  final String incidentId;

  const ActiveEmergencyPage({
    super.key,
    required this.incidentId,
  });

  @override
  ConsumerState<ActiveEmergencyPage> createState() => _ActiveEmergencyPageState();
}

class _ActiveEmergencyPageState extends ConsumerState<ActiveEmergencyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        border: Border(
                          left: BorderSide(color: AppColors.error, width: 4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning,
                            color: AppColors.error,
                            size: 24,
                            fill: 1.0,
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
                                  'Campus security and medical teams have been dispatched to your location at Engineering Block B.',
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
                    // Tracking Map
                    Container(
                      width: double.infinity,
                      height: 256,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Stack(
                          children: [
                            // Map placeholder
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: AppColors.surfaceContainerHigh,
                              child: const Center(
                                child: Icon(
                                  Icons.map,
                                  size: 48,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            // User Location Marker
                            Positioned(
                              top: 120,
                              left: 80,
                              child: _buildLocationMarker(
                                color: AppColors.primary,
                                label: 'You',
                                isPulsing: true,
                              ),
                            ),
                            // Responder Location Marker
                            Positioned(
                              top: 80,
                              right: 80,
                              child: _buildLocationMarker(
                                color: AppColors.error,
                                label: 'Responder',
                                icon: Icons.local_hospital,
                              ),
                            ),
                            // Path indication (dashed line)
                            CustomPaint(
                              size: Size.infinite,
                              painter: _PathPainter(
                                start: const Offset(80, 136),
                                end: const Offset(320, 96),
                                color: AppColors.error,
                              ),
                            ),
                            // ETA Overlay
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: AppColors.error,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'ETA: 3 min',
                                      style: AppTypography.technicalSm.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Responder Card
                    ResponderCard(
                      name: 'Unit 4 - Medical Responder',
                      role: 'Medical Responder',
                      distance: '350m away',
                      status: 'Approaching',
                      avatarUrl: null,
                      onContact: () {
                        // TODO: Implement contact responder
                      },
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
                          _buildTimeline(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Secondary Actions
                    Column(
                      children: [
                        SecondaryButton(
                          label: 'Update Emergency Details',
                          onPressed: () {},
                          leadingIcon: Icons.edit,
                          foregroundColor: AppColors.primary,
                          borderColor: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TertiaryButton(
                          label: 'Mark as False Alarm',
                          onPressed: () => _showFalseAlarmDialog(context),
                          foregroundColor: AppColors.error,
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

  Widget _buildLocationMarker({
    required Color color,
    required String label,
    IconData? icon,
    bool isPulsing = false,
  }) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            if (!isPulsing) return const SizedBox.shrink();
            return Transform.scale(
              scale: 1.0 + _pulseController.value * 0.5,
              child: Opacity(
                opacity: 1.0 - _pulseController.value * 0.5,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: AppColors.surface, width: 2),
          ),
          child: icon != null
              ? Icon(icon, color: AppColors.onError, size: 18)
              : null,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.computeLuminance() > 0.5 ? AppColors.onSurface : AppColors.onError,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final steps = [
      {
        'title': 'SOS SENT',
        'time': '14:02 PM',
        'status': TimelineStatus.completed,
      },
      {
        'title': 'Alert received',
        'time': '14:02 PM',
        'status': TimelineStatus.completed,
      },
      {
        'title': 'Responder assigned',
        'time': '14:03 PM',
        'status': TimelineStatus.completed,
      },
      {
        'title': 'Responder en route',
        'time': 'Est. Arrival: 14:06 PM',
        'status': TimelineStatus.active,
      },
      {
        'title': 'Arrived',
        'time': '',
        'status': TimelineStatus.pending,
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
              // TODO: Implement false alarm logic
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status == TimelineStatus.pending ? AppColors.surfaceContainerLowest : dotColor,
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
                          margin: const EdgeInsets.all(6),
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
    );
  }
}

class _PathPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _PathPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Quadratic bezier curve
    final controlPoint = Offset(
      (start.dx + end.dx) / 2,
      start.dy - 40,
    );
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      end.dx,
      end.dy,
    );

    // Draw dashed path
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final nextDistance = distance + 8;
          if (nextDistance < metric.length) {
            final nextTangent = metric.getTangentForOffset(nextDistance);
            if (nextTangent != null) {
              canvas.drawLine(tangent.position, nextTangent.position, paint);
            }
          }
        }
        distance += 16;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}