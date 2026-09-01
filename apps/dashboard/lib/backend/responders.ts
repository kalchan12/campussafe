import { supabase } from './supabase';
import type { Responder, ResponderFilter } from '@/types/responder';

export async function getResponders(filter?: ResponderFilter): Promise<Responder[]> {
  let query = supabase
    .from('responders')
    .select(`
      id,
      user_id,
      type,
      availability,
      current_incident_id,
      latitude,
      longitude,
      last_location_update,
      created_at,
      profiles!inner(
        full_name,
        email,
        phone
      )
    `);

  if (filter?.status?.length) {
    query = query.in('availability', filter.status);
  }
  if (filter?.role?.length) {
    query = query.in('type', filter.role);
  }

  const { data, error } = await query;
  if (error) throw error;

  let mapped = (data || []).map((row: any) => ({
    id: row.id,
    user_id: row.user_id,
    name: row.profiles?.full_name || 'Unknown',
    email: row.profiles?.email || '',
    phone: row.profiles?.phone || '',
    role: row.type,
    status: row.availability,
    current_incident_id: row.current_incident_id,
    latitude: row.latitude,
    longitude: row.longitude,
    last_location_update: row.last_location_update,
    last_active: row.last_location_update,
    created_at: row.created_at
  }));

  if (filter?.search) {
    const s = filter.search.toLowerCase();
    mapped = mapped.filter(m => 
      m.name.toLowerCase().includes(s) || 
      m.email.toLowerCase().includes(s)
    );
  }

  mapped.sort((a, b) => a.name.localeCompare(b.name));
  return mapped;
}

export async function getResponderById(id: string): Promise<Responder | null> {
  const { data, error } = await supabase
    .from('responders')
    .select('*, profiles(full_name, email, phone)')
    .eq('id', id)
    .single();

  if (error) throw error;
  if (!data) return null;

  return {
    id: data.id,
    user_id: data.user_id,
    name: data.profiles?.full_name || 'Unknown',
    email: data.profiles?.email || '',
    phone: data.profiles?.phone || '',
    role: data.type,
    status: data.availability,
    current_incident_id: data.current_incident_id,
    latitude: data.latitude,
    longitude: data.longitude,
    last_location_update: data.last_location_update,
    last_active: data.last_location_update,
    created_at: data.created_at
  };
}

export async function updateResponderStatus(
  id: string,
  status: Responder['status']
): Promise<Responder> {
  const { data, error } = await supabase
    .from('responders')
    .update({ availability: status, last_location_update: new Date().toISOString() })
    .eq('id', id)
    .select('*, profiles(full_name, email, phone)')
    .single();

  if (error) throw error;

  return {
    id: data.id,
    user_id: data.user_id,
    name: data.profiles?.full_name || 'Unknown',
    email: data.profiles?.email || '',
    phone: data.profiles?.phone || '',
    role: data.type,
    status: data.availability,
    current_incident_id: data.current_incident_id,
    latitude: data.latitude,
    longitude: data.longitude,
    last_location_update: data.last_location_update,
    last_active: data.last_location_update,
    created_at: data.created_at
  };
}

export async function getAvailableRespondersCount(): Promise<number> {
  const { count, error } = await supabase
    .from('responders')
    .select('*', { count: 'exact', head: true })
    .eq('availability', 'available');

  if (error) throw error;
  return count || 0;
}
