export type DeviceType =
  | 'sos_station'
  | 'environmental_node'
  | 'security_node'
  | 'warning_node';

export type DeviceStatus = 'online' | 'offline' | 'maintenance' | 'error';

export interface Device {
  id: string;
  device_id: string;
  type: DeviceType;
  name: string;
  location_id?: string;
  location_name?: string;
  latitude?: number;
  longitude?: number;
  status: DeviceStatus;
  firmware_version?: string;
  last_heartbeat?: string;
  last_event_type?: string;
  last_event_timestamp?: string;
  created_at: string;
}

export interface DeviceEvent {
  id: string;
  device_id: string;
  event_type: string;
  timestamp: string;
  payload?: Record<string, unknown>;
}

export interface DeviceFilter {
  type?: DeviceType[];
  status?: DeviceStatus[];
  search?: string;
}

export const DEVICE_TYPE_LABELS: Record<DeviceType, string> = {
  sos_station: 'SOS Station',
  environmental_node: 'Environmental Node',
  security_node: 'Security Node',
  warning_node: 'Warning Node',
};

export const DEVICE_STATUS_LABELS: Record<DeviceStatus, string> = {
  online: 'Online',
  offline: 'Offline',
  maintenance: 'Maintenance',
  error: 'Error',
};

export const DEVICE_STATUS_COLORS: Record<DeviceStatus, string> = {
  online: 'bg-green-100 text-green-800',
  offline: 'bg-gray-100 text-gray-500',
  maintenance: 'bg-yellow-100 text-yellow-800',
  error: 'bg-red-100 text-red-800',
};
