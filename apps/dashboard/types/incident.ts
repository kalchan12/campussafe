export type IncidentStatus =
  | 'created'
  | 'received'
  | 'assigned'
  | 'responding'
  | 'arrived'
  | 'resolved'
  | 'cancelled'
  | 'escalated'
  | 'unassigned'
  | 'failed';

export type EmergencyType =
  | 'medical'
  | 'security'
  | 'fire'
  | 'accident'
  | 'other';

export type IncidentPriority = 1 | 2 | 3 | 4 | 5;

export interface Incident {
  id: string;
  type: EmergencyType;
  status: IncidentStatus;
  priority: IncidentPriority;
  reporter_id: string;
  reporter_name?: string;
  reporter_email?: string;
  reporter_phone?: string;
  assigned_responder_id?: string;
  assigned_responder_name?: string;
  latitude: number;
  longitude: number;
  location_description?: string;
  campus_block?: string;
  description?: string;
  created_at: string;
  updated_at: string;
  assigned_at?: string;
  responded_at?: string;
  arrived_at?: string;
  resolved_at?: string;
}

export interface IncidentTimelineEvent {
  id: string;
  incident_id: string;
  status: IncidentStatus;
  timestamp: string;
  description?: string;
  actor_id?: string;
  actor_name?: string;
}

export interface IncidentFilter {
  status?: IncidentStatus[];
  type?: EmergencyType[];
  priority?: IncidentPriority[];
  date_from?: string;
  date_to?: string;
  campus_block?: string;
  search?: string;
}

export const INCIDENT_STATUS_LABELS: Record<IncidentStatus, string> = {
  created: 'Created',
  received: 'Received',
  assigned: 'Assigned',
  responding: 'Responding',
  arrived: 'Arrived',
  resolved: 'Resolved',
  cancelled: 'Cancelled',
  escalated: 'Escalated',
  unassigned: 'Unassigned',
  failed: 'Failed',
};

export const EMERGENCY_TYPE_LABELS: Record<EmergencyType, string> = {
  medical: 'Medical',
  security: 'Security',
  fire: 'Fire',
  accident: 'Accident',
  other: 'Other',
};

export const INCIDENT_STATUS_COLORS: Record<IncidentStatus, string> = {
  created: 'bg-gray-100 text-gray-800',
  received: 'bg-blue-100 text-blue-800',
  assigned: 'bg-purple-100 text-purple-800',
  responding: 'bg-amber-100 text-amber-800',
  arrived: 'bg-teal-100 text-teal-800',
  resolved: 'bg-green-100 text-green-800',
  cancelled: 'bg-gray-100 text-gray-500',
  escalated: 'bg-red-100 text-red-800',
  unassigned: 'bg-orange-100 text-orange-800',
  failed: 'bg-red-100 text-red-800',
};

export const EMERGENCY_TYPE_COLORS: Record<EmergencyType, string> = {
  medical: 'bg-red-100 text-red-800',
  security: 'bg-blue-100 text-blue-800',
  fire: 'bg-orange-100 text-orange-800',
  accident: 'bg-yellow-100 text-yellow-800',
  other: 'bg-gray-100 text-gray-800',
};

export type CommunityResponseType =
  | 'offering_assistance'
  | 'escorting_to_safety'
  | 'first_aid_provided'
  | 'eyewitness_report'
  | 'other_assistance';

export interface IncidentCommunityResponse {
  id: string;
  incident_id: string;
  responder_id?: string;
  responder_name?: string;
  response_type: CommunityResponseType;
  message: string;
  created_at: string;
}

export const COMMUNITY_RESPONSE_LABELS: Record<CommunityResponseType, { label: string; icon: string; color: string }> = {
  offering_assistance: { label: 'Assistance Offered', icon: 'handshake', color: 'text-blue-600 bg-blue-50 border-blue-200' },
  escorting_to_safety: { label: 'Escorting to Safety', icon: 'transfer_within_a_station', color: 'text-teal-600 bg-teal-50 border-teal-200' },
  first_aid_provided: { label: 'First Aid Applied', icon: 'medical_services', color: 'text-emerald-600 bg-emerald-50 border-emerald-200' },
  eyewitness_report: { label: 'Eyewitness Report', icon: 'visibility', color: 'text-amber-700 bg-amber-50 border-amber-200' },
  other_assistance: { label: 'Community Assistance', icon: 'volunteer_activism', color: 'text-indigo-600 bg-indigo-50 border-indigo-200' },
};

