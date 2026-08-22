'use client';

import type { Incident, IncidentStatus, EmergencyType } from '@/types/incident';
import {
  INCIDENT_STATUS_LABELS,
  INCIDENT_STATUS_COLORS,
  EMERGENCY_TYPE_LABELS,
  EMERGENCY_TYPE_COLORS,
} from '@/types/incident';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface IncidentTableProps {
  incidents: Incident[];
  onRowClick?: (incident: Incident) => void;
}

export function IncidentTable({ incidents, onRowClick }: IncidentTableProps) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="border-b border-gray-200">
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">ID</th>
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Type</th>
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Status</th>
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Priority</th>
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Location</th>
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Responder</th>
            <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Time</th>
          </tr>
        </thead>
        <tbody>
          {incidents.map((incident) => (
            <tr
              key={incident.id}
              onClick={() => onRowClick?.(incident)}
              className="border-b border-gray-100 hover:bg-gray-50 cursor-pointer"
            >
              <td className="py-3 px-4 text-sm font-mono text-gray-600">
                {incident.id.slice(0, 8)}
              </td>
              <td className="py-3 px-4">
                <Badge className={EMERGENCY_TYPE_COLORS[incident.type]}>
                  {EMERGENCY_TYPE_LABELS[incident.type]}
                </Badge>
              </td>
              <td className="py-3 px-4">
                <Badge className={INCIDENT_STATUS_COLORS[incident.status]}>
                  {INCIDENT_STATUS_LABELS[incident.status]}
                </Badge>
              </td>
              <td className="py-3 px-4 text-sm text-gray-600">
                {incident.priority}
              </td>
              <td className="py-3 px-4 text-sm text-gray-600 max-w-[200px] truncate">
                {incident.location_description || '-'}
              </td>
              <td className="py-3 px-4 text-sm text-gray-600">
                {incident.assigned_responder_name || '-'}
              </td>
              <td className="py-3 px-4 text-sm text-gray-500">
                {timeAgo(incident.created_at)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
