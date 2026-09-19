import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final emergencySmsServiceProvider = Provider<EmergencySmsService>((ref) {
  return EmergencySmsService();
});

/// Service responsible for automated dispatch of emergency SMS alerts via cellular carrier
/// when data networks (Wi-Fi / mobile internet) are unavailable or degraded.
///
/// Dispatches to the two critical campus emergency contacts:
/// 1. Parent / Guardian (configured during registration or profile edit)
/// 2. University Administration / Emergency Dispatch (pre-filled with 0920304050)
class EmergencySmsService {
  static const String _prefParentPhoneKey = 'emergency_parent_phone';
  static const String _prefParentNameKey = 'emergency_parent_name';
  static const String _prefCampusPhoneKey = 'emergency_campus_phone';

  // Legacy key for backward compatibility
  static const String _prefLegacyContactPhoneKey = 'emergency_contact_phone';
  static const String _prefLegacyContactNameKey = 'emergency_contact_name';

  /// Pre-filled demo university administration / campus emergency dispatch phone number
  static const String defaultCampusDispatchNumber = '0920304050';

  static const MethodChannel _smsChannel = MethodChannel('com.campussafe/sms');

  /// Formats a standardized distress message containing essential rescue coordinates.
  String formatEmergencyMessage({
    required String emergencyType,
    required String locationDescription,
    double? latitude,
    double? longitude,
    String? senderName,
    String? notes,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🚨 CAMPUSSAFE EMERGENCY SOS');
    if (senderName != null && senderName.isNotEmpty) {
      buffer.writeln('Student: $senderName');
    }
    buffer.writeln('Type: ${emergencyType.toUpperCase()}');
    buffer.writeln('Location: $locationDescription');
    if (latitude != null && longitude != null) {
      buffer.writeln('GPS: ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}');
      buffer.writeln('Map: https://maps.google.com/?q=$latitude,$longitude');
    }
    if (notes != null && notes.isNotEmpty) {
      buffer.writeln('Notes: $notes');
    }
    buffer.write('Urgent assistance required.');
    return buffer.toString();
  }

  /// Saves the two emergency contacts: Parent and University Admin.
  Future<void> saveEmergencyContacts({
    required String parentPhone,
    String? parentName,
    String? campusAdminPhone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefParentPhoneKey, parentPhone.trim());
    if (parentName != null && parentName.trim().isNotEmpty) {
      await prefs.setString(_prefParentNameKey, parentName.trim());
    }
    await prefs.setString(
      _prefCampusPhoneKey,
      (campusAdminPhone != null && campusAdminPhone.trim().isNotEmpty)
          ? campusAdminPhone.trim()
          : defaultCampusDispatchNumber,
    );

    // Keep legacy keys in sync
    await prefs.setString(_prefLegacyContactPhoneKey, parentPhone.trim());
    if (parentName != null) {
      await prefs.setString(_prefLegacyContactNameKey, parentName.trim());
    }
  }

  /// Retrieves the saved parent emergency phone number.
  Future<String?> getParentPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefParentPhoneKey) ?? prefs.getString(_prefLegacyContactPhoneKey);
  }

  /// Retrieves the saved parent name.
  Future<String?> getParentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefParentNameKey) ?? prefs.getString(_prefLegacyContactNameKey);
  }

  /// Retrieves the university admin / campus dispatch phone number (defaults to 0920304050).
  Future<String> getCampusAdminPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefCampusPhoneKey) ?? defaultCampusDispatchNumber;
  }

  /// Retrieves all emergency recipient phone numbers (Parent + Campus Admin).
  Future<List<String>> getAllEmergencyRecipients() async {
    final parentPhone = await getParentPhone();
    final campusPhone = await getCampusAdminPhone();

    final recipients = <String>[];
    if (parentPhone != null && parentPhone.trim().isNotEmpty) {
      recipients.add(parentPhone.trim());
    }
    if (campusPhone.trim().isNotEmpty && !recipients.contains(campusPhone.trim())) {
      recipients.add(campusPhone.trim());
    }
    if (recipients.isEmpty) {
      recipients.add(defaultCampusDispatchNumber);
    }
    return recipients;
  }

  /// Attempts silent background SMS send via native Android SmsManager.
  Future<bool> _sendDirectBackgroundSms({
    required String phone,
    required String message,
  }) async {
    try {
      final bool? sent = await _smsChannel.invokeMethod<bool>('sendDirectSms', {
        'phone': phone,
        'message': message,
      });
      return sent ?? false;
    } catch (e) {
      debugPrint('[EmergencySmsService] Background direct SMS not available/granted: $e');
      return false;
    }
  }

  /// Automated emergency SMS dispatcher:
  /// 1. Tries to send SMS silently in the background to all emergency contacts (Parent + Campus Admin).
  /// 2. If background sending is unavailable or permissions are not granted, automatically launches
  ///    the native SMS messenger with pre-filled numbers and distress text.
  Future<bool> dispatchAutomatedEmergencySms({
    required String emergencyType,
    required String locationDescription,
    double? latitude,
    double? longitude,
    String? senderName,
    String? notes,
  }) async {
    final recipients = await getAllEmergencyRecipients();
    final body = formatEmergencyMessage(
      emergencyType: emergencyType,
      locationDescription: locationDescription,
      latitude: latitude,
      longitude: longitude,
      senderName: senderName,
      notes: notes,
    );

    debugPrint('[EmergencySmsService] Dispatching automated offline SMS to recipients: $recipients');

    // Attempt direct background SMS first
    bool allBackgroundSent = true;
    for (final recipient in recipients) {
      final success = await _sendDirectBackgroundSms(phone: recipient, message: body);
      if (!success) {
        allBackgroundSent = false;
      }
    }

    if (allBackgroundSent && recipients.isNotEmpty) {
      debugPrint('[EmergencySmsService] Automated background SMS dispatched successfully to all recipients.');
      return true;
    }

    // Fallback: Automatically launch native SMS application with pre-filled recipients and body
    return await launchEmergencySms(
      recipientPhoneNumber: recipients.join(','),
      emergencyType: emergencyType,
      locationDescription: locationDescription,
      latitude: latitude,
      longitude: longitude,
      senderName: senderName,
      notes: notes,
    );
  }

  /// Launches the native cellular SMS composer with pre-filled distress message.
  Future<bool> launchEmergencySms({
    String? recipientPhoneNumber,
    required String emergencyType,
    required String locationDescription,
    double? latitude,
    double? longitude,
    String? senderName,
    String? notes,
  }) async {
    try {
      final String phone;
      if (recipientPhoneNumber != null && recipientPhoneNumber.isNotEmpty) {
        phone = recipientPhoneNumber;
      } else {
        final recipients = await getAllEmergencyRecipients();
        phone = recipients.join(',');
      }

      final body = formatEmergencyMessage(
        emergencyType: emergencyType,
        locationDescription: locationDescription,
        latitude: latitude,
        longitude: longitude,
        senderName: senderName,
        notes: notes,
      );

      final Uri uri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: <String, String>{
          'body': body,
        },
      );

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('[EmergencySmsService] Could not launch SMS URI: $uri');
        return false;
      }
    } catch (e) {
      debugPrint('[EmergencySmsService] Emergency SMS launch failed: $e');
      return false;
    }
  }

  // Backward compatibility helpers
  Future<void> saveEmergencyContact({
    required String phoneNumber,
    required String name,
  }) async {
    await saveEmergencyContacts(parentPhone: phoneNumber, parentName: name);
  }

  Future<String?> getEmergencyContactPhone() => getParentPhone();
  Future<String?> getEmergencyContactName() => getParentName();
}
