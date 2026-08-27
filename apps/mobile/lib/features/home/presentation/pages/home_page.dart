import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_badge.dart';

class HomePage extends ConsumerWidget {
  final bool isGuest;
  final VoidCallback? onLoginPressed;

  const HomePage({
    super.key,
    this.isGuest = false,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.containerMargin,
            right: AppSpacing.containerMargin,
            top: AppSpacing.lg,
            bottom: 104 + AppSpacing.safeAreaBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Campus Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Alex',
                    style: AppTypography.displayLgMobile.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 18,
                          fill: 1.0,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Campus: Secure',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // EMERGENCY SOS ACTION (Dominant Element)
              Center(
                child: Column(
                  children: [
                    EmergencyButton(
                      onTriggered: () => _showSOSConfirmation(context),
                      size: 180,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Press and hold for 3 seconds to request immediate help.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Quick Emergency Types (Bento Grid Style)
              SectionHeader(
                title: 'Quick Emergency Types',
              ),
              const SizedBox(height: AppSpacing.md),
              BentoGrid(
                crossAxisCount: 2,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                childAspectRatio: 1.2,
                children: [
                  _buildEmergencyTypeCard(context, 'Medical', Icons.medical_services, AppColors.error, AppColors.errorContainer),
                  _buildEmergencyTypeCard(context, 'Security', Icons.local_police, AppColors.primary, AppColors.primaryContainer),
                  _buildEmergencyTypeCard(context, 'Fire', Icons.fire_extinguisher, AppColors.warning, AppColors.warningContainer),
                  _buildEmergencyTypeCard(context, 'General', Icons.support, AppColors.information, AppColors.informationContainer),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Status Card (Safety Network)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cell_tower,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Safety Network',
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              StatusDot(
                                color: AppColors.primary,
                                size: 8,
                                isPulsing: true,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Connected',
                                style: AppTypography.technicalSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 32,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.secondaryContainer,
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.tertiaryContainer,
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '2 ',
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: 'Nearby Responders',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isGuest) ...[
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        'Login for Full Access',
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Login to send SOS alerts and track incidents',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'Login',
                        onPressed: onLoginPressed ?? () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyTypeCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Color containerColor,
  ) {
    return InkWell(
      onTap: () => context.push('/sos'),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: containerColor,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Emergency',
          style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
        ),
        content: Text(
          'Are you sure you want to send an SOS alert? Emergency services will be notified immediately.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          PrimaryButton(
            label: 'Yes, Send SOS',
            onPressed: () {
              Navigator.pop(context);
              context.push('/sos');
            },
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onError,
          ),
        ],
      ),
    );
  }
}
