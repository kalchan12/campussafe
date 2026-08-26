'use client';

import type { Incident } from '@/types/incident';
import {
  INCIDENT_STATUS_LABELS,
  EMERGENCY_TYPE_LABELS,
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
          <tr className="border-b border-outline-variant">
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">ID</th>
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Type</th>
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Severity</th>
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Status</th>
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Location</th>
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Responder</th>
            <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Time</th>
          </tr>
        </thead>
        <tbody>
          {incidents.map((incident) => (
            <tr
              key={incident.id}
              onClick={() => onRowClick?.(incident)}
              className="border-b border-outline-variant hover:bg-surface-container-low cursor-pointer transition-colors"
            >
              <td className="py-3 px-4 font-technical-sm text-technical-sm text-on-surface">
                {incident.id.toUpperCase()}
              </td>
              <td className="py-3 px-4">
                <span className="font-body-md text-body-md text-on-surface">
                  {EMERGENCY_TYPE_LABELS[incident.type]}
                </span>
              </td>
              <td className="py-3 px-4">
                <Badge variant={incident.priority === 1 ? 'critical' : incident.priority === 2 ? 'high' : 'medium'}>
                  {incident.priority === 1 ? 'Critical' : incident.priority === 2 ? 'High' : 'Medium'}
                </Badge>
              </td>
              <td className="py-3 px-4">
                <Badge variant={['responding', 'created'].includes(incident.status) ? 'error' : 'info'}>
                  {INCIDENT_STATUS_LABELS[incident.status]}
                </Badge>
              </td>
              <td className="py-3 px-4 font-body-md text-body-md text-on-surface max-w-[200px] truncate">
                {incident.location_description || '-'}
              </td>
              <td className="py-3 px-4 font-body-md text-body-md text-on-surface">
                {incident.assigned_responder_name || '-'}
              </td>
              <td className="py-3 px-4 font-technical-sm text-technical-sm text-on-surface-variant">
                {timeAgo(incident.created_at)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
