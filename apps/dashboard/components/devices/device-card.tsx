import type { Device } from '@/types/device';
import { DEVICE_TYPE_LABELS, DEVICE_STATUS_LABELS } from '@/types/device';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface DeviceCardProps {
  device: Device;
  onClick?: () => void;
}

export function DeviceCard({ device, onClick }: DeviceCardProps) {
  const statusVariant = device.status === 'online' ? 'success' as const
    : device.status === 'error' ? 'error' as const
    : device.status === 'maintenance' ? 'warning' as const
    : 'default' as const;

  const deviceIcon = device.type === 'sos_station' ? 'sos'
    : device.type === 'environmental_node' ? 'thermostat'
    : device.type === 'security_node' ? 'security'
    : 'sensors';

  return (
    <div
      onClick={onClick}
      className="bg-surface-container-lowest border border-outline-variant rounded-lg p-4 hover:border-primary/30 hover:shadow-md transition-all cursor-pointer"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
            device.status === 'online' ? 'bg-emerald-50 text-emerald-600' : 'bg-surface-variant text-on-surface-variant'
          }`}>
            <span className="material-symbols-outlined text-lg">{deviceIcon}</span>
          </div>
          <div>
            <p className="font-body-md text-body-md text-on-surface font-medium">{device.name}</p>
            <p className="font-technical-sm text-technical-sm text-on-surface-variant">{device.device_id}</p>
          </div>
        </div>
        <Badge variant={statusVariant}>
          {DEVICE_STATUS_LABELS[device.status]}
        </Badge>
      </div>

      <div className="space-y-2 font-technical-sm text-technical-sm text-on-surface-variant">
        <div className="flex items-center justify-between">
          <span>Type</span>
          <span className="font-medium text-on-surface">{DEVICE_TYPE_LABELS[device.type]}</span>
        </div>
        {device.location_name && (
          <div className="flex items-center justify-between">
            <span>Location</span>
            <span className="font-medium text-on-surface">{device.location_name}</span>
          </div>
        )}
        {device.firmware_version && (
          <div className="flex items-center justify-between">
            <span>Firmware</span>
            <span className="font-medium text-on-surface">{device.firmware_version}</span>
          </div>
        )}
        {device.last_heartbeat && (
          <div className="flex items-center justify-between">
            <span>Last Heartbeat</span>
            <span className="font-medium text-on-surface">{timeAgo(device.last_heartbeat)}</span>
          </div>
        )}
        {device.last_event_type && (
          <div className="flex items-center justify-between">
            <span>Last Event</span>
            <span className="font-medium text-on-surface">{device.last_event_type}</span>
          </div>
        )}
      </div>
    </div>
  );
}
