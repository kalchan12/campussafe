'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
import { CampusMap } from '@/components/maps/campus-map';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { getIncidents, getResponders, getDevices } from '@/lib/mock';
import { getIncidentMarkers, getResponderMarkers } from '@/lib/maps';
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

  useEffect(() => {
    async function loadData() {
      const [incidentsData, respondersData, devicesData] = await Promise.all([
        getIncidents(),
        getResponders(),
        getDevices(),
      ]);
      setIncidents(incidentsData);
      setResponders(respondersData);
      setDevices(devicesData);
    }
    loadData();
  }, []);

  const activeIncidents = incidents.filter(
    (i) => !['resolved', 'cancelled'].includes(i.status)
  );

  const incidentMarkers = getIncidentMarkers(activeIncidents);
  const responderMarkers = getResponderMarkers(responders);

  let filteredMarkers: MapMarker[] = [];
  if (activeLayer === 'all' || activeLayer === 'incidents') {
    filteredMarkers = [...filteredMarkers, ...incidentMarkers];
  }
  if (activeLayer === 'all' || activeLayer === 'responders') {
    filteredMarkers = [...filteredMarkers, ...responderMarkers];
  }

  const layers: { key: LayerFilter; label: string; icon: string }[] = [
    { key: 'all', label: 'All Layers', icon: 'tune' },
    { key: 'incidents', label: 'Incidents', icon: 'warning' },
    { key: 'responders', label: 'Responders', icon: 'location_on' },
    { key: 'devices', label: 'Devices', icon: 'sos' },
  ];

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
                backgroundImage: 'linear-gradient(to right, #80808012 1px, transparent 1px), linear-gradient(to bottom, #80808012 1px, transparent 1px)',
                backgroundSize: '40px 40px',
              }}
            />
            <CampusMap markers={filteredMarkers} className="h-full w-full" />
          </div>

          {/* Layer Filter Pills */}
          <div className="absolute top-4 left-4 z-20 flex gap-2">
            {layers.map((layer) => (
              <button
                key={layer.key}
                onClick={() => setActiveLayer(layer.key)}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-label-md text-label-md transition-colors shadow-sm ${
                  activeLayer === layer.key
                    ? 'bg-secondary-container text-on-secondary-container border border-secondary/30'
                    : 'bg-surface-container-lowest text-on-surface-variant border border-outline-variant hover:bg-surface-variant'
                }`}
              >
                <span className="material-symbols-outlined text-lg">{layer.icon}</span>
                {layer.label}
              </button>
            ))}
          </div>

          {/* Zoom Controls */}
          <div className="absolute bottom-24 left-4 z-20 flex flex-col gap-1">
            <button className="w-10 h-10 bg-surface-container-lowest border border-outline-variant rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-variant transition-colors shadow-sm">
              <span className="material-symbols-outlined">add</span>
            </button>
            <button className="w-10 h-10 bg-surface-container-lowest border border-outline-variant rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-variant transition-colors shadow-sm">
              <span className="material-symbols-outlined">remove</span>
            </button>
          </div>
          <button className="absolute bottom-8 left-4 z-20 w-10 h-10 bg-surface-container-lowest border border-outline-variant rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-variant transition-colors shadow-sm">
            <span className="material-symbols-outlined">my_location</span>
          </button>

          {/* Incident Detail Drawer */}
          {selectedIncident ? (
            <div className="absolute top-4 right-4 z-20 w-96 bg-surface-container-lowest rounded-xl border border-outline-variant shadow-lg overflow-hidden">
              {/* Header */}
              <div className="bg-error text-on-error px-6 py-4 flex items-start justify-between">
                <div className="flex items-center gap-2">
                  <span className="material-symbols-outlined">medical_services</span>
                  <div>
                    <p className="font-technical-sm text-technical-sm uppercase tracking-wider opacity-90">
                      {EMERGENCY_TYPE_LABELS[selectedIncident.type]}
                    </p>
                    <p className="font-headline-lg-mobile text-headline-lg-mobile font-bold">
                      {selectedIncident.id.toUpperCase()}
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedIncident(null)}
                  className="text-on-error hover:opacity-80 transition-opacity"
                >
                  <span className="material-symbols-outlined">close</span>
                </button>
              </div>

              {/* KPI Cards */}
              <div className="grid grid-cols-2 gap-3 p-4">
                <div className="bg-error-container rounded-lg p-3 text-center">
                  <p className="font-technical-sm text-technical-sm text-on-error-container uppercase tracking-wider">Severity</p>
                  <p className="font-headline-lg-mobile text-headline-lg-mobile text-on-error-container font-bold">CRITICAL</p>
                </div>
                <div className="bg-secondary-container rounded-lg p-3 text-center">
                  <p className="font-technical-sm text-technical-sm text-on-secondary-container uppercase tracking-wider">Responder ETA</p>
                  <p className="font-headline-lg-mobile text-headline-lg-mobile text-primary font-bold">3m</p>
                </div>
              </div>

              {/* Metadata */}
              <div className="px-4 pb-4 space-y-3">
                <div className="flex items-center gap-3 py-2 border-t border-outline-variant">
                  <span className="material-symbols-outlined text-on-surface-variant text-lg">location_on</span>
                  <div>
                    <p className="font-technical-sm text-technical-sm text-on-surface-variant uppercase tracking-wider">Location</p>
                    <p className="font-body-md text-body-md text-on-surface">{selectedIncident.location_description}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3 py-2 border-t border-outline-variant">
                  <span className="material-symbols-outlined text-on-surface-variant text-lg">person_alert</span>
                  <div>
                    <p className="font-technical-sm text-technical-sm text-on-surface-variant uppercase tracking-wider">Reporter</p>
                    <p className="font-body-md text-body-md text-on-surface">{selectedIncident.reporter_name || 'Unknown'}</p>
                  </div>
                </div>
                {selectedIncident.assigned_responder_name && (
                  <div className="flex items-center gap-3 py-2 border-t border-outline-variant">
                    <span className="material-symbols-outlined text-on-surface-variant text-lg">location_on</span>
                    <div className="flex-1">
                      <p className="font-technical-sm text-technical-sm text-on-surface-variant uppercase tracking-wider">Responder</p>
                      <div className="flex items-center gap-2">
                        <p className="font-body-md text-body-md text-on-surface">{selectedIncident.assigned_responder_name}</p>
                        <span className="inline-flex items-center px-2 py-0.5 bg-primary/10 text-primary font-technical-sm text-technical-sm rounded">
                          En Route
                        </span>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Action Footer */}
              <div className="flex gap-3 p-4 border-t border-outline-variant">
                <Button variant="ghost" className="flex-1">
                  <span className="material-symbols-outlined text-sm mr-1.5">chat</span>
                  Connect
                </Button>
                <Button className="flex-1">
                  <span className="material-symbols-outlined text-sm mr-1.5">info</span>
                  Full Details
                </Button>
              </div>
            </div>
          ) : (
            /* Show a hint to click a marker */
            activeIncidents.length > 0 && (
              <div className="absolute top-4 right-4 z-20">
                <div className="bg-surface-container-lowest border border-outline-variant rounded-lg px-4 py-3 shadow-sm">
                  <p className="font-label-md text-label-md text-on-surface-variant">
                    <span className="material-symbols-outlined text-sm align-middle mr-1">touch_app</span>
                    Click a marker for details
                  </p>
                </div>
              </div>
            )
          )}

          {/* Auto-select first critical incident for demo */}
          {!selectedIncident && activeIncidents.find((i) => i.priority === 1) && (
            <button
              onClick={() => setSelectedIncident(activeIncidents.find((i) => i.priority === 1) || null)}
              className="absolute bottom-8 right-4 z-20 bg-error text-on-error px-4 py-2 rounded-lg font-label-md text-label-md shadow-lg animate-subtle-pulse flex items-center gap-2"
            >
              <span className="material-symbols-outlined text-sm">warning</span>
              View Critical Incident
            </button>
          )}
        </main>
      </div>
    </div>
  );
}
