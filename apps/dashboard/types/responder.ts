export type ResponderStatus =
  | 'available'
  | 'assigned'
  | 'responding'
  | 'arrived'
  | 'offline';

export type ResponderRole = 'medical' | 'security' | 'operator' | 'admin';

export interface Responder {
  id: string;
  user_id: string;
  name: string;
  email: string;
  phone?: string;
  role: ResponderRole;
  status: ResponderStatus;
  current_incident_id?: string;
  current_incident_type?: string;
  latitude?: number;
  longitude?: number;
  last_location_update?: string;
  last_active: string;
  created_at: string;
}

export interface ResponderFilter {
  status?: ResponderStatus[];
  role?: ResponderRole[];
  search?: string;
}

export const RESPONDER_STATUS_LABELS: Record<ResponderStatus, string> = {
  available: 'Available',
  assigned: 'Assigned',
  responding: 'Responding',
  arrived: 'Arrived',
  offline: 'Offline',
};

export const RESPONDER_ROLE_LABELS: Record<ResponderRole, string> = {
  medical: 'Medical',
  security: 'Security',
  operator: 'Operator',
  admin: 'Admin',
};

export const RESPONDER_STATUS_COLORS: Record<ResponderStatus, string> = {
  available: 'bg-green-100 text-green-800',
  assigned: 'bg-purple-100 text-purple-800',
  responding: 'bg-amber-100 text-amber-800',
  arrived: 'bg-teal-100 text-teal-800',
  offline: 'bg-gray-100 text-gray-500',
};

export const RESPONDER_ROLE_COLORS: Record<ResponderRole, string> = {
  medical: 'bg-red-100 text-red-800',
  security: 'bg-blue-100 text-blue-800',
  operator: 'bg-gray-100 text-gray-800',
  admin: 'bg-purple-100 text-purple-800',
};
