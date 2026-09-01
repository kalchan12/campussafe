'use client';

import { useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  fetchIncidents,
  fetchResponders,
  assignResponderToIncident,
  updateIncidentStatus,
} from '@/lib/data-service';
import { realtimeService } from '@/lib/realtime';
import { EMERGENCY_TYPE_LABELS } from '@/types/incident';
import type { Incident, IncidentFilter } from '@/types/incident';
import type { Responder } from '@/types/responder';
import { formatTime } from '@/lib/utils';

const SEVERITY_CONFIG: Record<number, { label: string; variant: 'critical' | 'high' | 'medium'; icon: string; color: string }> = {
  1: { label: 'CRITICAL', variant: 'critical', icon: 'warning', color: 'text-error' },
  2: { label: 'HIGH', variant: 'high', icon: 'local_fire_department', color: 'text-amber-700' },
  3: { label: 'MEDIUM', variant: 'medium', icon: 'policy', color: 'text-teal-700' },
};

export default function IncidentsPage() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [responders, setResponders] = useState<Responder[]>([]);
  const [selectedIncident, setSelectedIncident] = useState<Incident | null>(null);
  const [selectedResponderId, setSelectedResponderId] = useState<string>('');
  const [filter, setFilter] = useState<IncidentFilter>({});
  const [search, setSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [actionLoading, setActionLoading] = useState(false);
  const itemsPerPage = 10;

  useEffect(() => {
    async function load() {
      const [incidentsData, respondersData] = await Promise.all([
        fetchIncidents({ ...filter, search }),
        fetchResponders(),
      ]);
      setIncidents(incidentsData);
      setResponders(respondersData);
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
      if (selectedIncident && selectedIncident.id === updated.id) {
        setSelectedIncident((prev) => (prev ? { ...prev, ...updated } : null));
      }
    });

    return () => {
      unsubCreated();
      unsubStatus();
    };
  }, [filter, search]);

  const handleAssignResponder = async () => {
    if (!selectedIncident || !selectedResponderId) return;
    setActionLoading(true);
    const assignedResponder = responders.find((r) => r.id === selectedResponderId);
    
    await assignResponderToIncident(selectedIncident.id, selectedResponderId);
    
    const updated = {
      ...selectedIncident,
      status: 'assigned' as const,
      assigned_responder_id: selectedResponderId,
      assigned_responder_name: assignedResponder?.name ?? 'Assigned Responder',
    };
    
    setIncidents((prev) =>
      prev.map((i) => (i.id === selectedIncident.id ? updated : i))
    );
    setSelectedIncident(updated);
    setActionLoading(false);
  };

  const handleUpdateStatus = async (status: Incident['status']) => {
    if (!selectedIncident) return;
    setActionLoading(true);
    await updateIncidentStatus(selectedIncident.id, status);
    const updated = { ...selectedIncident, status };
    setIncidents((prev) =>
      prev.map((i) => (i.id === selectedIncident.id ? updated : i))
    );
    setSelectedIncident(updated);
    setActionLoading(false);
  };

  const totalPages = Math.ceil(incidents.length / itemsPerPage);
  const paginatedIncidents = incidents.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <DashboardLayout showSearch searchPlaceholder="Search IDs, Locations..." onSearch={setSearch}>
          <div className="flex-1">
          <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header */}
            <div className="flex items-start justify-between">
              <div>
                <h1 className="font-headline-lg text-headline-lg text-on-surface">Live Incidents</h1>
                <p className="font-body-md text-body-md text-on-surface-variant mt-1">
                  Real-time operational overview of campus events. Click an incident to manage dispatch.
                </p>
              </div>
              <div className="flex gap-3">
                <Button variant="secondary" onClick={() => window.print()}>
                  <span className="material-symbols-outlined text-sm mr-1.5">download</span>
                  Export
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
                  <option value="">Status: All</option>
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
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant text-right">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedIncidents.map((incident) => {
                      const severity = SEVERITY_CONFIG[incident.priority] || SEVERITY_CONFIG[3];
                      return (
                        <tr
                          key={incident.id}
                          onClick={() => {
                            setSelectedIncident(incident);
                            setSelectedResponderId(incident.assigned_responder_id || '');
                          }}
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
                          <td className="py-4 px-4 font-technical-sm text-technical-sm text-on-surface font-bold">
                            {incident.id.toUpperCase()}
                          </td>
                          <td className="py-4 px-4 font-body-md text-body-md text-on-surface">
                            {EMERGENCY_TYPE_LABELS[incident.type]}
                          </td>
                          <td className="py-4 px-4 font-body-md text-body-md text-on-surface max-w-[220px] truncate">
                            {incident.location_description || incident.campus_block || '-'}
                          </td>
                          <td className="py-4 px-4 font-technical-sm text-technical-sm text-on-surface-variant">
                            {formatTime(incident.created_at)}
                          </td>
                          <td className="py-4 px-4 font-body-md text-body-md text-on-surface">
                            {incident.assigned_responder_name || (
                              <span className="text-amber-600 font-medium">Unassigned</span>
                            )}
                          </td>
                          <td className="py-4 px-4">
                            <Badge variant={incident.priority === 1 ? 'error' : incident.priority === 2 ? 'info' : 'default'}>
                              {incident.status.charAt(0).toUpperCase() + incident.status.slice(1)}
                            </Badge>
                          </td>
                          <td className="py-4 px-4 text-right">
                            <Button
                              variant="secondary"
                              className="text-xs px-2.5 py-1"
                              onClick={(e) => {
                                e.stopPropagation();
                                setSelectedIncident(incident);
                                setSelectedResponderId(incident.assigned_responder_id || '');
                              }}
                            >
                              Dispatch
                            </Button>
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
        </div>

      {/* Operator Dispatch & Status Modal */}
      {selectedIncident && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-surface-container-lowest border border-outline-variant rounded-xl max-w-lg w-full p-6 shadow-2xl space-y-5 animate-in fade-in zoom-in-95">
            <div className="flex items-start justify-between">
              <div>
                <span className="font-label-md text-xs uppercase tracking-wider text-on-surface-variant">
                  Incident Management Console
                </span>
                <h3 className="font-headline-md text-xl font-bold text-on-surface mt-0.5">
                  #{selectedIncident.id.toUpperCase()} — {EMERGENCY_TYPE_LABELS[selectedIncident.type]}
                </h3>
              </div>
              <button
                onClick={() => setSelectedIncident(null)}
                className="text-on-surface-variant hover:text-on-surface p-1 rounded"
              >
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <div className="bg-surface-container-low p-3.5 rounded-lg space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-on-surface-variant">Location:</span>
                <span className="font-semibold text-on-surface">
                  {selectedIncident.campus_block ?? selectedIncident.location_description ?? 'Campus Quad'}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-on-surface-variant">Priority:</span>
                <span className="font-semibold text-error">Priority {selectedIncident.priority}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-on-surface-variant">Current Status:</span>
                <Badge variant="info">{selectedIncident.status.toUpperCase()}</Badge>
              </div>
              {selectedIncident.description && (
                <div className="pt-2 border-t border-outline-variant text-on-surface-variant text-xs">
                  {selectedIncident.description}
                </div>
              )}
            </div>

            {/* Responder Assignment Section */}
            <div className="space-y-2">
              <label className="font-label-md text-xs font-bold text-on-surface">
                Assign On-Duty Responder:
              </label>
              <div className="flex gap-2">
                <select
                  value={selectedResponderId}
                  onChange={(e) => setSelectedResponderId(e.target.value)}
                  className="flex-1 px-3 py-2 border border-outline-variant rounded bg-surface text-on-surface text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                >
                  <option value="">Select a responder...</option>
                  {responders.map((r) => (
                    <option key={r.id} value={r.id}>
                      {r.name} ({r.role}) • {r.status}
                    </option>
                  ))}
                </select>
                <Button
                  onClick={handleAssignResponder}
                  disabled={!selectedResponderId || actionLoading}
                >
                  Assign
                </Button>
              </div>
            </div>

            {/* Status Progression Controls */}
            <div className="space-y-2 pt-2 border-t border-outline-variant">
              <label className="font-label-md text-xs font-bold text-on-surface">
                Operator Status Override:
              </label>
              <div className="grid grid-cols-2 gap-2">
                <Button
                  variant="secondary"
                  className="text-xs"
                  onClick={() => handleUpdateStatus('responding')}
                  disabled={actionLoading || selectedIncident.status === 'responding'}
                >
                  Mark En Route
                </Button>
                <Button
                  variant="secondary"
                  className="text-xs"
                  onClick={() => handleUpdateStatus('arrived')}
                  disabled={actionLoading || selectedIncident.status === 'arrived'}
                >
                  Mark Arrived
                </Button>
                <Button
                  className="text-xs bg-emerald-600 hover:bg-emerald-700 text-white"
                  onClick={() => handleUpdateStatus('resolved')}
                  disabled={actionLoading || selectedIncident.status === 'resolved'}
                >
                  Mark Resolved
                </Button>
                <Button
                  variant="danger"
                  className="text-xs"
                  onClick={() => handleUpdateStatus('cancelled')}
                  disabled={actionLoading || selectedIncident.status === 'cancelled'}
                >
                  Cancel / False Alarm
                </Button>
              </div>
            </div>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}
