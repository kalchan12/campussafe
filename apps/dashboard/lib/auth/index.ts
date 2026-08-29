import type { User, UserRole } from '@/types/user';

export const DEMO_USERS: Record<string, { password: string; user: User }> = {
  'operator@campus.edu': {
    password: 'password',
    user: {
      id: 'user-010',
      email: 'operator@campus.edu',
      full_name: 'Dashboard Operator',
      role: 'operator',
      campus_block: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
  },
  'admin@campus.edu': {
    password: 'password',
    user: {
      id: 'user-011',
      email: 'admin@campus.edu',
      full_name: 'Campus Administrator',
      role: 'administrator',
      campus_block: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
  },
  'responder@campus.edu': {
    password: 'password',
    user: {
      id: 'resp-001',
      email: 'responder@campus.edu',
      full_name: 'Dr. Sarah Chen',
      role: 'medical_responder',
      campus_block: 'health_center',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
  },
};

export async function signIn(email: string, password: string): Promise<User> {
  const normalizedEmail = email.trim().toLowerCase();
  const normalizedPassword = password.trim();

  const account = DEMO_USERS[normalizedEmail];
  if (account && account.password === normalizedPassword) {
    return account.user;
  }

  // Fallback check for any valid demo email
  if (normalizedEmail === 'operator@campus.edu' && normalizedPassword === 'password') {
    return DEMO_USERS['operator@campus.edu'].user;
  }

  throw new Error('Invalid credentials');
}

export async function signOut(): Promise<void> {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('campussafe_user');
    document.cookie = 'campussafe_session=; path=/; max-age=0; SameSite=Lax';
  }
}

export async function getCurrentUser(): Promise<User | null> {
  if (typeof window === 'undefined') return null;
  const stored = localStorage.getItem('campussafe_user');
  if (stored) {
    try {
      return JSON.parse(stored);
    } catch {
      return null;
    }
  }
  return null;
}

export function saveUser(user: User): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem('campussafe_user', JSON.stringify(user));
    document.cookie = `campussafe_session=${encodeURIComponent(JSON.stringify(user))}; path=/; max-age=86400; SameSite=Lax`;
  }
}

export function hasPermission(user: User | null, requiredRole: string[]): boolean {
  if (!user) return false;
  return requiredRole.includes(user.role);
}

