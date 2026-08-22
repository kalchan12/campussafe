import type { User, AuthState } from '@/types/user';

const MOCK_USER: User = {
  id: 'user-010',
  email: 'operator@campus.edu',
  full_name: 'Dashboard Operator',
  role: 'operator',
  campus_block: 'admin',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
};

export async function signIn(email: string, password: string): Promise<User> {
  // Mock authentication - in production, use Supabase Auth
  if (email === 'operator@campus.edu' && password === 'password') {
    return MOCK_USER;
  }
  throw new Error('Invalid credentials');
}

export async function signOut(): Promise<void> {
  // Mock sign out
  localStorage.removeItem('campussafe_user');
}

export async function getCurrentUser(): Promise<User | null> {
  // Mock getting current user
  const stored = localStorage.getItem('campussafe_user');
  if (stored) {
    return JSON.parse(stored);
  }
  return null;
}

export function saveUser(user: User): void {
  localStorage.setItem('campussafe_user', JSON.stringify(user));
}

export function hasPermission(user: User | null, requiredRole: string[]): boolean {
  if (!user) return false;
  return requiredRole.includes(user.role);
}
