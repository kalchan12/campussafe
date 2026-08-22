export type UserRole = 'student' | 'medical_responder' | 'security_responder' | 'operator' | 'administrator';

export interface User {
  id: string;
  email: string;
  full_name: string;
  phone?: string;
  role: UserRole;
  campus_block?: string;
  emergency_info?: string;
  created_at: string;
  updated_at: string;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export const USER_ROLE_LABELS: Record<UserRole, string> = {
  student: 'Student',
  medical_responder: 'Medical Responder',
  security_responder: 'Security Responder',
  operator: 'Operator',
  administrator: 'Administrator',
};

export const USER_ROLE_COLORS: Record<UserRole, string> = {
  student: 'bg-blue-100 text-blue-800',
  medical_responder: 'bg-red-100 text-red-800',
  security_responder: 'bg-orange-100 text-orange-800',
  operator: 'bg-gray-100 text-gray-800',
  administrator: 'bg-purple-100 text-purple-800',
};
