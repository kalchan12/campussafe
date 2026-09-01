import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/user.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../profile/presentation/state/profile_notifier.dart';

final pushNotificationsSettingProvider = StateProvider<bool>((ref) => true);
final locationServiceSettingProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final pushEnabled = ref.watch(pushNotificationsSettingProvider);
    final locationEnabled = ref.watch(locationServiceSettingProvider);

    final user = profileState.user ??
        User(
          id: authState.userId ?? 'usr_guest',
          email: authState.email ?? 'student@campus.edu',
          fullName: 'Campus User',
          role: UserRole.student,
          campusBlock: 'Main Campus Quad',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Settings & Security',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            color: AppColors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Account & Security Section
          _SettingsSection(
            title: 'ACCOUNT & IDENTITY',
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Edit Safety Profile',
                subtitle: user.fullName.isNotEmpty ? user.fullName : 'Update your contact and medical info',
                onTap: () => context.go('/profile'),
              ),
              _SettingsTile(
                icon: Icons.alternate_email_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'Registered Campus Email',
                subtitle: user.email,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.badge_outlined,
                iconColor: const Color(0xFF7C3AED),
                title: 'Campus Role',
                subtitle: user.role.displayName,
              ),
              _SettingsTile(
                icon: Icons.lock_reset_rounded,
                iconColor: const Color(0xFFD97706),
                title: 'Reset Password',
                subtitle: 'Send password recovery link to your email',
                onTap: () => _showPasswordResetDialog(context, ref, user.email),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Notifications Section
          _SettingsSection(
            title: 'NOTIFICATIONS & BROADCASTS',
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_outlined,
                iconColor: AppColors.primary,
                title: 'Push Notifications',
                subtitle: pushEnabled
                    ? 'Receiving high-priority campus safety alerts'
                    : 'Alerts muted (Not recommended)',
                trailing: Switch.adaptive(
                  value: pushEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(pushNotificationsSettingProvider.notifier).state = val;
                  },
                ),
              ),
              const _SettingsTile(
                icon: Icons.volume_up_outlined,
                iconColor: Color(0xFFEA580C),
                title: 'Emergency Siren Override',
                subtitle: 'Overrides silent mode for severe hazard alerts',
                trailing: Icon(Icons.check_circle_rounded, size: 20, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Location & Campus Section
          _SettingsSection(
            title: 'LOCATION & DISPATCH',
            children: [
              _SettingsTile(
                icon: Icons.near_me_outlined,
                iconColor: const Color(0xFF059669),
                title: 'Live GPS Location Services',
                subtitle: locationEnabled
                    ? 'High accuracy GPS enabled for dispatch'
                    : 'Location disabled (Manual block required)',
                trailing: Switch.adaptive(
                  value: locationEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(locationServiceSettingProvider.notifier).state = val;
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.domain_rounded,
                iconColor: AppColors.primary,
                title: 'Assigned Campus Block',
                subtitle: user.campusBlock != null && user.campusBlock!.isNotEmpty
                    ? user.campusBlock!
                    : 'Main Campus Quad',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4. About & Legal Section
          _SettingsSection(
            title: 'ABOUT & LEGAL',
            children: [
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.onSurfaceVariant,
                title: 'CampusSafe Platform',
                subtitle: 'Version 1.0.0 (Enterprise Safety Edition)',
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.onSurfaceVariant,
                title: 'Terms of Service',
                onTap: () => _showTermsDialog(context),
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                iconColor: AppColors.onSurfaceVariant,
                title: 'Privacy & Data Protection',
                onTap: () => _showPrivacyDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 5. Account Actions
          _SettingsSection(
            title: 'ACCOUNT ACTIONS',
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                iconColor: AppColors.primary,
                title: 'Sign Out',
                subtitle: 'Log out from this device',
                titleColor: AppColors.primary,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              _SettingsTile(
                icon: Icons.no_accounts_outlined,
                iconColor: AppColors.error,
                title: 'Deactivate Account',
                subtitle: 'Unlink your campus safety profile',
                titleColor: AppColors.error,
                onTap: () => _showDeactivateDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context, WidgetRef ref, String email) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Send a secure password reset link to $email?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordReset(email);

              if (context.mounted) {
                final currentError = ref.read(authNotifierProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentError == null
                          ? 'Password reset email sent to $email!'
                          : 'Failed: $currentError',
                    ),
                    backgroundColor: currentError == null ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Send Email', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out Confirmation', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Are you sure you want to sign out from CampusSafe?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deactivate Account', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Deactivating your account will disable emergency push alerts and unregister your campus ID. Are you sure?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Deactivate', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const SingleChildScrollView(
          child: Text(
            'CampusSafe is an emergency response coordination platform designed for university students, staff, and authorized responders. It assists in location dispatch and communication during campus emergencies.\n\nCampusSafe does not replace official national emergency services (911). In critical life-threatening situations, dial 911 immediately.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy & Data Protection', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is strictly safeguarded under University Data Protection standards.\n\n• Location data is only shared with verified responders when you actively trigger an SOS or submit a safety report.\n• Anonymous safety reports do not record your user identity or phone number.\n• Medical information is encrypted and accessible only to responding medical units.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(
                    height: 1,
                    indent: 52,
                    color: AppColors.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.onSurfaceVariant)
              : null),
    );
  }
}
