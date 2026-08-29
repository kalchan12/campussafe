export type UserRole = 'student' | 'medical_responder' | 'security_responder' | 'operator' | 'administrator' | 'staff';

export interface User {
  id: string;
  email: string;
  full_name: string;
  phone?: string;
  role: UserRole;
  campus_block?: string;
  emergency_info?: string;
  is_active?: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserFilter {
  role?: UserRole[];
  campus_block?: string;
  is_active?: boolean;
  search?: string;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export const USER_ROLE_LABELS: Record<UserRole, string> = {
  student: 'Student',
  staff: 'Staff',
  medical_responder: 'Medical Responder',
  security_responder: 'Security Responder',
  operator: 'EOC Operator',
  administrator: 'System Administrator',
};

export const USER_ROLE_COLORS: Record<UserRole, string> = {
  student: 'bg-blue-100 text-blue-800 border-blue-200',
  staff: 'bg-teal-100 text-teal-800 border-teal-200',
  medical_responder: 'bg-red-100 text-red-800 border-red-200',
  security_responder: 'bg-amber-100 text-amber-800 border-amber-200',
  operator: 'bg-indigo-100 text-indigo-800 border-indigo-200',
  administrator: 'bg-purple-100 text-purple-800 border-purple-200',
};

