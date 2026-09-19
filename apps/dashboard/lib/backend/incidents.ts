import { supabase } from './supabase';
import type { Incident, IncidentFilter, IncidentCommunityResponse, EmergencyType } from '@/types/incident';

export const DEFAULT_CAMPUS_INCIDENTS: Incident[] = [
  {
    id: 'a1111111-0000-0000-0000-000000000001',
    type: 'medical',
    status: 'received',
    priority: 1,
    reporter_id: 'rep-001',
    reporter_name: 'Dr. Helen (Faculty)',
    reporter_phone: '+251-911-554433',
    latitude: 8.5582,
    longitude: 39.2895,
    campus_block: 'Engineering Complex Block B',
    location_description: 'Engineering Block B, 2nd Floor Hallway',
    description: 'Student experiencing acute respiratory distress / asthma attack.',
    created_at: new Date(Date.now() - 12 * 60 * 1000).toISOString(),
    updated_at: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
  },
  {
    id: 'a2222222-0000-0000-0000-000000000002',
    type: 'security',
    status: 'assigned',
    priority: 2,
    reporter_id: 'rep-002',
    reporter_name: 'Yared Kebede (Student)',
    reporter_phone: '+251-922-667788',
    assigned_responder_id: '22222222-2222-2222-2222-222222222222',
    assigned_responder_name: 'Security Officer Bob (Patrol North)',
    latitude: 8.5620,
    longitude: 39.2925,
    campus_block: 'North Residential Halls',
    location_description: 'Near North Residential Halls Gate 2',
    description: 'Suspicious individual loitering and tampering with perimeter gate latch.',
    created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    updated_at: new Date(Date.now() - 18 * 60 * 1000).toISOString(),
    assigned_at: new Date(Date.now() - 20 * 60 * 1000).toISOString(),
  },
  {
    id: 'a3333333-0000-0000-0000-000000000003',
    type: 'fire',
    status: 'created',
    priority: 1,
    reporter_id: 'rep-003',
    reporter_name: 'Lab Tech Samuel',
    reporter_phone: '+251-933-778899',
    latitude: 8.5550,
    longitude: 39.2880,
    campus_block: 'Applied Science Complex',
    location_description: 'Chemistry Lab Room 304',
    description: 'Dense chemical smoke detected from heating apparatus. Alarm triggered.',
    created_at: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
    updated_at: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
  },
  {
    id: 'a4444444-0000-0000-0000-000000000004',
    type: 'accident',
    status: 'responding',
    priority: 3,
    reporter_id: 'rep-004',
    reporter_name: 'Meron Tadesse',
    reporter_phone: '+251-944-889900',
    assigned_responder_id: '33333333-3333-3333-3333-333333333333',
    assigned_responder_name: 'Security Officer Charlie (Main Gate)',
    latitude: 8.5540,
    longitude: 39.2935,
    campus_block: 'Student Union Quad',
    location_description: 'Main pedestrian pathway near Student Cafeteria',
    description: 'Minor electric scooter and bicycle collision. Mild knee abrasion reported.',
    created_at: new Date(Date.now() - 40 * 60 * 1000).toISOString(),
    updated_at: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
    assigned_at: new Date(Date.now() - 35 * 60 * 1000).toISOString(),
    responded_at: new Date(Date.now() - 28 * 60 * 1000).toISOString(),
  },
];

// In-memory fallback stores for demo/offline resilience
let inMemoryIncidents: Incident[] = [...DEFAULT_CAMPUS_INCIDENTS];
const inMemoryCommunityResponses = new Map<string, IncidentCommunityResponse[]>();

function applyIncidentFilter(list: Incident[], filter?: IncidentFilter): Incident[] {
  let filtered = [...list];
  if (filter?.status?.length) {
    filtered = filtered.filter((i) => filter.status!.includes(i.status));
  }
  if (filter?.type?.length) {
    filtered = filtered.filter((i) => filter.type!.includes(i.type));
  }
  if (filter?.priority?.length) {
    filtered = filtered.filter((i) => filter.priority!.includes(i.priority));
  }
  if (filter?.campus_block) {
    filtered = filtered.filter((i) => i.campus_block === filter.campus_block);
  }
  if (filter?.search) {
    const s = filter.search.toLowerCase();
    filtered = filtered.filter(
      (i) =>
        i.id.toLowerCase().includes(s) ||
        (i.description && i.description.toLowerCase().includes(s)) ||
        (i.location_description && i.location_description.toLowerCase().includes(s)) ||
        (i.reporter_name && i.reporter_name.toLowerCase().includes(s))
    );
  }
  return filtered;
}

