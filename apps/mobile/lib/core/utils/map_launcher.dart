import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherUtil {
  MapLauncherUtil._();

  /// Opens Google Maps centered on the specified [latitude] and [longitude].
  static Future<bool> openInGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Incident Location');
    
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    final geoUrl = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)',
    );

    try {
      if (!kIsWeb && await canLaunchUrl(geoUrl)) {
        return await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching map URL: $e');
    }
    return false;
  }

  /// Opens Google Maps directions to the specified [latitude] and [longitude].
  static Future<bool> openGoogleMapsDirections({
    required double latitude,
    required double longitude,
  }) async {
    final directionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(directionsUrl)) {
        return await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching directions URL: $e');
    }
    return false;
  }
}
