import type { User, UserFilter, UserRole } from '@/types/user';
import type { Incident, IncidentFilter } from '@/types/incident';
import type { Responder, ResponderFilter } from '@/types/responder';
import type { Device, DeviceFilter } from '@/types/device';
import type { SafetyReport, ReportFilter } from '@/types/report';
import {
  mockIncidents,
  mockResponders,
  mockDevices,
  mockReports,
  mockUsers,
} from './data';

let usersState = [...mockUsers];

export async function getUsers(filter?: UserFilter): Promise<User[]> {
  let results = [...usersState];

  if (filter?.role?.length) {
    results = results.filter((u) => filter.role!.includes(u.role));
  }
  if (filter?.campus_block) {
    results = results.filter((u) => u.campus_block?.toLowerCase() === filter.campus_block?.toLowerCase());
  }
  if (filter?.is_active !== undefined) {
    results = results.filter((u) => (u.is_active ?? true) === filter.is_active);
  }
  if (filter?.search) {
    const search = filter.search.toLowerCase();
    results = results.filter(
      (u) =>
        u.full_name.toLowerCase().includes(search) ||
        u.email.toLowerCase().includes(search) ||
        (u.phone && u.phone.toLowerCase().includes(search)) ||
        (u.campus_block && u.campus_block.toLowerCase().includes(search))
    );
  }

  return results;
}

export async function getUserById(id: string): Promise<User | undefined> {
  return usersState.find((u) => u.id === id);
}

export async function updateUserRole(id: string, role: UserRole): Promise<User | null> {
  const index = usersState.findIndex((u) => u.id === id);
  if (index === -1) return null;
  usersState[index] = {
    ...usersState[index],
    role,
    updated_at: new Date().toISOString(),
  };
  return usersState[index];
}

export async function toggleUserActive(id: string, isActive: boolean): Promise<User | null> {
  const index = usersState.findIndex((u) => u.id === id);
  if (index === -1) return null;
  usersState[index] = {
    ...usersState[index],
    is_active: isActive,
    updated_at: new Date().toISOString(),
  };
  return usersState[index];
}


export async function getIncidents(filter?: IncidentFilter): Promise<Incident[]> {
  let results = [...mockIncidents];

  if (filter?.status?.length) {
    results = results.filter((i) => filter.status!.includes(i.status));
  }
  if (filter?.type?.length) {
    results = results.filter((i) => filter.type!.includes(i.type));
  }
  if (filter?.priority?.length) {
    results = results.filter((i) => filter.priority!.includes(i.priority));
  }
  if (filter?.search) {
    const search = filter.search.toLowerCase();
    results = results.filter(
      (i) =>
        i.description?.toLowerCase().includes(search) ||
        i.location_description?.toLowerCase().includes(search)
    );
  }

  return results;
}

export async function getIncidentById(id: string): Promise<Incident | undefined> {
  return mockIncidents.find((i) => i.id === id);
}

export async function getResponders(filter?: ResponderFilter): Promise<Responder[]> {
  let results = [...mockResponders];

  if (filter?.status?.length) {
    results = results.filter((r) => filter.status!.includes(r.status));
  }
  if (filter?.role?.length) {
    results = results.filter((r) => filter.role!.includes(r.role));
  }
  if (filter?.search) {
    const search = filter.search.toLowerCase();
    results = results.filter(
      (r) =>
        r.name.toLowerCase().includes(search) ||
        r.email.toLowerCase().includes(search)
    );
  }

  return results;
}

export async function getResponderById(id: string): Promise<Responder | undefined> {
  return mockResponders.find((r) => r.id === id);
}

export async function getDevices(filter?: DeviceFilter): Promise<Device[]> {
  let results = [...mockDevices];

  if (filter?.type?.length) {
    results = results.filter((d) => filter.type!.includes(d.type));
  }
  if (filter?.status?.length) {
    results = results.filter((d) => filter.status!.includes(d.status));
  }
  if (filter?.search) {
    const search = filter.search.toLowerCase();
    results = results.filter(
      (d) =>
        d.name.toLowerCase().includes(search) ||
        d.device_id.toLowerCase().includes(search)
    );
  }

  return results;
}

export async function getDeviceById(id: string): Promise<Device | undefined> {
  return mockDevices.find((d) => d.id === id);
}

export async function getReports(filter?: ReportFilter): Promise<SafetyReport[]> {
  let results = [...mockReports];

  if (filter?.type?.length) {
    results = results.filter((r) => filter.type!.includes(r.type));
  }
  if (filter?.status?.length) {
    results = results.filter((r) => filter.status!.includes(r.status));
  }
  if (filter?.is_anonymous !== undefined) {
    results = results.filter((r) => r.is_anonymous === filter.is_anonymous);
  }
  if (filter?.search) {
    const search = filter.search.toLowerCase();
    results = results.filter((r) => r.description.toLowerCase().includes(search));
  }

  return results;
}

export async function getReportById(id: string): Promise<SafetyReport | undefined> {
  return mockReports.find((r) => r.id === id);
}

export async function getDashboardStats() {
  const activeIncidents = mockIncidents.filter(
    (i) => !['resolved', 'cancelled'].includes(i.status)
  ).length;
  const availableResponders = mockResponders.filter(
    (r) => r.status === 'available'
  ).length;
  const onlineDevices = mockDevices.filter(
    (d) => d.status === 'online'
  ).length;
  const pendingReports = mockReports.filter(
    (r) => r.status === 'submitted' || r.status === 'under_review'
  ).length;

  return {
    activeIncidents,
    availableResponders,
    onlineDevices,
    pendingReports,
    totalIncidents: mockIncidents.length,
    totalResponders: mockResponders.length,
    totalDevices: mockDevices.length,
  };
}
