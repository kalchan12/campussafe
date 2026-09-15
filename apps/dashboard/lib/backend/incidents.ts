import { supabase } from './supabase';
import type { Incident, IncidentFilter, IncidentCommunityResponse } from '@/types/incident';

export async function getIncidents(filter?: IncidentFilter): Promise<Incident[]> {
  let query = supabase
    .from('incidents')
    .select('*')
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
  if (error) throw error;
  return data || [];
}

export async function getIncidentById(id: string): Promise<Incident | null> {
  const { data, error } = await supabase
    .from('incidents')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data;
}

export async function updateIncidentStatus(
  id: string,
  status: Incident['status']
): Promise<Incident> {
  const { data, error } = await supabase
    .from('incidents')
    .update({ status, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function assignResponder(
  incidentId: string,
  responderId: string
): Promise<Incident> {
  const { data, error } = await supabase
    .from('incidents')
    .update({
      assigned_responder_id: responderId,
      status: 'assigned',
      assigned_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', incidentId)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getActiveIncidentsCount(): Promise<number> {
  const { count, error } = await supabase
    .from('incidents')
    .select('*', { count: 'exact', head: true })
    .not('status', 'in', '(resolved,cancelled)');

  if (error) throw error;
  return count || 0;
}

export async function deleteIncident(id: string): Promise<void> {
  const { error } = await supabase
    .from('incidents')
    .delete()
    .eq('id', id);

  if (error) throw error;
}

export async function getCommunityResponses(incidentId: string): Promise<IncidentCommunityResponse[]> {
  const { data, error } = await supabase
    .from('incident_community_responses')
    .select('*')
    .eq('incident_id', incidentId)
    .order('created_at', { ascending: true });

  if (error) throw error;
  return data || [];
}

export async function addCommunityResponse(
  response: Omit<IncidentCommunityResponse, 'id' | 'created_at'>
): Promise<IncidentCommunityResponse> {
  const { data, error } = await supabase
    .from('incident_community_responses')
    .insert({
      incident_id: response.incident_id,
      responder_id: response.responder_id || null,
      responder_name: response.responder_name || 'Community Member',
      response_type: response.response_type,
      message: response.message,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

