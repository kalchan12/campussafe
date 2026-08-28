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
      appBar: AppBar(
        title: const Text('Settings & Security'),
      ),
      body: ListView(
        children: [
          // 1. Account & Security Section
          _SettingsSection(
            title: 'Account & Identity',
            children: [
              _SettingsTile(
                icon: Icons.person_outlined,
                title: 'Edit Safety Profile',
                subtitle: user.fullName.isNotEmpty ? user.fullName : 'Update your profile information',
                onTap: () => context.go('/profile'),
              ),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'Registered Email',
                subtitle: user.email,
                trailing: const Icon(Icons.verified_user, size: 18, color: AppColors.success),
              ),
              _SettingsTile(
                icon: Icons.badge_outlined,
                title: 'Campus Role',
                subtitle: user.role.displayName,
                trailing: const SizedBox.shrink(),
              ),
              _SettingsTile(
                icon: Icons.lock_reset_outlined,
                title: 'Reset Password',
                subtitle: 'Send a password recovery email',
                onTap: () => _showPasswordResetDialog(context, ref, user.email),
              ),
            ],
          ),

          // 2. Notifications Section
          _SettingsSection(
            title: 'Safety Broadcasts & Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: pushEnabled
                    ? 'Receiving high-priority emergency alerts'
                    : 'Alerts muted (Not recommended)',
                trailing: Switch(
                  value: pushEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(pushNotificationsSettingProvider.notifier).state = val;
                  },
                ),
              ),
              const _SettingsTile(
                icon: Icons.campaign_outlined,
                title: 'Emergency Sound Channel',
                subtitle: 'Overrides Do Not Disturb for severe hazard SOS alerts',
                trailing: Icon(Icons.check_circle, size: 18, color: AppColors.primary),
              ),
            ],
          ),

          // 3. Location & Campus Section
          _SettingsSection(
            title: 'Location & Proximity',
            children: [
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'GPS Location Services',
                subtitle: locationEnabled
                    ? 'High-accuracy GPS active for emergency dispatch'
                    : 'Location disabled (SOS coordinates will be estimated)',
                trailing: Switch(
                  value: locationEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(locationServiceSettingProvider.notifier).state = val;
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.domain_outlined,
                title: 'Primary Campus Quad',
                subtitle: user.campusBlock != null && user.campusBlock!.isNotEmpty
                    ? user.campusBlock!
                    : 'Main Campus Quad',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),

          // 4. About & Legal Section
          _SettingsSection(
            title: 'About CampusSafe',
            children: [
              const _SettingsTile(
                icon: Icons.verified_outlined,
                title: 'App Version',
                subtitle: 'CampusSafe 1.0.0 (Build 2026.08 - Enterprise Security)',
                trailing: SizedBox.shrink(),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _showTermsDialog(context),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Data Protection',
                onTap: () => _showPrivacyDialog(context),
              ),
            ],
          ),

          // 5. Danger Zone / Logout
          _SettingsSection(
            title: 'Account Actions',
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Log out from this device',
                titleColor: AppColors.primary,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Deactivate Account',
                subtitle: 'Request account removal from campus database',
                titleColor: AppColors.error,
                onTap: () => _showDeactivateDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context, WidgetRef ref, String email) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'Send a secure password reset link to $email?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
        title: const Text('Logout Confirmation'),
        content: const Text(
          'Are you sure you want to sign out from CampusSafe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Deactivating your account will disable emergency push alerts and unregister your campus ID. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Deactivate', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'CampusSafe is an emergency response coordination platform designed for university students, staff, and authorized responders. It assists in location dispatch and communication during campus emergencies.\n\nCampusSafe does not replace official national emergency services (911). In critical life-threatening situations, dial 911 immediately.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Data Protection'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is strictly safeguarded under University Data Protection standards.\n\n• Location data is only shared with verified responders when you actively trigger an SOS or submit a safety report.\n• Anonymous safety reports do not record your user identity or phone number.\n• Medical information is encrypted and accessible only to responding medical units.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
