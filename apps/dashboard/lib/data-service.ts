import * as backendIncidents from './backend/incidents';
import * as backendResponders from './backend/responders';
import * as backendDevices from './backend/devices';
import * as backendReports from './backend/reports';
import * as backendUsers from './backend/users';
import { supabase } from './backend/supabase';

import type { Incident, IncidentFilter, IncidentCommunityResponse } from '@/types/incident';
import type { Responder, ResponderFilter } from '@/types/responder';
import type { Device, DeviceFilter } from '@/types/device';
import type { SafetyReport, ReportFilter } from '@/types/report';
import type { User, UserFilter, UserRole } from '@/types/user';

export async function fetchUsers(filter?: UserFilter): Promise<User[]> {
  return await backendUsers.getUsers(filter);
}

export async function fetchUserById(id: string): Promise<User | null> {
  return await backendUsers.getUserById(id);
}

export async function updateUserRole(id: string, role: UserRole): Promise<User | null> {
  return await backendUsers.updateUserRole(id, role);
}

export async function toggleUserActive(id: string, isActive: boolean): Promise<User | null> {
  return await backendUsers.toggleUserActive(id, isActive);
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
  return await backendIncidents.getIncidents(filter);
}

export async function fetchIncidentById(id: string): Promise<Incident | null> {
  return await backendIncidents.getIncidentById(id);
}

export async function fetchResponders(filter?: ResponderFilter): Promise<Responder[]> {
  return await backendResponders.getResponders(filter);
}

export async function updateResponderLocation(
  id: string,
  latitude: number,
  longitude: number,
  status?: Responder['status'],
  currentIncidentId?: string
): Promise<void> {
  return await backendResponders.updateResponderLocation(
    id,
    latitude,
    longitude,
    status,
    currentIncidentId
  );
}

export async function fetchDevices(filter?: DeviceFilter): Promise<Device[]> {
  return await backendDevices.getDevices(filter);
}

export async function fetchReports(filter?: ReportFilter): Promise<SafetyReport[]> {
  return await backendReports.getReports(filter);
}

export async function fetchDashboardStats() {
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
}

export async function updateIncidentStatus(
  id: string,
  status: Incident['status']
): Promise<Incident | null> {
  return await backendIncidents.updateIncidentStatus(id, status);
}

export async function assignResponderToIncident(
  incidentId: string,
  responderId: string,
  responderName?: string
): Promise<Incident | null> {
  return await backendIncidents.assignResponder(incidentId, responderId, responderName);
}

export async function deleteIncident(id: string): Promise<void> {
  return await backendIncidents.deleteIncident(id);
}

export function createSimulatedIncident(type?: import('@/types/incident').EmergencyType): Incident {
  return backendIncidents.createSimulatedIncident(type);
}

export async function fetchCommunityResponses(incidentId: string): Promise<IncidentCommunityResponse[]> {
  return await backendIncidents.getCommunityResponses(incidentId);
}

export async function submitCommunityResponse(
  response: Omit<IncidentCommunityResponse, 'id' | 'created_at'>
): Promise<IncidentCommunityResponse> {
  return await backendIncidents.addCommunityResponse(response);
}

