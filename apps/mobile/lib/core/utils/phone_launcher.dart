import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';

class PhoneLauncherUtil {
  PhoneLauncherUtil._();

  /// Prompts user confirmation then launches the phone dialer with [phoneNumber].
  static Future<void> launchCall({
    required BuildContext context,
    required String phoneNumber,
    required String contactName,
    bool isEmergency = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.phone_in_talk,
              color: isEmergency ? AppColors.critical : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(isEmergency ? 'Call Emergency Line' : 'Confirm Call'),
          ],
        ),
        content: Text(
          'Are you sure you want to call $contactName ($phoneNumber)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEmergency ? AppColors.critical : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uri = Uri.parse('tel:$phoneNumber');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to open dialer for $phoneNumber'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error launching call: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Direct silent launch without confirmation (used for fallback retry/crisis buttons)
  static Future<bool> directCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
