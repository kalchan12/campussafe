import type { MapMarker, CampusBlock } from '@/types/map';

// Real Adama Science & Technology / Adama City Campus Coordinates (Adama, Oromia, Ethiopia)
export const ADAMA_CENTER: [number, number] = [8.5565, 39.2910];

// Boundary bounding box for Adama City & University Campus
export const ADAMA_CAMPUS_BOUNDS: [[number, number], [number, number]] = [
  [8.5200, 39.2400], // Southwest boundary
  [8.5900, 39.3400], // Northeast boundary
];

export const CAMPUS_BLOCKS: CampusBlock[] = [
  { id: 'admin', name: 'Administration Building & EOC', latitude: 8.5565, longitude: 39.2910 },
  { id: 'engineering', name: 'Engineering Complex Block B', latitude: 8.5582, longitude: 39.2895 },
  { id: 'library', name: 'Main Campus Central Library', latitude: 8.5574, longitude: 39.2925 },
  { id: 'science', name: 'Applied Science & Chemistry Labs', latitude: 8.5550, longitude: 39.2880 },
  { id: 'student_center', name: 'Student Union & Cafeteria', latitude: 8.5540, longitude: 39.2935 },
  { id: 'health_center', name: 'Campus Health & Medical Centre', latitude: 8.5595, longitude: 39.2940 },
  { id: 'sports_complex', name: 'Stadium & Sports Complex', latitude: 8.5525, longitude: 39.2870 },
  { id: 'dormitory_north', name: 'North Residential Halls', latitude: 8.5610, longitude: 39.2915 },
  { id: 'main_gate', name: 'Campus Main Entrance Gate', latitude: 8.5515, longitude: 39.2950 },
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

// Precise University Campus Perimeter Polygon (Adama University Campus Zone)
export const ADAMA_UNIVERSITY_CAMPUS_POLYGON: [number, number][] = [
  [8.5630, 39.2885],
  [8.5635, 39.2945],
  [8.5595, 39.2970],
  [8.5510, 39.2975],
  [8.5495, 39.2920],
  [8.5515, 39.2855],
  [8.5580, 39.2850],
  [8.5630, 39.2885],
];

export interface TravelModeEstimates {
  walking: { minutes: number; text: string; distanceMeters: number };
  bicycling: { minutes: number; text: string; distanceMeters: number };
  driving: { minutes: number; text: string; distanceMeters: number };
}

export interface RouteGeoJson {
  coordinates: [number, number][]; // [lat, lng] array
  distanceMeters: number;
  durationSeconds: number;
  estimates: TravelModeEstimates;
  isRealRoadRoute: boolean;
}

/**
 * Calculates multi-modal transit estimates (Walk first, then Bike, then Car).
 * Speeds: Walking ~ 4.8 km/h (80 m/min), Cycling ~ 15 km/h (250 m/min), Car ~ 30 km/h (500 m/min on campus).
 */
export function calculateTravelEstimates(distanceMeters: number): TravelModeEstimates {
  const walkMins = Math.max(1, Math.ceil(distanceMeters / 80));
  const bikeMins = Math.max(1, Math.ceil(distanceMeters / 250));
  const carMins = Math.max(1, Math.ceil(distanceMeters / 500));

  const formatMin = (m: number) => {
    if (m < 60) return `${m} min`;
    const h = Math.floor(m / 60);
    const rem = m % 60;
    return `${h}h ${rem}m`;
  };

  return {
    walking: { minutes: walkMins, text: formatMin(walkMins), distanceMeters },
    bicycling: { minutes: bikeMins, text: formatMin(bikeMins), distanceMeters },
    driving: { minutes: carMins, text: formatMin(carMins), distanceMeters },
  };
}

/**
 * Fetches optimal routing geometry from Public OpenStreetMap OSRM Foot routing engine
 * with instantaneous local geodesic fallback.
 */
export async function getBestRoute(
  startLat: number,
  startLng: number,
  endLat: number,
  endLng: number
): Promise<RouteGeoJson> {
  const straightMeters = calculateDistanceMeters(startLat, startLng, endLat, endLng);

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2500);

    // OSRM foot routing endpoint for pedestrian/campus paths
    const url = `https://router.project-osrm.org/route/v1/foot/${startLng},${startLat};${endLng},${endLat}?overview=full&geometries=geojson`;
    const res = await fetch(url, { signal: controller.signal });
    clearTimeout(timeoutId);

    if (res.ok) {
      const data = await res.json();
      if (data.code === 'Ok' && data.routes && data.routes.length > 0) {
        const route = data.routes[0];
        // OSRM returns GeoJSON [lng, lat], convert to Leaflet [lat, lng]
        const coords: [number, number][] = route.geometry.coordinates.map(
          (c: [number, number]) => [c[1], c[0]]
        );
        const actualMeters = Math.round(route.distance);
        return {
          coordinates: coords,
          distanceMeters: actualMeters,
          durationSeconds: Math.round(route.duration),
          estimates: calculateTravelEstimates(actualMeters),
          isRealRoadRoute: true,
        };
      }
    }
  } catch (err) {
    // Graceful fallback to geodesic line
  }

  // Fallback: direct line with simulated 1.25x road curvature factor
  const roadAdjustedMeters = Math.round(straightMeters * 1.2);
  return {
    coordinates: [
      [startLat, startLng],
      [endLat, endLng],
    ],
    distanceMeters: straightMeters,
    durationSeconds: Math.round(roadAdjustedMeters / 1.33),
    estimates: calculateTravelEstimates(roadAdjustedMeters),
    isRealRoadRoute: false,
  };
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


