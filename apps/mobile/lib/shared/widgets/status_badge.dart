import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/design_tokens.dart';

enum BadgeVariant {
  critical,
  warning,
  success,
  information,
  inactive,
  primary,
  secondary,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool isActive;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
    this.isActive = true,
    this.isSmall = false,
  });

  static const Map<BadgeVariant, _BadgeColors> _colors = {
    BadgeVariant.critical: _BadgeColors(
      background: AppColors.errorContainer,
      foreground: AppColors.onErrorContainer,
      iconColor: AppColors.error,
    ),
    BadgeVariant.warning: _BadgeColors(
      background: AppColors.warningContainer,
      foreground: AppColors.onWarningContainer,
      iconColor: AppColors.warning,
    ),
    BadgeVariant.success: _BadgeColors(
      background: AppColors.successContainer,
      foreground: AppColors.onSuccessContainer,
      iconColor: AppColors.success,
    ),
    BadgeVariant.information: _BadgeColors(
      background: AppColors.informationContainer,
      foreground: AppColors.onInformationContainer,
      iconColor: AppColors.information,
    ),
    BadgeVariant.inactive: _BadgeColors(
      background: AppColors.inactiveContainer,
      foreground: AppColors.onInactiveContainer,
      iconColor: AppColors.inactive,
    ),
    BadgeVariant.primary: _BadgeColors(
      background: AppColors.primaryContainer,
      foreground: AppColors.onPrimaryContainer,
      iconColor: AppColors.primary,
    ),
    BadgeVariant.secondary: _BadgeColors(
      background: AppColors.secondaryContainer,
      foreground: AppColors.onSecondaryContainer,
      iconColor: AppColors.secondary,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors[variant]!;
    final horizontalPadding = isSmall ? AppSpacing.sm : AppSpacing.md;
    final verticalPadding = isSmall ? AppSpacing.xs : AppSpacing.xs;
    final fontSize = isSmall ? 11.0 : 12.0;
    final iconSize = isSmall ? 12.0 : 14.0;
    final indicatorSize = isSmall ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: isActive ? colors.background : colors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isActive ? colors.iconColor : colors.iconColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: colors.foreground),
            const SizedBox(width: AppSpacing.xs),
          ] else ...[
            Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? colors.iconColor : colors.iconColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isActive ? colors.foreground : colors.foreground.withValues(alpha: 0.5),
              fontFamily: AppTypography.inter,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeColors {
  final Color background;
  final Color foreground;
  final Color iconColor;

  const _BadgeColors({
    required this.background,
    required this.foreground,
    required this.iconColor,
  });
}

class StatusDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool isPulsing;

  const StatusDot({
    super.key,
    required this.color,
    this.size = 8,
    this.isPulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPulsing) {
      return _PulsingDot(color: color, size: size);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

extension IncidentStatusExtension on String {
  BadgeVariant get statusBadgeVariant {
    switch (toLowerCase()) {
      case 'created':
        return BadgeVariant.inactive;
      case 'received':
        return BadgeVariant.information;
      case 'assigned':
        return BadgeVariant.secondary;
      case 'responding':
        return BadgeVariant.warning;
      case 'arrived':
        return BadgeVariant.success;
      case 'resolved':
        return BadgeVariant.success;
      case 'cancelled':
        return BadgeVariant.inactive;
      case 'failed':
        return BadgeVariant.critical;
      case 'escalated':
        return BadgeVariant.warning;
      case 'unassigned':
        return BadgeVariant.inactive;
      default:
        return BadgeVariant.inactive;
    }
  }

  String get statusDisplayName {
    switch (toLowerCase()) {
      case 'created':
        return 'Created';
      case 'received':
        return 'Received';
      case 'assigned':
        return 'Assigned';
      case 'responding':
        return 'Responding';
      case 'arrived':
        return 'Arrived';
      case 'resolved':
        return 'Resolved';
      case 'cancelled':
        return 'Cancelled';
      case 'failed':
        return 'Failed';
      case 'escalated':
        return 'Escalated';
      case 'unassigned':
        return 'Unassigned';
      default:
        return toUpperCase();
    }
  }
}

extension EmergencyTypeExtension on String {
  BadgeVariant get typeBadgeVariant {
    switch (toLowerCase()) {
      case 'medical':
        return BadgeVariant.critical;
      case 'security':
        return BadgeVariant.primary;
      case 'fire':
        return BadgeVariant.warning;
      case 'accident':
        return BadgeVariant.warning;
      case 'general':
        return BadgeVariant.information;
      default:
        return BadgeVariant.information;
    }
  }

  IconData get typeIcon {
    switch (toLowerCase()) {
      case 'medical':
        return Icons.medical_services;
      case 'security':
        return Icons.local_police;
      case 'fire':
        return Icons.fire_extinguisher;
      case 'accident':
        return Icons.car_crash;
      case 'general':
        return Icons.support;
      default:
        return Icons.help_outline;
    }
  }

  Color get typeColor {
    switch (toLowerCase()) {
      case 'medical':
        return AppColors.error;
      case 'security':
        return AppColors.primary;
      case 'fire':
        return AppColors.warning;
      case 'accident':
        return AppColors.warning;
      case 'general':
        return AppColors.information;
      default:
        return AppColors.information;
    }
  }

  Color get typeContainerColor {
    switch (toLowerCase()) {
      case 'medical':
        return AppColors.errorContainer;
      case 'security':
        return AppColors.primaryContainer;
      case 'fire':
        return AppColors.warningContainer;
      case 'accident':
        return AppColors.warningContainer;
      case 'general':
        return AppColors.informationContainer;
      default:
        return AppColors.informationContainer;
    }
  }

  Color get typeOnContainerColor {
    switch (toLowerCase()) {
      case 'medical':
        return AppColors.onErrorContainer;
      case 'security':
        return AppColors.onPrimaryContainer;
      case 'fire':
        return AppColors.onWarningContainer;
      case 'accident':
        return AppColors.onWarningContainer;
      case 'general':
        return AppColors.onInformationContainer;
      default:
        return AppColors.onInformationContainer;
    }
  }
}