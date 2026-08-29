import * as backendIncidents from './backend/incidents';
import * as backendResponders from './backend/responders';
import * as backendDevices from './backend/devices';
import * as backendReports from './backend/reports';
import * as backendUsers from './backend/users';
import * as mock from './mock';
import { supabase } from './backend/supabase';

import type { Incident, IncidentFilter } from '@/types/incident';
import type { Responder, ResponderFilter } from '@/types/responder';
import type { Device, DeviceFilter } from '@/types/device';
import type { SafetyReport, ReportFilter } from '@/types/report';
import type { User, UserFilter, UserRole } from '@/types/user';

export const isSupabaseConfigured = () => {
  return (
    typeof process !== 'undefined' &&
    !!process.env.NEXT_PUBLIC_SUPABASE_URL &&
    !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY &&
    process.env.NEXT_PUBLIC_SUPABASE_URL !== 'https://placeholder.supabase.co' &&
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY !== 'placeholder_key'
  );
};

export async function fetchUsers(filter?: UserFilter): Promise<User[]> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendUsers.getUsers(filter);
      if (data && data.length > 0) return data;
    } catch (err) {
      console.warn('Backend fetchUsers failed, falling back to mock data:', err);
    }
  }
  return mock.getUsers(filter);
}

export async function fetchUserById(id: string): Promise<User | null> {
  if (isSupabaseConfigured()) {
    try {
      const data = await backendUsers.getUserById(id);
      if (data) return data;
    } catch (err) {
      console.warn(`Backend fetchUserById(${id}) failed:`, err);
    }
  }
  const found = await mock.getUserById(id);
  return found ?? null;
}

export async function updateUserRole(id: string, role: UserRole): Promise<User | null> {
  if (isSupabaseConfigured()) {
    try {
      return await backendUsers.updateUserRole(id, role);
    } catch (err) {
      console.warn(`Backend updateUserRole(${id}) failed:`, err);
    }
  }
  return mock.updateUserRole(id, role);
}

export async function toggleUserActive(id: string, isActive: boolean): Promise<User | null> {
  if (isSupabaseConfigured()) {
    try {
      return await backendUsers.toggleUserActive(id, isActive);
    } catch (err) {
      console.warn(`Backend toggleUserActive(${id}) failed:`, err);
    }
  }
  return mock.toggleUserActive(id, isActive);
}

export async function fetchUserStats() {
  const allUsers = await fetchUsers();
  return {
    total: allUsers.length,
    students: allUsers.filter((u) => u.role === 'student').length,
    responders: allUsers.filter((u) => u.role === 'medical_responder' || u.role === 'security_responder').length,
    operators: allUsers.filter((u) => u.role === 'operator').length,
    administrators: allUsers.filter((u) => u.role === 'administrator').length,
    staff: allUsers.filter((u) => u.role === 'staff').length,
    active: allUsers.filter((u) => u.is_active ?? true).length,
    inactive: allUsers.filter((u) => u.is_active === false).length,
  };
}

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

export async function updateIncidentStatus(
  id: string,
  status: Incident['status']
): Promise<Incident | null> {
  if (isSupabaseConfigured()) {
    try {
      return await backendIncidents.updateIncidentStatus(id, status);
    } catch (err) {
      console.warn(`Backend updateIncidentStatus(${id}) failed:`, err);
    }
  }
  return null;
}

export async function assignResponderToIncident(
  incidentId: string,
  responderId: string
): Promise<Incident | null> {
  if (isSupabaseConfigured()) {
    try {
      return await backendIncidents.assignResponder(incidentId, responderId);
    } catch (err) {
      console.warn(`Backend assignResponder(${incidentId}) failed:`, err);
    }
  }
  return null;
}

