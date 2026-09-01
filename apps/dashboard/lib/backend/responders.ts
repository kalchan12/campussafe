import { supabase } from './supabase';
import type { Responder, ResponderFilter } from '@/types/responder';

export async function getResponders(filter?: ResponderFilter): Promise<Responder[]> {
  let query = supabase
    .from('profiles')
    .select(`
      id,
      full_name,
      email,
      phone,
      role,
      created_at,
      responders (
        id,
        availability,
        current_incident_id,
        latitude,
        longitude,
        last_location_update
      )
    `)
    .in('role', ['medical_responder', 'security_responder']);

  const { data, error } = await query;
  if (error) throw error;

  let mapped = (data || []).map((profile: any) => {
    // Left join yields an array of responder records for this profile. 
    // Usually 0 or 1 record per profile.
    const responderState = profile.responders?.[0] || {};
    
    return {
      id: responderState.id || profile.id, // Fallback to profile id if no responder record exists yet
      user_id: profile.id,
      name: profile.full_name || 'Unknown',
      email: profile.email || '',
      phone: profile.phone || '',
      role: profile.role, // 'medical_responder' or 'security_responder'
      status: responderState.availability || 'offline',
      current_incident_id: responderState.current_incident_id,
      latitude: responderState.latitude,
      longitude: responderState.longitude,
      last_location_update: responderState.last_location_update,
      last_active: responderState.last_location_update,
      created_at: profile.created_at
    };
  });

  if (filter?.status?.length) {
    mapped = mapped.filter(m => filter.status!.includes(m.status));
  }
  
  if (filter?.role?.length) {
    // The UI uses 'medical' and 'security' for filtering
    mapped = mapped.filter(m => 
      filter.role!.some(r => m.role.includes(r))
    );
  }

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
    .from('profiles')
    .select(`
      id,
      full_name,
      email,
      phone,
      role,
      created_at,
      responders (
        id,
        availability,
        current_incident_id,
        latitude,
        longitude,
        last_location_update
      )
    `)
    .eq('id', id)
    .single();

  if (error) throw error;
  if (!data) return null;

  const responderState = data.responders?.[0] || {};

  return {
    id: responderState.id || data.id,
    user_id: data.id,
    name: data.full_name || 'Unknown',
    email: data.email || '',
    phone: data.phone || '',
    role: data.role,
    status: responderState.availability || 'offline',
    current_incident_id: responderState.current_incident_id,
    latitude: responderState.latitude,
    longitude: responderState.longitude,
    last_location_update: responderState.last_location_update,
    last_active: responderState.last_location_update,
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
