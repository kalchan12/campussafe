import { supabase } from './supabase';
import type { Responder, ResponderFilter } from '@/types/responder';

export const DEFAULT_CAMPUS_RESPONDERS: Responder[] = [
  {
    id: '11111111-1111-1111-1111-111111111111',
    user_id: '11111111-1111-1111-1111-111111111111',
    name: 'Medical Responder Alex (Medic 1)',
    email: 'med1@campus.edu',
    phone: '+251-911-234567',
    role: 'medical',
    status: 'available',
    latitude: 8.5595,
    longitude: 39.2940,
    last_location_update: new Date().toISOString(),
    last_active: new Date().toISOString(),
    created_at: new Date().toISOString(),
  },
  {
    id: '22222222-2222-2222-2222-222222222222',
    user_id: '22222222-2222-2222-2222-222222222222',
    name: 'Security Officer Bob (Patrol North)',
    email: 'sec1@campus.edu',
    phone: '+251-922-345678',
    role: 'security',
    status: 'available',
    latitude: 8.5620,
    longitude: 39.2925,
    last_location_update: new Date().toISOString(),
    last_active: new Date().toISOString(),
    created_at: new Date().toISOString(),
  },
  {
    id: '33333333-3333-3333-3333-333333333333',
    user_id: '33333333-3333-3333-3333-333333333333',
    name: 'Security Officer Charlie (Main Gate)',
    email: 'sec2@campus.edu',
    phone: '+251-933-456789',
    role: 'security',
    status: 'available',
    latitude: 8.5515,
    longitude: 39.2950,
    last_location_update: new Date().toISOString(),
    last_active: new Date().toISOString(),
    created_at: new Date().toISOString(),
  },
  {
    id: '44444444-4444-4444-4444-444444444444',
    user_id: '44444444-4444-4444-4444-444444444444',
    name: 'Rapid Medic Sara (Medic 2)',
    email: 'med2@campus.edu',
    phone: '+251-944-567890',
    role: 'medical',
    status: 'available',
    latitude: 8.5565,
    longitude: 39.2910,
    last_location_update: new Date().toISOString(),
    last_active: new Date().toISOString(),
    created_at: new Date().toISOString(),
  },
  {
    id: '55555555-5555-5555-5555-555555555555',
    user_id: '55555555-5555-5555-5555-555555555555',
    name: 'Security Officer Dawit (Engineering Patrol)',
    email: 'sec3@campus.edu',
    phone: '+251-955-678901',
    role: 'security',
    status: 'available',
    latitude: 8.5582,
    longitude: 39.2895,
    last_location_update: new Date().toISOString(),
    last_active: new Date().toISOString(),
    created_at: new Date().toISOString(),
  },
];

export async function getResponders(filter?: ResponderFilter): Promise<Responder[]> {
  let mapped: Responder[] = [];

  try {
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
      .in('role', ['medical_responder', 'security_responder']);

    if (error) {
      console.warn('Could not fetch responders from Supabase, using campus seeds:', error.message);
      mapped = [...DEFAULT_CAMPUS_RESPONDERS];
    } else if (!data || data.length === 0) {
      mapped = [...DEFAULT_CAMPUS_RESPONDERS];
    } else {
      mapped = data.map((profile: any, idx: number) => {
        const responderState = profile.responders?.[0] || {};
        const fallbackSeed = DEFAULT_CAMPUS_RESPONDERS[idx % DEFAULT_CAMPUS_RESPONDERS.length];
        const role = profile.role?.includes('medical') ? 'medical' : 'security';

        return {
          id: responderState.id || profile.id,
          user_id: profile.id,
          name: profile.full_name || fallbackSeed.name,
          email: profile.email || fallbackSeed.email,
          phone: profile.phone || fallbackSeed.phone,
          role: role as Responder['role'],
          status: (responderState.availability || 'available') as Responder['status'],
          current_incident_id: responderState.current_incident_id,
          latitude: responderState.latitude ?? fallbackSeed.latitude,
          longitude: responderState.longitude ?? fallbackSeed.longitude,
          last_location_update: responderState.last_location_update || new Date().toISOString(),
          last_active: responderState.last_location_update || new Date().toISOString(),
          created_at: profile.created_at || new Date().toISOString(),
        };
      });
    }
  } catch (err) {
    console.warn('Failed to query responders, falling back to campus defaults:', err);
    mapped = [...DEFAULT_CAMPUS_RESPONDERS];
  }

  if (filter?.status?.length) {
    mapped = mapped.filter((m) => filter.status!.includes(m.status));
  }

  if (filter?.role?.length) {
    mapped = mapped.filter((m) =>
      filter.role!.some((r) => m.role.includes(r))
    );
  }

  if (filter?.search) {
    const s = filter.search.toLowerCase();
    mapped = mapped.filter(
      (m) =>
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
  try {
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
      created_at: data.created_at,
    };
  } catch {
    const fallback =
      DEFAULT_CAMPUS_RESPONDERS.find((r) => r.id === id) || DEFAULT_CAMPUS_RESPONDERS[0];
    return {
      ...fallback,
      id,
      status,
      last_location_update: new Date().toISOString(),
      last_active: new Date().toISOString(),
    };
  }
}

export async function updateResponderLocation(
  id: string,
  latitude: number,
  longitude: number,
  status?: Responder['status'],
  currentIncidentId?: string
): Promise<void> {
  try {
    const updatePayload: Record<string, any> = {
      latitude,
      longitude,
      last_location_update: new Date().toISOString(),
    };
    if (status) updatePayload.availability = status;
    if (currentIncidentId !== undefined) {
      updatePayload.current_incident_id = currentIncidentId;
    }

    await supabase.from('responders').update(updatePayload).eq('id', id);
  } catch (err) {
    console.warn('Failed to update responder location in Supabase:', err);
  }
}

export async function getAvailableRespondersCount(): Promise<number> {
  try {
    const { count, error } = await supabase
      .from('responders')
      .select('*', { count: 'exact', head: true })
      .eq('availability', 'available');

    if (error) return 0;
    return count || 0;
  } catch (err) {
    return 0;
  }
}
