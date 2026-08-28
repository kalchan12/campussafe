import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/phone_launcher.dart';

class SafetyGuideView extends StatelessWidget {
  const SafetyGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.sm,
        AppSpacing.containerMargin,
        80 + AppSpacing.safeAreaBottom,
      ),
      children: [
        // 1. 24/7 Campus Emergency Helplines Card
        Card(
          elevation: 2,
          color: AppColors.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '24/7 Campus Emergency Helplines',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap any service below to place a direct phone call to campus responders.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHelplineChip(
                      context,
                      label: 'Campus Police (911)',
                      icon: Icons.local_police_rounded,
                      phone: '911',
                      isEmergency: true,
                    ),
                    _buildHelplineChip(
                      context,
                      label: 'Night Escort (+1 555-0188)',
                      icon: Icons.shield_moon_rounded,
                      phone: '+15550188',
                      isEmergency: false,
                    ),
                    _buildHelplineChip(
                      context,
                      label: 'Campus First Aid (+1 555-0199)',
                      icon: Icons.medical_services_rounded,
                      phone: '+15550199',
                      isEmergency: false,
                    ),
                    _buildHelplineChip(
                      context,
                      label: 'Crisis Line (988)',
                      icon: Icons.support_agent_rounded,
                      phone: '988',
                      isEmergency: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          'Emergency Action Protocols',
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        _buildProtocolTile(
          icon: Icons.lock_clock_rounded,
          iconColor: AppColors.critical,
          title: 'Active Threat & Lockdown',
          steps: [
            'Run: Evacuate if safe path is available.',
            'Hide: Lock doors, turn off lights, silence cell phones.',
            'Fight: As an absolute last resort when in imminent danger.',
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        _buildProtocolTile(
          icon: Icons.air_rounded,
          iconColor: AppColors.warning,
          title: 'Severe Weather & Storms',
          steps: [
            'Move to the lowest interior room or hallway away from windows.',
            'Avoid elevators and stay clear of power lines outdoors.',
            'Monitor official CampusSafe alerts for all-clear broadcast.',
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        _buildProtocolTile(
          icon: Icons.medical_services_rounded,
          iconColor: const Color(0xFF1E88E5),
          title: 'Medical Emergency Protocol',
          steps: [
            'Trigger CampusSafe SOS button or call emergency line.',
            'Do not move an injured person unless immediate danger is present.',
            'Locate the nearest Automated External Defibrillator (AED).',
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        _buildProtocolTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFFF6D00),
          title: 'Fire Alarm & Evacuation',
          steps: [
            'Pull the nearest manual fire alarm pull station.',
            'Evacuate immediately via stairwells — never use elevators.',
            'Gather at the designated campus assembly point.',
          ],
        ),
      ],
    );
  }

  Widget _buildHelplineChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String phone,
    required bool isEmergency,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: isEmergency ? AppColors.critical : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      onPressed: () {
        PhoneLauncherUtil.launchCall(
          context: context,
          phoneNumber: phone,
          contactName: label,
          isEmergency: isEmergency,
        );
      },
      icon: Icon(icon, size: 15, color: isEmergency ? AppColors.critical : AppColors.primary),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: isEmergency ? AppColors.critical : AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildProtocolTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> steps,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          children: [
            ...steps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
