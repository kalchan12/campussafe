import * as backendIncidents from './backend/incidents';
import * as backendResponders from './backend/responders';
import * as backendDevices from './backend/devices';
import * as backendReports from './backend/reports';
import * as mock from './mock';
import { supabase } from './backend/supabase';

import type { Incident, IncidentFilter } from '@/types/incident';
import type { Responder, ResponderFilter } from '@/types/responder';
import type { Device, DeviceFilter } from '@/types/device';
import type { SafetyReport, ReportFilter } from '@/types/report';

export const isSupabaseConfigured = () => {
  return (
    typeof process !== 'undefined' &&
    !!process.env.NEXT_PUBLIC_SUPABASE_URL &&
    !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  );
};

export async function fetchIncidents(filter?: IncidentFilter): Promise<Incident[]> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendIncidents.getIncidents(filter);
      if (data && data.length > 0) return data;
    } catch (err) {
      console.warn('Backend fetchIncidents failed, falling back to mock data:', err);
    }
  }
  return mock.getIncidents(filter);
}

export async function fetchIncidentById(id: string): Promise<Incident | null> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendIncidents.getIncidentById(id);
      if (data) return data;
    } catch (err) {
      console.warn(`Backend fetchIncidentById(${id}) failed:`, err);
    }
  }
  const found = await mock.getIncidentById(id);
  return found ?? null;
}

export async function fetchResponders(filter?: ResponderFilter): Promise<Responder[]> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendResponders.getResponders(filter);
      if (data && data.length > 0) return data;
    } catch (err) {
      console.warn('Backend fetchResponders failed, falling back to mock data:', err);
    }
  }
  return mock.getResponders(filter);
}

export async function fetchDevices(filter?: DeviceFilter): Promise<Device[]> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendDevices.getDevices(filter);
      if (data && data.length > 0) return data;
    } catch (err) {
      console.warn('Backend fetchDevices failed, falling back to mock data:', err);
    }
  }
  return mock.getDevices(filter);
}

export async function fetchReports(filter?: ReportFilter): Promise<SafetyReport[]> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendReports.getReports(filter);
      if (data && data.length > 0) return data;
    } catch (err) {
      console.warn('Backend fetchReports failed, falling back to mock data:', err);
    }
  }
  return mock.getReports(filter);
}

export async function fetchDashboardStats() {
  if (isSupabaseConfigured()) {
    try {
      const [activeIncidents, availableResponders, onlineDevices, pendingReports] =
        await Promise.all([
          backendIncidents.getActiveIncidentsCount(),
          backendResponders.getAvailableRespondersCount(),
          backendDevices.getOnlineDevicesCount(),
          backendReports.getPendingReportsCount(),
        ]);

      return {
        activeIncidents,
        availableResponders,
        onlineDevices,
        pendingReports,
        totalIncidents: activeIncidents,
        totalResponders: availableResponders,
        totalDevices: onlineDevices,
      };
    } catch (err) {
      console.warn('Backend fetchDashboardStats failed, falling back to mock stats:', err);
    }
  }
  return mock.getDashboardStats();
}
