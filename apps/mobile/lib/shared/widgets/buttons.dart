import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/design_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveFgColor = foregroundColor ?? AppColors.onPrimary;

    final child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: effectiveFgColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: effectiveFgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, size: 20, color: effectiveFgColor),
              ],
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBgColor,
        foregroundColor: effectiveFgColor,
        minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        elevation: 1,
        shadowColor: effectiveBgColor.withValues(alpha: 0.3),
        textStyle: AppTypography.labelMd.copyWith(
          color: effectiveFgColor,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return effectiveFgColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return effectiveFgColor.withValues(alpha: 0.05);
          }
          return null;
        }),
      ),
      child: child,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? borderColor;
  final Color? foregroundColor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.borderColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.outlineVariant;
    final effectiveFgColor = foregroundColor ?? AppColors.onSurface;

    final child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: effectiveFgColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: effectiveFgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, size: 20, color: effectiveFgColor),
              ],
            ],
          );

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveFgColor,
        minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: BorderSide(color: effectiveBorderColor, width: 1.5),
        textStyle: AppTypography.labelMd.copyWith(
          color: effectiveFgColor,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return effectiveFgColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return effectiveFgColor.withValues(alpha: 0.05);
          }
          return null;
        }),
      ),
      child: child,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class TertiaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final Color? foregroundColor;

  const TertiaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFgColor = foregroundColor ?? AppColors.primary;

    final child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: effectiveFgColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: effectiveFgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final button = TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveFgColor,
        minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        textStyle: AppTypography.labelMd.copyWith(
          color: effectiveFgColor,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return effectiveFgColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return effectiveFgColor.withValues(alpha: 0.05);
          }
          return null;
        }),
      ),
      child: child,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class EmergencyButton extends StatefulWidget {
  final VoidCallback? onTriggered;
  final Duration holdDuration;
  final double size;
  final bool enabled;

  const EmergencyButton({
    super.key,
    this.onTriggered,
    this.holdDuration = const Duration(seconds: 3),
    this.size = 180,
    this.enabled = true,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isPressing = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: widget.holdDuration,
      vsync: this,
    );
    _progressController.addListener(() {
      if (mounted) {
        setState(() {
          _progress = _progressController.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _onPanDown(DragDownDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _isPressing = true;
    });
    _progressController.forward(from: 0);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    _handleRelease();
  }

  void _onPanCancel() {
    if (!widget.enabled) return;
    _handleRelease();
  }

  void _handleRelease() {
    if (_progress >= 1.0 && widget.onTriggered != null) {
      widget.onTriggered!();
      _triggerHapticFeedback();
    }
    _progressController.stop();
    _progressController.reset();
    if (mounted) {
      setState(() {
        _isPressing = false;
        _progress = 0.0;
      });
    }
  }

  void _triggerHapticFeedback() {
    // Haptic feedback would be implemented with a platform channel
    // For now, we'll just use the visual feedback
  }

  @override
  Widget build(BuildContext context) {
    const circumference = 289.0; // 2 * pi * 46
    final strokeOffset = circumference * (1 - _progress);

    return GestureDetector(
      onPanDown: _onPanDown,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: SizedBox(
        width: widget.size + 40,
        height: widget.size + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse rings when pressing
            if (_isPressing)
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(widget.size + 40, widget.size + 40),
                    painter: _PulsePainter(
                      progress: _progressController.value,
                      color: AppColors.sosRed,
                    ),
                  );
                },
              ),
            // Progress ring
            SizedBox(
              width: widget.size + 8,
              height: widget.size + 8,
              child: CustomPaint(
                painter: _ProgressRingPainter(
                  progress: _progress,
                  color: AppColors.sosRed,
                  strokeWidth: 4,
                ),
              ),
            ),
            // SOS Button
            AnimatedContainer(
              duration: AppDurations.fast,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.enabled
                      ? [AppColors.sosRed, AppColors.sosRedDark]
                      : [AppColors.inactive, AppColors.inactiveLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.enabled
                        ? AppColors.sosRed.withValues(alpha: 0.4)
                        : AppColors.inactive.withValues(alpha: 0.2),
                    blurRadius: 32,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emergency,
                        color: AppColors.onError,
                        size: widget.size * 0.26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: AppColors.onError,
                          fontSize: widget.size * 0.13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontFamily: AppTypography.geist,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Progress indicator text
            if (_isPressing && _progress > 0)
              Positioned(
                bottom: -10,
                child: Text(
                  _progress >= 1.0 ? 'RELEASING...' : 'HOLD TO ACTIVATE',
                  style: AppTypography.technicalSm.copyWith(
                    color: AppColors.sosRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  final Color color;

  _PulsePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * (0.5 + ringProgress * 0.5);
      final opacity = (1.0 - ringProgress) * 0.3;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _PulsePainter && oldDelegate.progress != progress;
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -3.14159 / 2; // -90 degrees (top)
      final sweepAngle = 2 * 3.14159 * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _ProgressRingPainter &&
        oldDelegate.progress != progress &&
        oldDelegate.color != color;
  }
}