import { supabase } from './supabase';
import type { Device, DeviceFilter } from '@/types/device';

export async function getDevices(filter?: DeviceFilter): Promise<Device[]> {
  let query = supabase
    .from('devices')
    .select('*')
    .order('name');

  if (filter?.type?.length) {
    query = query.in('type', filter.type);
  }
  if (filter?.status?.length) {
    query = query.in('status', filter.status);
  }
  if (filter?.search) {
    query = query.or(`name.ilike.%${filter.search}%,device_id.ilike.%${filter.search}%`);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data || [];
}

export async function getDeviceById(id: string): Promise<Device | null> {
  const { data, error } = await supabase
    .from('devices')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data;
}

export async function getOnlineDevicesCount(): Promise<number> {
  const { count, error } = await supabase
    .from('devices')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'online');

  if (error) throw error;
  return count || 0;
}

export async function getDeviceEvents(
  deviceId: string,
  limit: number = 50
): Promise<Device['last_event_type'][]> {
  const { data, error } = await supabase
    .from('device_events')
    .select('*')
    .eq('device_id', deviceId)
    .order('timestamp', { ascending: false })
    .limit(limit);

  if (error) throw error;
  return data || [];
}