export async function getIncidents(filter?: IncidentFilter): Promise<Incident[]> {
  try {
    let query = supabase
      .from('incidents')
      .select('*, profiles!reporter_id(full_name, email, phone)')
      .order('created_at', { ascending: false });

    if (filter?.status?.length) {
      query = query.in('status', filter.status);
    }
    if (filter?.type?.length) {
      query = query.in('type', filter.type);
    }
    if (filter?.priority?.length) {
      query = query.in('priority', filter.priority);
    }
    if (filter?.date_from) {
      query = query.gte('created_at', filter.date_from);
    }
    if (filter?.date_to) {
      query = query.lte('created_at', filter.date_to);
    }
    if (filter?.campus_block) {
      query = query.eq('campus_block', filter.campus_block);
    }
    if (filter?.search) {
      query = query.or(`description.ilike.%${filter.search}%,location_description.ilike.%${filter.search}%`);
    }

    const { data, error } = await query;
    if (error || !data || data.length === 0) {
      return applyIncidentFilter(inMemoryIncidents, filter);
    }

    return data.map((row: any) => ({
      ...row,
      reporter_name: row.profiles?.full_name || row.reporter_name || 'Campus Member',
      reporter_email: row.profiles?.email || row.reporter_email,
      reporter_phone: row.profiles?.phone || row.reporter_phone,
    }));
  } catch {
    return applyIncidentFilter(inMemoryIncidents, filter);
  }
}

export async function getIncidentById(id: string): Promise<Incident | null> {
  try {
    const { data, error } = await supabase
      .from('incidents')
      .select('*, profiles!reporter_id(full_name, email, phone)')
      .eq('id', id)
      .single();

    if (error || !data) {
      const fallback = inMemoryIncidents.find((i) => i.id === id) || null;
      return fallback;
    }

    return {
      ...data,
      reporter_name: data.profiles?.full_name || data.reporter_name || 'Campus Member',
      reporter_email: data.profiles?.email || data.reporter_email,
      reporter_phone: data.profiles?.phone || data.reporter_phone,
    };
  } catch {
    return inMemoryIncidents.find((i) => i.id === id) || null;
  }
}

export async function updateIncidentStatus(
  id: string,
  status: Incident['status']
): Promise<Incident> {
  const timestamp = new Date().toISOString();

  // Always update in-memory state
  inMemoryIncidents = inMemoryIncidents.map((i) =>
    i.id === id ? { ...i, status, updated_at: timestamp } : i
  );

  try {
    const { data, error } = await supabase
      .from('incidents')
      .update({ status, updated_at: timestamp })
      .eq('id', id)
      .select()
      .single();

    if (error || !data) {
      const found = inMemoryIncidents.find((i) => i.id === id);
      return (
        found || {
          id,
          status,
          type: 'other',
          priority: 2,
          reporter_id: 'unknown',
          latitude: 8.5565,
          longitude: 39.2910,
          created_at: timestamp,
          updated_at: timestamp,
        }
      );
    }
    return data;
  } catch {
    const found = inMemoryIncidents.find((i) => i.id === id);
    return (
      found || {
        id,
        status,
        type: 'other',
        priority: 2,
        reporter_id: 'unknown',
        latitude: 8.5565,
        longitude: 39.2910,
        created_at: timestamp,
        updated_at: timestamp,
      }
    );
  }
}

export async function assignResponder(
  incidentId: string,
  responderId: string,
  responderName?: string
): Promise<Incident> {
  const timestamp = new Date().toISOString();

  // Always update in-memory cache
  inMemoryIncidents = inMemoryIncidents.map((i) =>
    i.id === incidentId
      ? {
          ...i,
          assigned_responder_id: responderId,
          assigned_responder_name: responderName || i.assigned_responder_name || 'Assigned Responder',
          status: 'assigned',
          assigned_at: timestamp,
          updated_at: timestamp,
        }
      : i
  );

  try {
    const isUuid = /^[0-9a-fA-F-]{36}$/.test(responderId);
    if (isUuid) {
      await supabase
        .from('incidents')
        .update({
          assigned_responder_id: responderId,
          status: 'assigned',
          assigned_at: timestamp,
          updated_at: timestamp,
        })
        .eq('id', incidentId);
    }
  } catch {
    // Graceful fallback without crashing
  }

  const updated = inMemoryIncidents.find((i) => i.id === incidentId);
  return (
    updated || {
      id: incidentId,
      assigned_responder_id: responderId,
      assigned_responder_name: responderName || 'Assigned Responder',
      status: 'assigned',
      type: 'other',
      priority: 2,
      reporter_id: 'unknown',
      latitude: 8.5565,
      longitude: 39.2910,
      created_at: timestamp,
      updated_at: timestamp,
    }
  );
}

