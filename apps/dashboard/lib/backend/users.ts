import { supabase } from './supabase';
import type { User, UserFilter, UserRole } from '@/types/user';

export async function getUsers(filter?: UserFilter): Promise<User[]> {
  let query = supabase
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: false });

  if (filter?.role?.length) {
    query = query.in('role', filter.role);
  }
  if (filter?.campus_block) {
    query = query.eq('campus_block', filter.campus_block);
  }
  if (filter?.is_active !== undefined) {
    query = query.eq('is_active', filter.is_active);
  }
  if (filter?.search) {
    query = query.or(
      `full_name.ilike.%${filter.search}%,email.ilike.%${filter.search}%,phone.ilike.%${filter.search}%`
    );
  }

  const { data, error } = await query;
  if (error) throw error;
  return data || [];
}

export async function getUserById(id: string): Promise<User | null> {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data;
}

export async function updateUserRole(id: string, role: UserRole): Promise<User> {
  const { data, error } = await supabase
    .from('profiles')
    .update({ role, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function toggleUserActive(id: string, isActive: boolean): Promise<User> {
  const { data, error } = await supabase
    .from('profiles')
    .update({ is_active: isActive, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getTotalUsersCount(): Promise<number> {
  const { count, error } = await supabase
    .from('profiles')
    .select('*', { count: 'exact', head: true });

  if (error) throw error;
  return count || 0;
}
