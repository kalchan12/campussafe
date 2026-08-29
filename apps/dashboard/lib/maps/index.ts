import type { MapMarker, CampusBlock } from '@/types/map';

export const CAMPUS_BLOCKS: CampusBlock[] = [
  { id: 'engineering', name: 'Engineering Building', latitude: 6.8897, longitude: 79.8823 },
  { id: 'library', name: 'Library', latitude: 6.8901, longitude: 79.8835 },
  { id: 'science', name: 'Science Building', latitude: 6.8910, longitude: 79.8810 },
  { id: 'student_center', name: 'Student Center', latitude: 6.8885, longitude: 79.8845 },
  { id: 'admin', name: 'Admin Building', latitude: 6.8905, longitude: 79.8815 },
  { id: 'parking', name: 'Parking Area', latitude: 6.8895, longitude: 79.8820 },
];

export function getIncidentMarkers(
  incidents: { id: string; latitude: number; longitude: number; type: string; status: string }[]
): MapMarker[] {
  return incidents.map((inc) => ({
    id: inc.id,
    latitude: inc.latitude,
    longitude: inc.longitude,
    type: 'incident' as const,
    label: `${inc.type} - ${inc.status}`,
    status: inc.status,
    color: getIncidentColor(inc.status),
  }));
}

export function getResponderMarkers(
  responders: { id: string; latitude?: number; longitude?: number; name: string; status: string }[]
): MapMarker[] {
  return responders
    .filter((r) => r.latitude && r.longitude)
    .map((resp) => ({
      id: resp.id,
      latitude: resp.latitude!,
      longitude: resp.longitude!,
      type: 'responder' as const,
      label: resp.name,
      status: resp.status,
      color: getResponderColor(resp.status),
    }));
}

export function getDeviceMarkers(
  devices: { id: string; latitude?: number; longitude?: number; name: string; status: string }[]
): MapMarker[] {
  return devices
    .filter((d) => d.latitude && d.longitude)
    .map((dev) => ({
      id: dev.id,
      latitude: dev.latitude!,
      longitude: dev.longitude!,
      type: 'device' as const,
      label: dev.name,
      status: dev.status,
      color: getDeviceColor(dev.status),
    }));
}

function getIncidentColor(status: string): string {
  const colors: Record<string, string> = {
    created: '#6b7280',
    received: '#3b82f6',
    assigned: '#8b5cf6',
    responding: '#f59e0b',
    arrived: '#14b8a6',
    resolved: '#22c55e',
    cancelled: '#9ca3af',
    failed: '#ef4444',
  };
  return colors[status] || '#6b7280';
}

function getResponderColor(status: string): string {
  const colors: Record<string, string> = {
    available: '#22c55e',
    assigned: '#8b5cf6',
    responding: '#f59e0b',
    arrived: '#14b8a6',
    offline: '#9ca3af',
  };
  return colors[status] || '#6b7280';
}

function getDeviceColor(status: string): string {
  const colors: Record<string, string> = {
    online: '#22c55e',
    offline: '#9ca3af',
    maintenance: '#eab308',
    error: '#ef4444',
  };
  return colors[status] || '#6b7280';
}

/**
 * Calculates straight-line distance in meters between two lat/lng points (Haversine formula).
 */
export function calculateDistanceMeters(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371e3; // Earth's radius in meters
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return Math.round(R * c);
}

/**
 * Formats distance in meters into human readable units (e.g., '140 m' or '1.4 km').
 */
export function formatDistance(meters: number): string {
  if (meters < 1000) {
    return `${meters} m`;
  }
  return `${(meters / 1000).toFixed(1)} km`;
}

/**
 * Calculates estimated walking/transit ETA based on average speed (e.g. ~4.8 km/h or 80 m/min).
 */
export function calculateEtaMinutes(meters: number, speedMetersPerMin = 80): string {
  const mins = Math.max(1, Math.ceil(meters / speedMetersPerMin));
  if (mins < 60) return `${mins} min`;
  const hours = Math.floor(mins / 60);
  const remainingMins = mins % 60;
  return `${hours}h ${remainingMins}m`;
}

