import { supabase } from './supabase';
import type { Responder, ResponderFilter } from '@/types/responder';

export async function getResponders(filter?: ResponderFilter): Promise<Responder[]> {
  let query = supabase
    .from('responders')
    .select('*')
    .order('name');

  if (filter?.status?.length) {
    query = query.in('status', filter.status);
  }
  if (filter?.role?.length) {
    query = query.in('role', filter.role);
  }
  if (filter?.search) {
    query = query.or(`name.ilike.%${filter.search}%,email.ilike.%${filter.search}%`);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data || [];
}

export async function getResponderById(id: string): Promise<Responder | null> {
  const { data, error } = await supabase
    .from('responders')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data;
}

export async function updateResponderStatus(
  id: string,
  status: Responder['status']
): Promise<Responder> {
  const { data, error } = await supabase
    .from('responders')
    .update({ status, last_active: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getAvailableRespondersCount(): Promise<number> {
  const { count, error } = await supabase
    .from('responders')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'available');

  if (error) throw error;
  return count || 0;
}
