'use client';

import { useState, useEffect, useMemo } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
import { CampusMap, type OperatorLocation } from '@/components/maps/campus-map';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  fetchIncidents,
  fetchResponders,
  fetchDevices,
  assignResponderToIncident,
} from '@/lib/data-service';
import { realtimeService } from '@/lib/realtime';
import {
  getIncidentMarkers,
  getResponderMarkers,
  calculateDistanceMeters,
  formatDistance,
  calculateEtaMinutes,
} from '@/lib/maps';
import { EMERGENCY_TYPE_LABELS } from '@/types/incident';
import type { Incident } from '@/types/incident';
import type { Responder } from '@/types/responder';
import type { Device } from '@/types/device';
import type { MapMarker } from '@/types/map';

type LayerFilter = 'all' | 'incidents' | 'responders' | 'devices';

export default function MapPage() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [responders, setResponders] = useState<Responder[]>([]);
  const [devices, setDevices] = useState<Device[]>([]);
  const [activeLayer, setActiveLayer] = useState<LayerFilter>('all');
  const [selectedIncident, setSelectedIncident] = useState<Incident | null>(null);
  const [isAssigning, setIsAssigning] = useState(false);
  const [dispatchSuccess, setDispatchSuccess] = useState<string | null>(null);

  // Real Operator GPS state
  const [operatorLocation, setOperatorLocation] = useState<OperatorLocation | null>(null);
  const [gpsError, setGpsError] = useState<string | null>(null);

  // 1. Capture Real Operator Location via Browser Geolocation API
  useEffect(() => {
    if (typeof window === 'undefined' || !navigator.geolocation) {
      setGpsError('Geolocation is not supported by your browser.');
      // Fallback location near campus
      setOperatorLocation({ latitude: 6.8905, longitude: 79.8815, accuracy: 15, isLive: false });
      return;
    }

    const watchId = navigator.geolocation.watchPosition(
      (pos) => {
        setOperatorLocation({
          latitude: pos.coords.latitude,
          longitude: pos.coords.longitude,
          accuracy: pos.coords.accuracy,
          isLive: true,
        });
        setGpsError(null);
      },
      (err) => {
        console.warn('Operator GPS watch error, using default EOC building coords:', err.message);
        setGpsError(err.message);
        // Fallback default coordinates (Admin building / EOC base)
        setOperatorLocation({ latitude: 6.8905, longitude: 79.8815, accuracy: 20, isLive: false });
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 5000,
      }
    );

    return () => {
      navigator.geolocation.clearWatch(watchId);
    };
  }, []);

  // 2. Load Incidents, Responders, and Devices
  useEffect(() => {
    async function loadData() {
      const [incidentsData, respondersData, devicesData] = await Promise.all([
        fetchIncidents(),
        fetchResponders(),
        fetchDevices(),
      ]);
      setIncidents(incidentsData);
      setResponders(respondersData);
      setDevices(devicesData);
    }
    loadData();

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
      setSelectedIncident((prev) => (prev?.id === updated.id ? { ...prev, ...updated } : prev));
    });

    return () => {
      unsubCreated();
      unsubStatus();
    };
  }, []);

  const activeIncidents = incidents.filter(
    (i) => !['resolved', 'cancelled'].includes(i.status)
  );

  const incidentMarkers = getIncidentMarkers(activeIncidents);
  const responderMarkers = getResponderMarkers(responders);
  const deviceMarkers: MapMarker[] = devices
    .filter((d) => d.latitude && d.longitude)
    .map((d) => ({
      id: d.id,
      label: d.name,
      latitude: d.latitude!,
      longitude: d.longitude!,
      type: 'device',
      status: d.status,
    }));

  let filteredMarkers: MapMarker[] = [];
  if (activeLayer === 'all' || activeLayer === 'incidents') {
    filteredMarkers = [...filteredMarkers, ...incidentMarkers];
  }
  if (activeLayer === 'all' || activeLayer === 'responders') {
    filteredMarkers = [...filteredMarkers, ...responderMarkers];
  }
  if (activeLayer === 'all' || activeLayer === 'devices') {
    filteredMarkers = [...filteredMarkers, ...deviceMarkers];
  }

  const layers: { key: LayerFilter; label: string; icon: string }[] = [
    { key: 'all', label: 'All Layers', icon: 'tune' },
    { key: 'incidents', label: 'Incidents', icon: 'warning' },
    { key: 'responders', label: 'Responders', icon: 'location_on' },
    { key: 'devices', label: 'Devices', icon: 'sos' },
  ];

  // Operator distance & ETA to the selected incident
  const operatorIncidentDistance = useMemo(() => {
    if (!operatorLocation || !selectedIncident || !selectedIncident.latitude || !selectedIncident.longitude) {
      return null;
    }
    const meters = calculateDistanceMeters(
      operatorLocation.latitude,
      operatorLocation.longitude,
      selectedIncident.latitude,
      selectedIncident.longitude
    );
    return {
      meters,
      formatted: formatDistance(meters),
      eta: calculateEtaMinutes(meters),
    };
  }, [operatorLocation, selectedIncident]);

  // Proximity-ranked responders relative to the selected incident
  const rankedResponders = useMemo(() => {
    if (!selectedIncident || !selectedIncident.latitude || !selectedIncident.longitude) {
      return [];
    }

    return responders
      .filter((r) => r.latitude && r.longitude)
      .map((r) => {
        const distanceToIncident = calculateDistanceMeters(
          r.latitude!,
          r.longitude!,
          selectedIncident.latitude!,
          selectedIncident.longitude!
        );
        return {
          ...r,
          distanceToIncident,
          formattedDistance: formatDistance(distanceToIncident),
          etaToIncident: calculateEtaMinutes(distanceToIncident),
        };
      })
      .sort((a, b) => a.distanceToIncident - b.distanceToIncident);
  }, [responders, selectedIncident]);

  // Handle assigning a specific responder based on proximity
  const handleAssignResponder = async (responderId: string, responderName: string) => {
    if (!selectedIncident) return;
    setIsAssigning(true);
    try {
      await assignResponderToIncident(selectedIncident.id, responderId);
      setSelectedIncident((prev) =>
        prev
          ? {
              ...prev,
              assigned_responder_id: responderId,
              assigned_responder_name: responderName,
              status: 'assigned',
            }
          : null
      );
      setDispatchSuccess(`Dispatched ${responderName} to incident`);
      setTimeout(() => setDispatchSuccess(null), 4000);
    } catch (err) {
      console.error('Failed to assign responder:', err);
    } finally {
      setIsAssigning(false);
    }
  };

  const handleMarkerClick = (marker: MapMarker) => {
    if (marker.type === 'incident') {
      const inc = incidents.find((i) => i.id === marker.id);
      if (inc) setSelectedIncident(inc);
    }
  };

  // Find responder for selected incident
  const assignedResponder = selectedIncident
    ? responders.find((r) => r.id === selectedIncident.assigned_responder_id)
    : null;

  return (
    <div className="flex h-screen bg-background overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 h-screen">
        <TopNav showSearch searchPlaceholder="Search incidents, assets..." />
        <main className="flex-1 relative overflow-hidden">
          {/* Map Canvas */}
          <div className="absolute inset-0 bg-surface-variant">
            <div
              className="absolute inset-0"
              style={{
                backgroundImage:
                  'linear-gradient(to right, #80808012 1px, transparent 1px), linear-gradient(to bottom, #80808012 1px, transparent 1px)',
                backgroundSize: '40px 40px',
              }}
            />
            <CampusMap
              markers={filteredMarkers}
              operatorLocation={operatorLocation}
              selectedMarkerId={selectedIncident?.id || null}
              onMarkerClick={handleMarkerClick}
              className="h-full w-full"
            />
          </div>

          {/* Floating Control Toolbar (Layer Filters & Status) */}
          <div className="absolute top-4 left-4 z-20 flex flex-wrap items-center gap-2">
            <div className="bg-surface-container-lowest/95 backdrop-blur-md rounded-xl p-1 border border-outline-variant shadow-lg flex items-center gap-1">
              <span className="px-2.5 text-[11px] font-label-md uppercase tracking-wider text-outline font-bold">
                Entities
              </span>
              {layers.map((layer) => (
                <button
                  key={layer.key}
                  onClick={() => setActiveLayer(layer.key)}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-label-md text-xs transition-colors ${
                    activeLayer === layer.key
                      ? 'bg-secondary-container text-on-secondary-container font-bold border border-secondary/30 shadow-sm'
                      : 'text-on-surface-variant hover:bg-surface-variant'
                  }`}
                >
                  <span className="material-symbols-outlined text-sm">{layer.icon}</span>
                  {layer.label}
                </button>
              ))}
            </div>

            {/* Operator Live GPS Pill */}
            <div className="bg-surface-container-lowest/95 backdrop-blur-md rounded-xl px-3 py-1.5 border border-outline-variant shadow-lg flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-blue-600 animate-ping" />
              <div className="text-xs">
                <span className="font-label-md font-semibold text-on-surface">Operator Location: </span>
                <span className="font-technical-sm text-outline">
                  {operatorLocation
                    ? `${operatorLocation.latitude.toFixed(4)}, ${operatorLocation.longitude.toFixed(4)}`
                    : 'Locating...'}
                </span>
              </div>
            </div>
          </div>

          {/* Toast Notification */}
          {dispatchSuccess && (
            <div className="absolute top-16 left-4 z-30 bg-emerald-600 text-white px-4 py-2.5 rounded-xl shadow-xl font-label-md text-xs flex items-center gap-2 animate-fade-in">
              <span className="material-symbols-outlined text-base">check_circle</span>
              <span>{dispatchSuccess}</span>
            </div>
          )}

          {/* Incident Detail & Proximity Dispatch Drawer */}
          {selectedIncident ? (
            <div className="absolute top-4 right-4 z-20 w-[410px] max-h-[90vh] bg-surface-container-lowest rounded-2xl border border-outline-variant shadow-2xl overflow-y-auto flex flex-col animate-fade-in">
              {/* Header */}
              <div className="bg-error text-on-error px-5 py-4 flex items-start justify-between sticky top-0 z-10">
                <div className="flex items-center gap-2.5">
                  <span className="material-symbols-outlined text-2xl">
                    {selectedIncident.type === 'medical'
                      ? 'medical_services'
                      : selectedIncident.type === 'security'
                      ? 'shield'
                      : selectedIncident.type === 'fire'
                      ? 'local_fire_department'
                      : 'warning'}
                  </span>
                  <div>
                    <p className="font-technical-sm text-[11px] uppercase tracking-wider opacity-90">
                      {EMERGENCY_TYPE_LABELS[selectedIncident.type] || 'Emergency'}
                    </p>
                    <p className="font-headline-lg-mobile text-base font-bold">
                      Incident #{selectedIncident.id.toUpperCase().slice(0, 8)}
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedIncident(null)}
                  className="text-on-error/80 hover:text-on-error p-1 rounded-full hover:bg-white/10 transition-colors"
                >
                  <span className="material-symbols-outlined text-lg">close</span>
                </button>
              </div>

              {/* Operator Distance & ETA Banner */}
              {operatorIncidentDistance && (
                <div className="bg-blue-50 border-b border-blue-100 px-5 py-3 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="material-symbols-outlined text-blue-600 text-lg">near_me</span>
                    <div>
                      <p className="text-[11px] font-label-md uppercase tracking-wider text-blue-700 font-bold">
                        Distance From You
                      </p>
                      <p className="text-xs font-semibold text-blue-950">
                        {operatorIncidentDistance.formatted} away
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <span className="text-[11px] uppercase tracking-wider text-blue-600 font-bold block">
                      Est. Time
                    </span>
                    <span className="text-xs font-bold text-blue-800">
                      ~{operatorIncidentDistance.eta}
                    </span>
                  </div>
                </div>
              )}

              {/* Quick Incident Info */}
              <div className="p-5 space-y-4">
                <div>
                  <h4 className="text-xs font-label-md uppercase tracking-wider text-outline font-bold mb-1">
                    Location & Description
                  </h4>
                  <p className="text-sm font-semibold text-on-surface">
                    {selectedIncident.location_description || 'Campus Block'}
                  </p>
                  {selectedIncident.description && (
                    <p className="text-xs text-on-surface-variant mt-1">
                      {selectedIncident.description}
                    </p>
                  )}
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div className="p-2.5 bg-surface-container rounded-lg">
                    <span className="text-[10px] font-technical-sm uppercase text-outline block">Status</span>
                    <span className="font-bold uppercase text-primary">{selectedIncident.status}</span>
                  </div>
                  <div className="p-2.5 bg-surface-container rounded-lg">
                    <span className="text-[10px] font-technical-sm uppercase text-outline block">Reporter</span>
                    <span className="font-bold text-on-surface truncate block">
                      {selectedIncident.reporter_name || 'Anonymous / Student'}
                    </span>
                  </div>
                </div>

                {/* Assigned Responder (if any) */}
                {selectedIncident.assigned_responder_name && (
                  <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-emerald-600 text-lg">verified</span>
                      <div>
                        <p className="text-[10px] font-label-md uppercase tracking-wider text-emerald-700 font-bold">
                          Assigned Responder
                        </p>
                        <p className="text-xs font-bold text-emerald-950">
                          {selectedIncident.assigned_responder_name}
                        </p>
                      </div>
                    </div>
                    <span className="text-[10px] px-2 py-0.5 bg-emerald-200 text-emerald-900 rounded font-semibold uppercase">
                      Active
                    </span>
                  </div>
                )}

                {/* Proximity Responder Selection */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="text-xs font-label-md uppercase tracking-wider text-outline font-bold">
                      Nearby Responders (Proximity)
                    </h4>
                    <span className="text-[11px] text-primary font-semibold">
                      {rankedResponders.length} found
                    </span>
                  </div>

                  <div className="space-y-2 max-h-56 overflow-y-auto pr-1">
                    {rankedResponders.length === 0 ? (
                      <p className="text-xs text-outline py-2 text-center">No responders available with GPS.</p>
                    ) : (
                      rankedResponders.map((resp, idx) => {
                        const isCurrentlyAssigned =
                          selectedIncident.assigned_responder_id === resp.id;

                        return (
                          <div
                            key={resp.id}
                            className={`p-2.5 rounded-xl border transition-all flex items-center justify-between ${
                              isCurrentlyAssigned
                                ? 'bg-primary/5 border-primary/40'
                                : 'bg-surface-container-lowest border-outline-variant hover:border-primary/50'
                            }`}
                          >
                            <div className="flex items-center gap-2.5 min-w-0">
                              <span
                                className={`w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-bold ${
                                  idx === 0
                                    ? 'bg-amber-100 text-amber-800'
                                    : 'bg-surface-variant text-on-surface-variant'
                                }`}
                              >
                                #{idx + 1}
                              </span>
                              <div className="min-w-0">
                                <p className="text-xs font-semibold text-on-surface truncate">
                                  {resp.name}
                                </p>
                                <div className="flex items-center gap-2 text-[11px] text-outline font-technical-sm">
                                  <span className="text-blue-600 font-semibold">
                                    {resp.formattedDistance}
                                  </span>
                                  <span>•</span>
                                  <span>ETA {resp.etaToIncident}</span>
                                </div>
                              </div>
                            </div>

                            <button
                              type="button"
                              onClick={() => handleAssignResponder(resp.id, resp.name)}
                              disabled={isAssigning || isCurrentlyAssigned}
                              className={`px-3 py-1 rounded-lg text-xs font-label-md transition-colors ${
                                isCurrentlyAssigned
                                  ? 'bg-emerald-100 text-emerald-800 font-bold cursor-default'
                                  : idx === 0
                                  ? 'bg-primary text-on-primary hover:bg-primary-container font-semibold'
                                  : 'bg-surface-variant text-on-surface hover:bg-secondary-container'
                              }`}
                            >
                              {isCurrentlyAssigned ? 'Assigned' : idx === 0 ? 'Dispatch Closest' : 'Dispatch'}
                            </button>
                          </div>
                        );
                      })
                    )}
                  </div>
                </div>
              </div>
            </div>
          ) : (
            /* Show hint to click a marker */
            activeIncidents.length > 0 && (
              <div className="absolute top-4 right-4 z-20">
                <div className="bg-surface-container-lowest border border-outline-variant rounded-xl px-4 py-3 shadow-lg flex items-center gap-2">
                  <span className="material-symbols-outlined text-primary text-lg">touch_app</span>
                  <p className="font-label-md text-xs text-on-surface-variant">
                    Click any incident marker to inspect live distance & dispatch closest responders.
                  </p>
                </div>
              </div>
            )
          )}
        </main>
      </div>
    </div>
  );
}

