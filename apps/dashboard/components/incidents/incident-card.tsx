import type { Incident } from '@/types/incident';
import {
  INCIDENT_STATUS_LABELS,
  INCIDENT_STATUS_COLORS,
  EMERGENCY_TYPE_LABELS,
  EMERGENCY_TYPE_COLORS,
} from '@/types/incident';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface IncidentCardProps {
  incident: Incident;
  onClick?: () => void;
}

export function IncidentCard({ incident, onClick }: IncidentCardProps) {
  return (
    <div
      onClick={onClick}
      className="bg-white border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:shadow-md transition-all cursor-pointer"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          <Badge className={EMERGENCY_TYPE_COLORS[incident.type]}>
            {EMERGENCY_TYPE_LABELS[incident.type]}
          </Badge>
          <Badge className={INCIDENT_STATUS_COLORS[incident.status]}>
            {INCIDENT_STATUS_LABELS[incident.status]}
          </Badge>
        </div>
        <span className="text-xs text-gray-500">{timeAgo(incident.created_at)}</span>
      </div>

      <p className="text-sm text-gray-900 font-medium mb-2 line-clamp-2">
        {incident.description || 'No description'}
      </p>

      <div className="flex items-center gap-4 text-xs text-gray-500">
        {incident.location_description && (
          <span className="flex items-center gap-1">
            📍 {incident.location_description}
          </span>
        )}
        {incident.assigned_responder_name && (
          <span className="flex items-center gap-1">
            👤 {incident.assigned_responder_name}
          </span>
        )}
      </div>

      <div className="mt-3 flex items-center justify-between">
        <span className="text-xs font-medium text-gray-600">
          Priority {incident.priority}
        </span>
        {incident.campus_block && (
          <span className="text-xs text-gray-500 capitalize">
            {incident.campus_block.replace('_', ' ')}
          </span>
        )}
      </div>
    </div>
  );
}
