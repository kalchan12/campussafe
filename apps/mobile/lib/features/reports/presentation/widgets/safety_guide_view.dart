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
        16,
        12,
        16,
        80 + AppSpacing.safeAreaBottom,
      ),
      children: [
        // 1. 24/7 Campus Emergency Helplines Card (Zero Overflow, Fully Responsive)
        Card(
          elevation: 2,
          color: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24/7 Campus Helplines',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap any helpline below for instant direct dial.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Primary Emergency: Campus Police 811
                _buildPriorityEmergencyTile(
                  context,
                  title: 'Campus Police (Emergency)',
                  number: '811',
                  icon: Icons.local_police_rounded,
                ),
                const SizedBox(height: 10),

                // Other 24/7 Ethiopian Campus Helplines
                _buildHelplineTile(
                  context,
                  title: 'Campus Clinic & Ambulance',
                  numberDisplay: '+251 91 145 2288',
                  phoneNumber: '+251911452288',
                  icon: Icons.medical_services_rounded,
                  badge: '24/7 MEDICAL',
                  badgeColor: const Color(0xFF1E88E5),
                ),
                const SizedBox(height: 8),
                _buildHelplineTile(
                  context,
                  title: 'Night Safety Escort Service',
                  numberDisplay: '+251 92 088 3344',
                  phoneNumber: '+251920883344',
                  icon: Icons.shield_moon_rounded,
                  badge: 'SECURITY',
                  badgeColor: const Color(0xFF7B1FA2),
                ),
                const SizedBox(height: 8),
                _buildHelplineTile(
                  context,
                  title: 'Student Crisis & Counseling',
                  numberDisplay: '+251 91 177 6655',
                  phoneNumber: '+251911776655',
                  icon: Icons.support_agent_rounded,
                  badge: 'SUPPORT',
                  badgeColor: const Color(0xFF00897B),
                ),
                const SizedBox(height: 8),
                _buildHelplineTile(
                  context,
                  title: 'Central Security Desk (EOC)',
                  numberDisplay: '+251 22 111 0455',
                  phoneNumber: '+251221110455',
                  icon: Icons.cell_tower_rounded,
                  badge: 'OPERATIONS',
                  badgeColor: const Color(0xFF546E7A),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Section Title: Action Protocols
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Emergency Action Protocols',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildProtocolTile(
          icon: Icons.lock_clock_rounded,
          iconColor: AppColors.critical,
          title: 'Active Threat & Campus Lockdown',
          tag: 'CRITICAL',
          steps: [
            'RUN: Evacuate immediately if an unobstructed, safe path is available.',
            'HIDE: Lock and barricade doors, turn off lights, and silence mobile devices.',
            'FIGHT: Act with aggression as an absolute last resort when in imminent life danger.',
          ],
        ),
        const SizedBox(height: 10),

        _buildProtocolTile(
          icon: Icons.medical_services_rounded,
          iconColor: const Color(0xFF1E88E5),
          title: 'Medical Emergency & First Aid',
          tag: 'MEDICAL',
          steps: [
            'Trigger CampusSafe SOS or dial 811 / +251 91 145 2288 immediately.',
            'Do not move an injured person unless there is immediate hazard (fire/collapse).',
            'Locate the nearest campus AED unit and check vital signs until responders arrive.',
          ],
        ),
        const SizedBox(height: 10),

        _buildProtocolTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFFF6D00),
          title: 'Fire Alarm & Building Evacuation',
          tag: 'EVACUATION',
          steps: [
            'Pull the nearest manual alarm pull station box immediately.',
            'Evacuate via marked stairwells — NEVER use elevators during a fire alarm.',
            'Gather at the designated campus emergency assembly point on the open field.',
          ],
        ),
        const SizedBox(height: 10),

        _buildProtocolTile(
          icon: Icons.air_rounded,
          iconColor: AppColors.warning,
          title: 'Severe Weather & Storms',
          tag: 'WEATHER',
          steps: [
            'Move to interior ground-floor rooms or central corridors away from windows.',
            'Stay indoors and keep clear of exterior power lines and mature trees.',
            'Check official CampusSafe broadcast notifications for verified all-clear status.',
          ],
        ),
        const SizedBox(height: 10),

        _buildProtocolTile(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF7B1FA2),
          title: 'Night Safety & Harassment Prevention',
          tag: 'SAFETY',
          steps: [
            'Call the Night Safety Escort (+251 92 088 3344) when walking campus after dark.',
            'Stick to designated well-lit campus pathways and Blue Light station corridors.',
            'Submit anonymous incident reports in the Reports tab for rapid security follow-up.',
          ],
        ),
        const SizedBox(height: 20),

        // Bottom Campus Info Footer
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: AppColors.onSurfaceVariant),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ASTU Campus Security operates 24 hours daily. For urgent dispatch, utilize the SOS button or dial 811 directly.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityEmergencyTile(
    BuildContext context, {
    required String title,
    required String number,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        PhoneLauncherUtil.launchCall(
          context: context,
          phoneNumber: number,
          contactName: title,
          isEmergency: true,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.critical.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_police_rounded,
                color: AppColors.critical,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.critical.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'EMERGENCY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.critical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Direct Emergency: $number',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.critical,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.critical,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Call 811',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineTile(
    BuildContext context, {
    required String title,
    required String numberDisplay,
    required String phoneNumber,
    required IconData icon,
    required String badge,
    required Color badgeColor,
  }) {
    return InkWell(
      onTap: () {
        PhoneLauncherUtil.launchCall(
          context: context,
          phoneNumber: phoneNumber,
          contactName: title,
          isEmergency: false,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: badgeColor, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    numberDisplay,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_forwarded_rounded,
                size: 15,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String tag,
    required List<String> steps,
  }) {
    return Card(
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: AppColors.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '3 Action Steps',
                  style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          children: [
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: 10),
            ...steps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final step = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$idx',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
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
