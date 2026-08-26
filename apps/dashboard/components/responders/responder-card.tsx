import type { Responder } from '@/types/responder';
import { RESPONDER_STATUS_LABELS, RESPONDER_STATUS_COLORS } from '@/types/responder';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface ResponderCardProps {
  responder: Responder;
  onClick?: () => void;
}

export function ResponderCard({ responder, onClick }: ResponderCardProps) {
  const statusVariant = responder.status === 'available' ? 'success' as const
    : responder.status === 'responding' ? 'error' as const
    : responder.status === 'offline' ? 'default' as const
    : 'warning' as const;

  return (
    <div
      onClick={onClick}
      className="bg-surface-container-lowest border border-outline-variant rounded-lg p-4 hover:border-primary/30 hover:shadow-md transition-all cursor-pointer"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary-fixed rounded-full flex items-center justify-center">
            <span className="font-label-md text-label-md text-primary font-bold">
              {responder.name.split(' ').map(n => n[0]).join('')}
            </span>
          </div>
          <div>
            <p className="font-body-md text-body-md text-on-surface font-medium">{responder.name}</p>
            <p className="font-technical-sm text-technical-sm text-on-surface-variant">{responder.email}</p>
          </div>
        </div>
        <Badge variant={statusVariant}>
          {RESPONDER_STATUS_LABELS[responder.status]}
        </Badge>
      </div>

      <div className="space-y-2 font-technical-sm text-technical-sm text-on-surface-variant">
        <div className="flex items-center justify-between">
          <span>Role</span>
          <span className="font-medium text-on-surface capitalize">{responder.role}</span>
        </div>
        {responder.current_incident_type && (
          <div className="flex items-center justify-between">
            <span>Current Incident</span>
            <span className="font-medium text-on-surface capitalize">{responder.current_incident_type}</span>
          </div>
        )}
        <div className="flex items-center justify-between">
          <span>Last Active</span>
          <span className="font-medium text-on-surface">{timeAgo(responder.last_active)}</span>
        </div>
      </div>
    </div>
  );
}
