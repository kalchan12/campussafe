import type { Incident } from '@/types/incident';
import {
  INCIDENT_STATUS_LABELS,
  EMERGENCY_TYPE_LABELS,
} from '@/types/incident';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface IncidentCardProps {
  incident: Incident;
  onClick?: () => void;
}

export function IncidentCard({ incident, onClick }: IncidentCardProps) {
  const severityVariant = incident.priority === 1 ? 'critical' as const : incident.priority === 2 ? 'high' as const : 'medium' as const;
  const statusVariant = ['responding', 'created'].includes(incident.status) ? 'error' as const : 'info' as const;

  return (
    <div
      onClick={onClick}
      className="bg-surface-container-lowest border border-outline-variant rounded-lg p-4 hover:border-primary/30 hover:shadow-md transition-all cursor-pointer"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          <Badge variant={severityVariant}>
            {incident.priority === 1 ? 'Critical' : incident.priority === 2 ? 'High' : 'Medium'}
          </Badge>
          <Badge variant={statusVariant}>
            {INCIDENT_STATUS_LABELS[incident.status]}
          </Badge>
        </div>
        <span className="font-technical-sm text-technical-sm text-on-surface-variant">{timeAgo(incident.created_at)}</span>
      </div>

      <p className="font-body-md text-body-md text-on-surface font-medium mb-2 line-clamp-2">
        {incident.description || 'No description'}
      </p>

      <div className="flex items-center gap-4 font-technical-sm text-technical-sm text-on-surface-variant">
        {incident.location_description && (
          <span className="flex items-center gap-1">
            <span className="material-symbols-outlined text-sm">location_on</span>
            {incident.location_description}
          </span>
        )}
        {incident.assigned_responder_name && (
          <span className="flex items-center gap-1">
            <span className="material-symbols-outlined text-sm">person</span>
            {incident.assigned_responder_name}
          </span>
        )}
      </div>

      <div className="mt-3 flex items-center justify-between">
        <span className="font-technical-sm text-technical-sm text-on-surface-variant">
          {incident.id.toUpperCase()}
        </span>
        {incident.campus_block && (
          <span className="font-technical-sm text-technical-sm text-on-surface-variant capitalize">
            {incident.campus_block.replace('_', ' ')}
          </span>
        )}
      </div>
    </div>
  );
}
