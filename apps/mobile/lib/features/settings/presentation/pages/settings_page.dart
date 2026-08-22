import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          const _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
              ),
              _SettingsTile(
                icon: Icons.lock_outlined,
                title: 'Change Password',
                subtitle: 'Update your password',
              ),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'john.doe@university.edu',
              ),
            ],
          ),
          // Notifications Section
          const _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts for incidents',
                trailing: Switch(
                  value: true,
                  onChanged: null,
                ),
              ),
              _SettingsTile(
                icon: Icons.sms_outlined,
                title: 'SMS Alerts',
                subtitle: 'Receive SMS for critical alerts',
                trailing: Switch(
                  value: false,
                  onChanged: null,
                ),
              ),
            ],
          ),
          // Location Section
          const _SettingsSection(
            title: 'Location',
            children: [
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Location Services',
                subtitle: 'Allow app to access your location',
                trailing: Switch(
                  value: true,
                  onChanged: null,
                ),
              ),
              _SettingsTile(
                icon: Icons.map_outlined,
                title: 'Default Campus Block',
                subtitle: 'Engineering Block',
              ),
            ],
          ),
          // About Section
          const _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outlined,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
              ),
            ],
          ),
          // Danger Zone
          _SettingsSection(
            title: 'Danger Zone',
            children: [
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                titleColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement account deletion
                            Navigator.pop(context);
                            context.go('/login');
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
      leading: Icon(icon, color: titleColor ?? Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
