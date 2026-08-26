import type { Incident } from '@/types/incident';
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
    <div className="space-y-4 border-l-2 border-outline-variant ml-2 pl-4">
      {events.map((event, index) => (
        <div key={index} className="relative">
          <span
            className={`absolute -left-[21px] top-1 w-2.5 h-2.5 rounded-full border-2 border-surface-container-lowest ${
              event.status === incident.status
                ? 'bg-primary'
                : 'bg-outline-variant'
            }`}
          />
          <p className="font-body-md text-body-md text-on-surface font-medium">{event.label}</p>
          <p className="font-technical-sm text-technical-sm text-on-surface-variant">{formatDateTime(event.time)}</p>
        </div>
      ))}
    </div>
  );
}
