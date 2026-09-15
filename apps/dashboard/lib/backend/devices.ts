import { supabase } from './supabase';
import type { Device, DeviceFilter } from '@/types/device';

export async function getDevices(filter?: DeviceFilter): Promise<Device[]> {
  try {
    let query = supabase
      .from('devices')
      .select('*')
      .order('device_id', { ascending: true });

    if (filter?.type?.length) {
      query = query.in('device_type', filter.type);
    }
    if (filter?.status?.length) {
      const wantOnline = filter.status.includes('online');
      const wantOffline = filter.status.includes('offline');
      if (wantOnline && !wantOffline) {
        query = query.eq('is_online', true);
      } else if (wantOffline && !wantOnline) {
        query = query.eq('is_online', false);
      }
    }
    if (filter?.search) {
      query = query.or(`device_id.ilike.%${filter.search}%,campus_block.ilike.%${filter.search}%`);
    }

    const { data, error } = await query;
    if (error) {
      console.warn('devices query error:', error.message);
      return [];
    }

    return (data || []).map((row: any) => ({
      id: row.id,
      device_id: row.device_id,
      type: row.device_type,
      name: `${row.device_id} (${row.campus_block || 'Campus Node'})`,
      location_name: row.campus_block,
      status: row.is_online ? 'online' : 'offline',
      firmware_version: row.firmware_version,
      last_heartbeat: row.last_seen_at,
      created_at: row.created_at,
    }));
  } catch (err) {
    console.warn('Failed to load devices:', err);
    return [];
  }
}

export async function getDeviceById(id: string): Promise<Device | null> {
  try {
    const { data, error } = await supabase
      .from('devices')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) return null;

    return {
      id: data.id,
      device_id: data.device_id,
      type: data.device_type,
      name: `${data.device_id} (${data.campus_block || 'Campus Node'})`,
      location_name: data.campus_block,
      status: data.is_online ? 'online' : 'offline',
      firmware_version: data.firmware_version,
      last_heartbeat: data.last_seen_at,
      created_at: data.created_at,
    };
  } catch {
    return null;
  }
}

export async function getOnlineDevicesCount(): Promise<number> {
  try {
    const { count, error } = await supabase
      .from('devices')
      .select('*', { count: 'exact', head: true })
      .eq('is_online', true);

    if (error) return 0;
    return count || 0;
  } catch {
    return 0;
  }
}

export async function getDeviceEvents(
  deviceId: string,
  limit: number = 50
): Promise<any[]> {
  try {
    const { data, error } = await supabase
      .from('device_events')
      .select('*')
      .eq('device_id', deviceId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) return [];
    return data || [];
  } catch {
    return [];
  }
}
