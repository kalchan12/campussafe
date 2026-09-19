import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final emergencySmsServiceProvider = Provider<EmergencySmsService>((ref) {
  return EmergencySmsService();
});

/// Service responsible for dispatching emergency SMS alerts via the cellular carrier
/// when data networks (Wi-Fi / mobile internet) are unavailable or degraded.
class EmergencySmsService {
  static const String _prefContactPhoneKey = 'emergency_contact_phone';
  static const String _prefContactNameKey = 'emergency_contact_name';
  static const String defaultCampusDispatchNumber = '811';

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
      final phone = recipientPhoneNumber ?? await getEmergencyContactPhone() ?? defaultCampusDispatchNumber;
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
        debugPrint('Could not launch SMS URI: $uri');
        return false;
      }
    } catch (e) {
      debugPrint('Emergency SMS launch failed: $e');
      return false;
    }
  }

  /// Saves a trusted personal emergency contact's phone and name.
  Future<void> saveEmergencyContact({
    required String phoneNumber,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefContactPhoneKey, phoneNumber);
    await prefs.setString(_prefContactNameKey, name);
  }

  /// Retrieves the saved emergency contact phone number.
  Future<String?> getEmergencyContactPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefContactPhoneKey);
  }

  /// Retrieves the saved emergency contact name.
  Future<String?> getEmergencyContactName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefContactNameKey);
  }
}
