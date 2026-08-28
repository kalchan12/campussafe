'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { fetchIncidents } from '@/lib/data-service';
import { realtimeService } from '@/lib/realtime';
import { EMERGENCY_TYPE_LABELS } from '@/types/incident';
import type { Incident, IncidentFilter } from '@/types/incident';
import { formatTime } from '@/lib/utils';

const SEVERITY_CONFIG: Record<number, { label: string; variant: 'critical' | 'high' | 'medium'; icon: string; color: string }> = {
  1: { label: 'CRITICAL', variant: 'critical', icon: 'warning', color: 'text-error' },
  2: { label: 'HIGH', variant: 'high', icon: 'local_fire_department', color: 'text-amber-700' },
  3: { label: 'MEDIUM', variant: 'medium', icon: 'policy', color: 'text-teal-700' },
};

export default function IncidentsPage() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [filter, setFilter] = useState<IncidentFilter>({});
  const [search, setSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    async function load() {
      const data = await fetchIncidents({ ...filter, search });
      setIncidents(data);
      setCurrentPage(1);
    }
    load();

    const unsubCreated = realtimeService.subscribe('INCIDENT_CREATED', (payload) => {
      const newInc = payload.data as unknown as Incident;
      setIncidents((prev) => {
        if (prev.some((i) => i.id === newInc.id)) return prev;
        return [newInc, ...prev];
      });
    });

    const unsubStatus = realtimeService.subscribe('INCIDENT_STATUS_CHANGED', (payload) => {
      const updated = payload.data as unknown as Incident;
      setIncidents((prev) =>
        prev.map((i) => (i.id === updated.id ? { ...i, ...updated } : i))
      );
    });

    return () => {
      unsubCreated();
      unsubStatus();
    };
  }, [filter, search]);

  const totalPages = Math.ceil(incidents.length / itemsPerPage);
  const paginatedIncidents = incidents.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 h-screen">
        <TopNav showSearch searchPlaceholder="Search IDs, Locations..." onSearch={setSearch} />
        <main className="flex-1 overflow-y-auto bg-background p-6">
          <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header */}
            <div className="flex items-start justify-between">
              <div>
                <h1 className="font-headline-lg text-headline-lg text-on-surface">Live Incidents</h1>
                <p className="font-body-md text-body-md text-on-surface-variant mt-1">
                  Real-time operational overview of campus events.
                </p>
              </div>
              <div className="flex gap-3">
                <Button variant="secondary">
                  <span className="material-symbols-outlined text-sm mr-1.5">download</span>
                  Export
                </Button>
                <Button>
                  <span className="mr-1.5">+</span>
                  New Incident
                </Button>
              </div>
            </div>

            {/* Filter Bar */}
            <div className="bg-surface-container-lowest border border-outline-variant rounded-lg p-4">
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2 text-on-surface-variant">
                  <span className="material-symbols-outlined text-lg">tune</span>
                  <span className="font-label-md text-label-md">Filters:</span>
                </div>
                <select
                  className="px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-label-md text-label-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                  onChange={(e) =>
                    setFilter({ ...filter, status: e.target.value ? [e.target.value as Incident['status']] : undefined })
                  }
                >
                  <option value="">Status: Active</option>
                  <option value="created">Created</option>
                  <option value="received">Received</option>
                  <option value="assigned">Assigned</option>
                  <option value="responding">Responding</option>
                  <option value="arrived">Arrived</option>
                  <option value="resolved">Resolved</option>
                </select>
                <select
                  className="px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-label-md text-label-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                  onChange={(e) =>
                    setFilter({ ...filter, type: e.target.value ? [e.target.value as Incident['type']] : undefined })
                  }
                >
                  <option value="">Type: All</option>
                  <option value="medical">Medical</option>
                  <option value="security">Security</option>
                  <option value="fire">Fire</option>
                  <option value="accident">Accident</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            {/* Incidents Table */}
            <div className="bg-surface-container-lowest border border-outline-variant rounded-lg overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-left">
                  <thead>
                    <tr className="border-b border-outline-variant bg-surface-container-low">
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Severity</th>
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Incident ID</th>
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Type</th>
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Location</th>
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Reported</th>
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Responder</th>
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedIncidents.map((incident) => {
                      const severity = SEVERITY_CONFIG[incident.priority] || SEVERITY_CONFIG[3];
                      return (
                        <tr
                          key={incident.id}
                          className="border-b border-outline-variant hover:bg-surface-container-low transition-colors cursor-pointer"
                        >
                          <td className="py-4 px-4">
                            <div className="flex items-center gap-2">
                              {incident.priority === 1 && (
                                <span className="w-2 h-2 rounded-full bg-error animate-subtle-pulse" />
                              )}
                              <span className={`material-symbols-outlined text-lg ${severity.color}`}>
                                {severity.icon}
                              </span>
                              <span className={`font-label-md text-label-md font-bold ${severity.color}`}>
                                {severity.label}
                              </span>
                            </div>
                          </td>
                          <td className="py-4 px-4 font-technical-sm text-technical-sm text-on-surface">
                            {incident.id.toUpperCase()}
                          </td>
                          <td className="py-4 px-4 font-body-md text-body-md text-on-surface">
                            {EMERGENCY_TYPE_LABELS[incident.type]}
                          </td>
                          <td className="py-4 px-4 font-body-md text-body-md text-on-surface">
                            {incident.location_description || '-'}
                          </td>
                          <td className="py-4 px-4 font-technical-sm text-technical-sm text-on-surface-variant">
                            {formatTime(incident.created_at)}
                          </td>
                          <td className="py-4 px-4 font-body-md text-body-md text-on-surface">
                            {incident.assigned_responder_name || '-'}
                          </td>
                          <td className="py-4 px-4">
                            <Badge variant={incident.priority === 1 ? 'error' : incident.priority === 2 ? 'info' : 'default'}>
                              {incident.status.charAt(0).toUpperCase() + incident.status.slice(1)}
                            </Badge>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              {/* Pagination Footer */}
              <div className="flex items-center justify-between px-4 py-3 border-t border-outline-variant">
                <span className="font-technical-sm text-technical-sm text-on-surface-variant">
                  Showing {(currentPage - 1) * itemsPerPage + 1} to {Math.min(currentPage * itemsPerPage, incidents.length)} of {incidents.length} entries
                </span>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                    disabled={currentPage === 1}
                    className="p-2 rounded text-on-surface-variant hover:bg-surface-variant disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                  >
                    <span className="material-symbols-outlined text-lg">chevron_left</span>
                  </button>
                  {Array.from({ length: Math.min(totalPages, 3) }, (_, i) => i + 1).map((page) => (
                    <button
                      key={page}
                      onClick={() => setCurrentPage(page)}
                      className={`w-8 h-8 rounded font-label-md text-label-md transition-colors ${
                        page === currentPage
                          ? 'bg-primary text-on-primary'
                          : 'text-on-surface-variant hover:bg-surface-variant'
                      }`}
                    >
                      {page}
                    </button>
                  ))}
                  <button
                    onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                    disabled={currentPage === totalPages}
                    className="p-2 rounded text-on-surface-variant hover:bg-surface-variant disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                  >
                    <span className="material-symbols-outlined text-lg">chevron_right</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
