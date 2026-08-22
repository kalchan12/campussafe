import type { Device } from '@/types/device';
import { DEVICE_TYPE_LABELS, DEVICE_STATUS_LABELS, DEVICE_STATUS_COLORS } from '@/types/device';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface DeviceCardProps {
  device: Device;
  onClick?: () => void;
}

export function DeviceCard({ device, onClick }: DeviceCardProps) {
  return (
    <div
      onClick={onClick}
      className="bg-white border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:shadow-md transition-all cursor-pointer"
    >
      <div className="flex items-start justify-between mb-3">
        <div>
          <p className="text-sm font-medium text-gray-900">{device.name}</p>
          <p className="text-xs font-mono text-gray-500">{device.device_id}</p>
        </div>
        <Badge className={DEVICE_STATUS_COLORS[device.status]}>
          {DEVICE_STATUS_LABELS[device.status]}
        </Badge>
      </div>

      <div className="space-y-2 text-xs text-gray-500">
        <div className="flex items-center justify-between">
          <span>Type</span>
          <span className="font-medium text-gray-700">{DEVICE_TYPE_LABELS[device.type]}</span>
        </div>
        {device.location_name && (
          <div className="flex items-center justify-between">
            <span>Location</span>
            <span className="font-medium text-gray-700">{device.location_name}</span>
          </div>
        )}
        {device.firmware_version && (
          <div className="flex items-center justify-between">
            <span>Firmware</span>
            <span className="font-mono text-gray-700">{device.firmware_version}</span>
          </div>
        )}
        {device.last_heartbeat && (
          <div className="flex items-center justify-between">
            <span>Last Heartbeat</span>
            <span className="font-medium text-gray-700">{timeAgo(device.last_heartbeat)}</span>
          </div>
        )}
        {device.last_event_type && (
          <div className="flex items-center justify-between">
            <span>Last Event</span>
            <span className="font-medium text-gray-700">{device.last_event_type}</span>
          </div>
        )}
      </div>
    </div>
  );
}