export async function getActiveIncidentsCount(): Promise<number> {
  try {
    const { count, error } = await supabase
      .from('incidents')
      .select('*', { count: 'exact', head: true })
      .not('status', 'in', '(resolved,cancelled)');

    if (error || count === null || count === 0) {
      return inMemoryIncidents.filter((i) => !['resolved', 'cancelled'].includes(i.status)).length;
    }
    return count;
  } catch {
    return inMemoryIncidents.filter((i) => !['resolved', 'cancelled'].includes(i.status)).length;
  }
}

export async function deleteIncident(id: string): Promise<void> {
  inMemoryIncidents = inMemoryIncidents.filter((i) => i.id !== id);
  try {
    await supabase.from('incidents').delete().eq('id', id);
  } catch {
    // Gracefully ignore error on mock/unconnected deletion
  }
}

export async function getCommunityResponses(incidentId: string): Promise<IncidentCommunityResponse[]> {
  try {
    const { data, error } = await supabase
      .from('incident_community_responses')
      .select('*')
      .eq('incident_id', incidentId)
      .order('created_at', { ascending: true });

    if (error || !data) {
      return inMemoryCommunityResponses.get(incidentId) || [];
    }
    return data;
  } catch {
    return inMemoryCommunityResponses.get(incidentId) || [];
  }
}

export async function addCommunityResponse(
  response: Omit<IncidentCommunityResponse, 'id' | 'created_at'>
): Promise<IncidentCommunityResponse> {
  const newRecord: IncidentCommunityResponse = {
    id: `local-${Date.now()}`,
    incident_id: response.incident_id,
    responder_id: response.responder_id,
    responder_name: response.responder_name || 'Operations Dispatch',
    response_type: response.response_type,
    message: response.message,
    created_at: new Date().toISOString(),
  };

  try {
    const { data, error } = await supabase
      .from('incident_community_responses')
      .insert({
        incident_id: response.incident_id,
        responder_id: response.responder_id || null,
        responder_name: response.responder_name || 'Operations Dispatch',
        response_type: response.response_type,
        message: response.message,
      })
      .select()
      .single();

    if (!error && data) {
      return data;
    }
  } catch {
    // Non-fatal
  }

  // Update in-memory
  const existing = inMemoryCommunityResponses.get(response.incident_id) || [];
  inMemoryCommunityResponses.set(response.incident_id, [...existing, newRecord]);
  return newRecord;
}

export function createSimulatedIncident(type: EmergencyType = 'medical'): Incident {
  const id = `inc-${Date.now().toString(36).slice(-6)}`;
  const locations: Record<EmergencyType, { block: string; desc: string; lat: number; lng: number }> = {
    medical: { block: 'Engineering Complex Block B', desc: 'Engineering Block B 1st Floor', lat: 8.5582, lng: 39.2895 },
    security: { block: 'North Residential Halls', desc: 'North Gate perimeter pathway', lat: 8.5620, lng: 39.2925 },
    fire: { block: 'Applied Science Complex', desc: 'Chemistry Lab corridor', lat: 8.5550, lng: 39.2880 },
    accident: { block: 'Student Union Quad', desc: 'Cafeteria entrance steps', lat: 8.5540, lng: 39.2935 },
    other: { block: 'Main Administration', desc: 'Admin EOC plaza', lat: 8.5565, lng: 39.2910 },
  };

  const loc = locations[type] || locations.medical;
  const newInc: Incident = {
    id,
    type,
    status: 'created',
    priority: type === 'medical' || type === 'fire' ? 1 : 2,
    reporter_id: 'user-sim',
    reporter_name: 'Simulated Student Trigger',
    reporter_phone: '+251-911-000000',
    campus_block: loc.block,
    location_description: loc.desc,
    description: `Simulated ${type} emergency event triggered from Dashboard Operator console.`,
    latitude: loc.lat,
    longitude: loc.lng,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  inMemoryIncidents = [newInc, ...inMemoryIncidents];
  return newInc;
}

