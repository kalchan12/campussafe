import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Center coordinates for Adama Science & Technology University / Adama City Campus
const LatLng kAdamaCampusCenter = LatLng(8.5565, 39.2910);

/// Bounding box constraint for Adama City & University Campus
final LatLngBounds kAdamaCampusBounds = LatLngBounds(
  const LatLng(8.5200, 39.2400), // Southwest boundary
  const LatLng(8.5900, 39.3400), // Northeast boundary
);

/// Precise ASTU / Adama University Full Campus Perimeter Polygon.
/// Covers main gates, administrative block, north dormitories, university stadium,
/// and eastern/northeastern advanced research & technology park.
const List<LatLng> kAdamaCampusPolygon = [
  LatLng(8.5670, 39.2890), // Far North-West Gate & Field perimeter
  LatLng(8.5675, 39.2940), // North perimeter (North of North Residential Halls & Stadium)
  LatLng(8.5680, 39.2985), // North-East (North of University Stadium)
  LatLng(8.5650, 39.3060), // East Research & Technology Center Annex
  LatLng(8.5610, 39.3080), // Eastern Research Complex boundary
  LatLng(8.5530, 39.3050), // South-East Agricultural & Energy Research field
  LatLng(8.5490, 39.2980), // South-East perimeter
  LatLng(8.5480, 39.2920), // South Gate / Main Entrance perimeter
  LatLng(8.5505, 39.2850), // South-West sports boundary
  LatLng(8.5590, 39.2840), // West Engineering perimeter
  LatLng(8.5670, 39.2890), // Close polygon back to North-West
];

/// Campus block reference with names and coordinates
class CampusBlockInfo {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const CampusBlockInfo({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  LatLng get coordinates => LatLng(latitude, longitude);
}

const List<CampusBlockInfo> kAdamaCampusBlocks = [
  CampusBlockInfo(
    id: 'admin',
    name: 'Administration Building & Emergency Operations Center',
    latitude: 8.5565,
    longitude: 39.2910,
  ),
  CampusBlockInfo(
    id: 'engineering',
    name: 'Engineering Complex Block B',
    latitude: 8.5582,
    longitude: 39.2895,
  ),
  CampusBlockInfo(
    id: 'library',
    name: 'Main Campus Central Library',
    latitude: 8.5574,
    longitude: 39.2925,
  ),
  CampusBlockInfo(
    id: 'science',
    name: 'Applied Science & Chemistry Labs',
    latitude: 8.5550,
    longitude: 39.2880,
  ),
  CampusBlockInfo(
    id: 'student_center',
    name: 'Student Union & Cafeteria',
    latitude: 8.5540,
    longitude: 39.2935,
  ),
  CampusBlockInfo(
    id: 'health_center',
    name: 'Campus Health & Medical Centre',
    latitude: 8.5595,
    longitude: 39.2940,
  ),
  CampusBlockInfo(
    id: 'dormitory_north',
    name: 'North Residential Dormitories',
    latitude: 8.5620,
    longitude: 39.2925,
  ),
  CampusBlockInfo(
    id: 'stadium_north',
    name: 'University Stadium & Sports Arena',
    latitude: 8.5645,
    longitude: 39.2955,
  ),
  CampusBlockInfo(
    id: 'research_complex',
    name: 'Advanced Technology & Science Research Institute',
    latitude: 8.5625,
    longitude: 39.3040,
  ),
  CampusBlockInfo(
    id: 'innovation_hub',
    name: 'University Innovation & Incubation Center',
    latitude: 8.5590,
    longitude: 39.3025,
  ),
  CampusBlockInfo(
    id: 'main_gate',
    name: 'Main Campus Entrance Gate & Security Post',
    latitude: 8.5515,
    longitude: 39.2950,
  ),
];

/// Checks if given lat/lng point falls inside the University Campus polygon
/// using the Ray-Casting algorithm.
bool isInsideCampusZone(double lat, double lng) {
  final polygon = kAdamaCampusPolygon;
  bool inside = false;
  for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].latitude;
    final yi = polygon[i].longitude;
    final xj = polygon[j].latitude;
    final yj = polygon[j].longitude;

    final intersect = ((yi > lng) != (yj > lng)) &&
        (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
    if (intersect) {
      inside = !inside;
    }
  }
  return inside;
}

/// Map tile layer styling options
enum MapStyleOption {
  streets,
  satellite,
  darkOps,
  topography,
}

extension MapStyleOptionDetails on MapStyleOption {
  String get label {
    switch (this) {
      case MapStyleOption.streets:
        return 'Standard Streets';
      case MapStyleOption.satellite:
        return 'Satellite Imagery';
      case MapStyleOption.darkOps:
        return 'Dark Tactical';
      case MapStyleOption.topography:
        return 'Topographic';
    }
  }

  String get urlTemplate {
    switch (this) {
      case MapStyleOption.streets:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapStyleOption.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyleOption.darkOps:
        return 'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';
      case MapStyleOption.topography:
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  IconData get icon {
    switch (this) {
      case MapStyleOption.streets:
        return Icons.map_outlined;
      case MapStyleOption.satellite:
        return Icons.satellite_alt_outlined;
      case MapStyleOption.darkOps:
        return Icons.dark_mode_outlined;
      case MapStyleOption.topography:
        return Icons.terrain_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case MapStyleOption.streets:
        return const Color(0xFF1E88E5);
      case MapStyleOption.satellite:
        return const Color(0xFF43A047);
      case MapStyleOption.darkOps:
        return const Color(0xFF7E57C2);
      case MapStyleOption.topography:
        return const Color(0xFFFB8C00);
    }
  }
}
