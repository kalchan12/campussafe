import type { Incident } from '@/types/incident';
import { INCIDENT_STATUS_LABELS } from '@/types/incident';
import { formatDateTime } from '@/lib/utils';

interface IncidentTimelineProps {
  incident: Incident;
}

export function IncidentTimeline({ incident }: IncidentTimelineProps) {
  const events = [
    { status: 'created', time: incident.created_at, label: 'Incident Created' },
    incident.assigned_at && { status: 'assigned', time: incident.assigned_at, label: 'Responder Assigned' },
    incident.responded_at && { status: 'responding', time: incident.responded_at, label: 'Responder En Route' },
    incident.arrived_at && { status: 'arrived', time: incident.arrived_at, label: 'Responder Arrived' },
    incident.resolved_at && { status: 'resolved', time: incident.resolved_at, label: 'Incident Resolved' },
  ].filter(Boolean) as { status: string; time: string; label: string }[];

  return (
    <div className="space-y-4">
      {events.map((event, index) => (
        <div key={index} className="flex items-start gap-4">
          <div className="flex flex-col items-center">
            <div
              className={`w-3 h-3 rounded-full ${
                event.status === incident.status
                  ? 'bg-blue-600 ring-4 ring-blue-100'
                  : 'bg-gray-300'
              }`}
            />
            {index < events.length - 1 && (
              <div className="w-0.5 h-8 bg-gray-200 mt-1" />
            )}
          </div>
          <div className="flex-1 pb-4">
            <p className="text-sm font-medium text-gray-900">{event.label}</p>
            <p className="text-xs text-gray-500">{formatDateTime(event.time)}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
