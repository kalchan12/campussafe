import type { Responder } from '@/types/responder';
import { RESPONDER_STATUS_LABELS, RESPONDER_STATUS_COLORS } from '@/types/responder';
import { Badge } from '@/components/ui/badge';
import { timeAgo } from '@/lib/utils';

interface ResponderCardProps {
  responder: Responder;
  onClick?: () => void;
}

export function ResponderCard({ responder, onClick }: ResponderCardProps) {
  return (
    <div
      onClick={onClick}
      className="bg-white border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:shadow-md transition-all cursor-pointer"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
            <span className="text-sm font-medium text-blue-600">
              {responder.name.split(' ').map(n => n[0]).join('')}
            </span>
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{responder.name}</p>
            <p className="text-xs text-gray-500">{responder.email}</p>
          </div>
        </div>
        <Badge className={RESPONDER_STATUS_COLORS[responder.status]}>
          {RESPONDER_STATUS_LABELS[responder.status]}
        </Badge>
      </div>

      <div className="space-y-2 text-xs text-gray-500">
        <div className="flex items-center justify-between">
          <span>Role</span>
          <span className="font-medium text-gray-700 capitalize">{responder.role}</span>
        </div>
        {responder.current_incident_type && (
          <div className="flex items-center justify-between">
            <span>Current Incident</span>
            <span className="font-medium text-gray-700">{responder.current_incident_type}</span>
          </div>
        )}
        <div className="flex items-center justify-between">
          <span>Last Active</span>
          <span className="font-medium text-gray-700">{timeAgo(responder.last_active)}</span>
        </div>
      </div>
    </div>
  );
}
