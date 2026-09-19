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
  deleteIncident,
  fetchCommunityResponses,
  submitCommunityResponse,
  createSimulatedIncident,
} from '@/lib/data-service';
import { realtimeService } from '@/lib/realtime';
import { EMERGENCY_TYPE_LABELS, COMMUNITY_RESPONSE_LABELS } from '@/types/incident';
import type { Incident, IncidentFilter, IncidentCommunityResponse, CommunityResponseType } from '@/types/incident';
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
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [communityResponses, setCommunityResponses] = useState<IncidentCommunityResponse[]>([]);
  const [loadingResponses, setLoadingResponses] = useState(false);
  const [newUpdateText, setNewUpdateText] = useState('');
  const [submittingResponse, setSubmittingResponse] = useState(false);
  const itemsPerPage = 10;

  useEffect(() => {
    if (!selectedIncident) {
      setCommunityResponses([]);
      return;
    }
    setLoadingResponses(true);
    fetchCommunityResponses(selectedIncident.id)
      .then((data) => setCommunityResponses(data))
      .catch((e) => console.error('Failed to load community responses', e))
      .finally(() => setLoadingResponses(false));
  }, [selectedIncident?.id]);

  useEffect(() => {
    async function load() {
      try {
        const [incidentsData, respondersData] = await Promise.all([
          fetchIncidents({ ...filter, search }),
          fetchResponders(),
        ]);
        setIncidents(incidentsData);
        setResponders(respondersData);
        setCurrentPage(1);
      } catch (err) {
        console.error('Failed to load incidents or responders:', err);
      }
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

    const unsubDeleted = realtimeService.subscribe('INCIDENT_DELETED', (payload) => {
      const deleted = payload.data as unknown as Incident;
      setIncidents((prev) => prev.filter((i) => i.id !== deleted.id));
      if (selectedIncident && selectedIncident.id === deleted.id) {
        setSelectedIncident(null);
      }
    });

    const unsubCommunity = realtimeService.subscribe('COMMUNITY_RESPONSE_ADDED', (payload) => {
      const newResp = payload.data as unknown as IncidentCommunityResponse;
      setCommunityResponses((prev) => {
        if (prev.some((r) => r.id === newResp.id)) return prev;
        if (selectedIncident && newResp.incident_id === selectedIncident.id) {
          return [...prev, newResp];
        }
        return prev;
      });
    });

    return () => {
      unsubCreated();
      unsubStatus();
      unsubDeleted();
      unsubCommunity();
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

  const handleInlineUpdateStatus = async (incidentId: string, status: Incident['status']) => {
    setActionLoading(true);
    try {
      await updateIncidentStatus(incidentId, status);
      setIncidents((prev) =>
        prev.map((i) => (i.id === incidentId ? { ...i, status } : i))
      );
      if (selectedIncident && selectedIncident.id === incidentId) {
        setSelectedIncident((prev) => (prev ? { ...prev, status } : null));
      }
    } finally {
      setActionLoading(false);
    }
  };

  const handleInlineAssignResponder = async (
    incidentId: string,
    responderId: string,
    responderName?: string
  ) => {
    if (!responderId) return;
    const name =
      responderName ||
      responders.find((r) => r.id === responderId)?.name ||
      'Assigned Responder';
    setActionLoading(true);
    try {
      await assignResponderToIncident(incidentId, responderId, name);
      setIncidents((prev) =>
        prev.map((i) =>
          i.id === incidentId
            ? {
                ...i,
                status: 'assigned',
                assigned_responder_id: responderId,
                assigned_responder_name: name,
              }
            : i
        )
      );
      if (selectedIncident && selectedIncident.id === incidentId) {
        setSelectedIncident((prev) =>
          prev
            ? {
                ...prev,
                status: 'assigned',
                assigned_responder_id: responderId,
                assigned_responder_name: name,
              }
            : null
        );
      }
    } finally {
      setActionLoading(false);
    }
  };

  const handleQuickDispatch = async (incident: Incident) => {
    const matchingRole = incident.type === 'medical' ? 'medical' : 'security';
    const candidate =
      responders.find((r) => r.role === matchingRole && r.status === 'available') ||
      responders.find((r) => r.status === 'available') ||
      responders[0];

    if (candidate) {
      await handleInlineAssignResponder(incident.id, candidate.id, candidate.name);
    } else {
      setSelectedIncident(incident);
      setSelectedResponderId(incident.assigned_responder_id || '');
    }
  };

  const handleSimulateIncident = () => {
    const types = ['medical', 'security', 'fire', 'accident'] as const;
    const chosenType = types[Math.floor(Math.random() * types.length)];
    const sim = createSimulatedIncident(chosenType);
    setIncidents((prev) => [sim, ...prev]);
  };

  const handleDeleteIncident = async () => {
    if (!selectedIncident) return;
    setActionLoading(true);
    try {
      await deleteIncident(selectedIncident.id);
      setIncidents((prev) => prev.filter((i) => i.id !== selectedIncident.id));
      setSelectedIncident(null);
      setShowDeleteConfirm(false);
    } catch (e) {
      console.error('Failed to delete incident:', e);
    } finally {
      setActionLoading(false);
    }
  };

  const handlePostCommunityUpdate = async (type: CommunityResponseType = 'other_assistance') => {
    if (!selectedIncident || !newUpdateText.trim()) return;
    setSubmittingResponse(true);
    try {
      const resp = await submitCommunityResponse({
        incident_id: selectedIncident.id,
        responder_name: 'Operations Dispatch',
        response_type: type,
        message: newUpdateText.trim(),
      });
      setCommunityResponses((prev) => [...prev, resp]);
      setNewUpdateText('');
    } catch (e) {
      console.error('Failed to post update:', e);
    } finally {
      setSubmittingResponse(false);
    }
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
              <div className="flex items-center gap-2">
                <Button
                  variant="primary"
                  onClick={handleSimulateIncident}
                  className="bg-primary text-on-primary hover:bg-primary/90 text-xs px-3 py-1.5 flex items-center gap-1.5 shadow-sm"
                >
                  <span className="material-symbols-outlined text-sm">add_alert</span>
                  <span>+ Simulate Incident</span>
                </Button>
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
                      <th className="py-3 px-4 font-label-md text-label-md text-on-surface-variant text-right">Actions</th>
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
                            setShowDeleteConfirm(false);
                          }}
                          className="border-b border-outline-variant hover:bg-surface-container-low transition-colors cursor-pointer"
                        >
                          <td className="py-3 px-4">
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
                          <td className="py-3 px-4 font-technical-sm text-technical-sm text-on-surface font-bold">
                            {incident.id.toUpperCase().slice(0, 12)}
                          </td>
                          <td className="py-3 px-4 font-body-md text-body-md text-on-surface">
                            {EMERGENCY_TYPE_LABELS[incident.type]}
                          </td>
                          <td className="py-3 px-4 font-body-md text-body-md text-on-surface max-w-[220px] truncate">
                            {incident.location_description || incident.campus_block || '-'}
                          </td>
                          <td className="py-3 px-4 font-technical-sm text-technical-sm text-on-surface-variant">
                            {formatTime(incident.created_at)}
                          </td>
                          <td className="py-3 px-4 font-body-md text-body-md text-on-surface" onClick={(e) => e.stopPropagation()}>
                            {incident.assigned_responder_name ? (
                              <div className="flex items-center gap-1.5">
                                <span className="material-symbols-outlined text-sm text-emerald-600">verified_user</span>
                                <span className="font-semibold text-xs text-on-surface truncate max-w-[140px]" title={incident.assigned_responder_name}>
                                  {incident.assigned_responder_name}
                                </span>
                              </div>
                            ) : (
                              <select
                                value=""
                                onChange={(e) => handleInlineAssignResponder(incident.id, e.target.value)}
                                className="text-xs px-2 py-1 border border-outline-variant rounded bg-surface text-on-surface font-medium focus:outline-none focus:ring-1 focus:ring-primary cursor-pointer hover:border-primary/50"
                              >
                                <option value="">Assign Responder...</option>
                                {responders.map((r) => (
                                  <option key={r.id} value={r.id}>
                                    {r.name} ({r.role})
                                  </option>
                                ))}
                              </select>
                            )}
                          </td>
                          <td className="py-3 px-4">
                            <Badge variant={incident.priority === 1 ? 'error' : incident.priority === 2 ? 'info' : 'default'}>
                              {incident.status.charAt(0).toUpperCase() + incident.status.slice(1)}
                            </Badge>
                          </td>
                          <td className="py-3 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                            <div className="flex items-center justify-end gap-1.5">
                              {/* Direct action button before opening full modal */}
                              {incident.status === 'created' || incident.status === 'received' ? (
                                <button
                                  type="button"
                                  className="text-xs px-2.5 py-1 bg-primary text-on-primary hover:bg-primary/90 rounded font-bold transition-colors shadow-sm flex items-center gap-1"
                                  onClick={() => handleQuickDispatch(incident)}
                                  disabled={actionLoading}
                                  title="Assign closest available responder immediately"
                                >
                                  <span className="material-symbols-outlined text-xs">bolt</span>
                                  <span>Dispatch</span>
                                </button>
                              ) : incident.status === 'assigned' ? (
                                <button
                                  type="button"
                                  className="text-xs px-2.5 py-1 bg-amber-500 text-white rounded font-bold hover:bg-amber-600 transition-colors shadow-sm flex items-center gap-1"
                                  onClick={() => handleInlineUpdateStatus(incident.id, 'responding')}
                                  disabled={actionLoading}
                                  title="Mark responder as en route"
                                >
                                  <span className="material-symbols-outlined text-xs">near_me</span>
                                  <span>En Route</span>
                                </button>
                              ) : incident.status === 'responding' ? (
                                <button
                                  type="button"
                                  className="text-xs px-2.5 py-1 bg-teal-600 text-white rounded font-bold hover:bg-teal-700 transition-colors shadow-sm flex items-center gap-1"
                                  onClick={() => handleInlineUpdateStatus(incident.id, 'arrived')}
                                  disabled={actionLoading}
                                  title="Mark responder as arrived at scene"
                                >
                                  <span className="material-symbols-outlined text-xs">location_on</span>
                                  <span>Arrived</span>
                                </button>
                              ) : incident.status === 'arrived' ? (
                                <button
                                  type="button"
                                  className="text-xs px-2.5 py-1 bg-emerald-600 text-white rounded font-bold hover:bg-emerald-700 transition-colors shadow-sm flex items-center gap-1"
                                  onClick={() => handleInlineUpdateStatus(incident.id, 'resolved')}
                                  disabled={actionLoading}
                                  title="Mark incident resolved"
                                >
                                  <span className="material-symbols-outlined text-xs">check_circle</span>
                                  <span>Resolve</span>
                                </button>
                              ) : (
                                <span className="text-xs font-semibold text-outline px-1">Completed</span>
                              )}

                              {/* View Full Incident Console */}
                              <Button
                                variant="secondary"
                                className="text-xs px-2 py-1 hover:bg-surface-variant flex items-center gap-1"
                                title="View Full Incident Details & Console"
                                onClick={() => {
                                  setSelectedIncident(incident);
                                  setSelectedResponderId(incident.assigned_responder_id || '');
                                  setShowDeleteConfirm(false);
                                }}
                              >
                                <span>Details</span>
                                <span className="material-symbols-outlined text-xs">open_in_new</span>
                              </Button>
                            </div>
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
          <div className="bg-surface-container-lowest border border-outline-variant rounded-xl max-w-xl max-h-[90vh] overflow-y-auto w-full p-6 shadow-2xl space-y-5 animate-in fade-in zoom-in-95">
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

            {/* Community First Response & Eyewitness Updates */}
            <div className="pt-3 border-t border-outline-variant space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-1.5">
                  <span className="material-symbols-outlined text-primary text-base">
                    {['security', 'fire'].includes(selectedIncident.type) ? 'visibility' : 'volunteer_activism'}
                  </span>
                  <span className="font-label-md text-xs font-bold text-on-surface">
                    {['security', 'fire'].includes(selectedIncident.type)
                      ? 'Eyewitness Situation Reports'
                      : 'Community Assistance & First Response'}
                  </span>
                </div>
                <span className="text-[11px] text-on-surface-variant font-mono">
                  {communityResponses.length} update{communityResponses.length === 1 ? '' : 's'}
                </span>
              </div>

              {['security', 'fire'].includes(selectedIncident.type) ? (
                <div className="p-2.5 rounded bg-amber-500/10 border border-amber-500/30 text-[12px] text-amber-800 dark:text-amber-300 flex items-start gap-2">
                  <span className="material-symbols-outlined text-base text-amber-600 mt-0.5">security</span>
                  <span>
                    <strong>Safety Notice:</strong> Direct civilian intervention is restricted for security/fire incidents. Displaying observational reports from bystanders.
                  </span>
                </div>
              ) : (
                <div className="p-2 rounded bg-primary/5 border border-primary/20 text-[12px] text-on-surface-variant flex items-center gap-2">
                  <span className="material-symbols-outlined text-base text-primary">handshake</span>
                  <span>Nearby students/staff can provide first aid or escort victim to campus clinic.</span>
                </div>
              )}

              {/* Feed List */}
              <div className="space-y-2 max-h-48 overflow-y-auto pr-1">
                {loadingResponses ? (
                  <p className="text-xs text-on-surface-variant text-center py-2">Loading updates...</p>
                ) : communityResponses.length === 0 ? (
                  <p className="text-xs text-on-surface-variant text-center py-3 italic bg-surface-container-low rounded">
                    No community updates or eyewitness reports submitted yet.
                  </p>
                ) : (
                  communityResponses.map((cr) => {
                    const cfg = COMMUNITY_RESPONSE_LABELS[cr.response_type] || COMMUNITY_RESPONSE_LABELS.other_assistance;
                    return (
                      <div key={cr.id} className="p-2.5 rounded bg-surface-container-low border border-outline-variant text-xs space-y-1">
                        <div className="flex items-center justify-between">
                          <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border ${cfg.color}`}>
                            <span className="material-symbols-outlined text-xs">{cfg.icon}</span>
                            {cfg.label}
                          </span>
                          <span className="text-[10px] text-on-surface-variant">
                            {formatTime(cr.created_at)}
                          </span>
                        </div>
                        <p className="text-on-surface text-xs font-medium">{cr.message}</p>
                        <p className="text-[10px] text-on-surface-variant">
                          Reported by: <span className="font-semibold">{cr.responder_name || 'Anonymous User'}</span>
                        </p>
                      </div>
                    );
                  })
                )}
              </div>

              {/* Dispatch/Operator Log Entry */}
              <div className="flex gap-2 pt-1">
                <input
                  type="text"
                  placeholder={['security', 'fire'].includes(selectedIncident.type) ? "Log eyewitness observation..." : "Log community/first aid update..."}
                  value={newUpdateText}
                  onChange={(e) => setNewUpdateText(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handlePostCommunityUpdate(['security', 'fire'].includes(selectedIncident.type) ? 'eyewitness_report' : 'other_assistance');
                    }
                  }}
                  className="flex-1 px-3 py-1.5 border border-outline-variant rounded bg-surface text-on-surface text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                />
                <Button
                  variant="secondary"
                  className="text-xs px-3 py-1.5"
                  disabled={submittingResponse || !newUpdateText.trim()}
                  onClick={() => handlePostCommunityUpdate(['security', 'fire'].includes(selectedIncident.type) ? 'eyewitness_report' : 'other_assistance')}
                >
                  {submittingResponse ? 'Posting...' : 'Post Log'}
                </Button>
              </div>
            </div>

            {/* Delete Incident (Reporter Only) */}
            <div className="pt-3 border-t border-outline-variant">
              {!showDeleteConfirm ? (
                <button
                  onClick={() => setShowDeleteConfirm(true)}
                  className="w-full text-center text-xs text-on-surface-variant hover:text-error transition-colors py-1.5"
                >
                  Delete this incident permanently...
                </button>
              ) : (
                <div className="space-y-2">
                  <p className="text-xs text-error font-medium text-center">
                    Are you sure? This will permanently remove this incident from the system.
                    Only the person who reported this incident can perform this action.
                  </p>
                  <div className="flex gap-2">
                    <Button
                      variant="secondary"
                      className="flex-1 text-xs"
                      onClick={() => setShowDeleteConfirm(false)}
                      disabled={actionLoading}
                    >
                      Cancel
                    </Button>
                    <Button
                      variant="danger"
                      className="flex-1 text-xs"
                      onClick={handleDeleteIncident}
                      disabled={actionLoading}
                    >
                      {actionLoading ? 'Deleting...' : 'Yes, Delete Permanently'}
                    </Button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}
