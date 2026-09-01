'use client';

import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { StatCard } from '@/components/ui/stat-card';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { CampusMap } from '@/components/maps/campus-map';
import {
  fetchIncidents,
  fetchResponders,
  fetchDevices,
  fetchDashboardStats,
} from '@/lib/data-service';
import { realtimeService } from '@/lib/realtime';
import { getIncidentMarkers, getResponderMarkers } from '@/lib/maps';
import { useEffect, useState } from 'react';
import { timeAgo, formatTime } from '@/lib/utils';
import type { Incident } from '@/types/incident';
import type { Responder } from '@/types/responder';
import type { Device } from '@/types/device';
import { EMERGENCY_TYPE_LABELS } from '@/types/incident';

export default function DashboardPage() {
  const [stats, setStats] = useState<Awaited<ReturnType<typeof fetchDashboardStats>> | null>(null);
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [responders, setResponders] = useState<Responder[]>([]);
  const [devices, setDevices] = useState<Device[]>([]);
  const [systemEvents, setSystemEvents] = useState([
    { time: '10:45 AM', description: 'SOS-ENG-01 Connection Active', color: 'bg-primary' },
    { time: '10:30 AM', description: 'Emergency Operations Center Online', color: 'bg-secondary' },
    { time: '10:15 AM', description: 'Campus Responders on Standby', color: 'bg-emerald-500' },
  ]);

  useEffect(() => {
    async function loadData() {
      const [statsData, incidentsData, respondersData, devicesData] = await Promise.all([
        fetchDashboardStats(),
        fetchIncidents(),
        fetchResponders(),
        fetchDevices(),
      ]);
      setStats(statsData);
      setIncidents(incidentsData);
      setResponders(respondersData);
      setDevices(devicesData);
    }
    loadData();

    // Subscribe to live Realtime events
    const unsubCreated = realtimeService.subscribe('INCIDENT_CREATED', (payload) => {
      const newIncident = payload.data as unknown as Incident;
      setIncidents((prev) => {
        if (prev.some((i) => i.id === newIncident.id)) return prev;
        return [newIncident, ...prev];
      });
      setStats((prev) => (prev ? { ...prev, activeIncidents: prev.activeIncidents + 1 } : null));
      setSystemEvents((prev) => [
        {
          time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          description: `LIVE SOS: ${newIncident.type?.toUpperCase() ?? 'EMERGENCY'} at ${newIncident.campus_block ?? 'Campus'}`,
          color: 'bg-error',
        },
        ...prev.slice(0, 8),
      ]);
    });

    const unsubStatus = realtimeService.subscribe('INCIDENT_STATUS_CHANGED', (payload) => {
      const updated = payload.data as unknown as Incident;
      setIncidents((prev) =>
        prev.map((i) => (i.id === updated.id ? { ...i, ...updated } : i))
      );
      setSystemEvents((prev) => [
        {
          time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          description: `Incident #${updated.id?.slice(0, 8)} status changed to ${updated.status}`,
          color: 'bg-primary',
        },
        ...prev.slice(0, 8),
      ]);
    });

    const unsubDevice = realtimeService.subscribe('DEVICE_EVENT_RECEIVED', (payload) => {
      const dev = payload.data as Record<string, unknown>;
      setSystemEvents((prev) => [
        {
          time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          description: `IoT Device Event: ${String(dev.device_id ?? 'Station')} (${String(dev.event_type ?? 'Signal')})`,
          color: 'bg-amber-600',
        },
        ...prev.slice(0, 8),
      ]);
    });

    return () => {
      unsubCreated();
      unsubStatus();
      unsubDevice();
    };
  }, []);

  const activeIncidents = incidents.filter(
    (i) => !['resolved', 'cancelled'].includes(i.status)
  );

  const criticalCount = activeIncidents.filter((i) => i.priority === 1).length;

  const markers = [
    ...getIncidentMarkers(activeIncidents),
    ...getResponderMarkers(responders),
  ];

  const availableResponders = responders.filter((r) => r.status === 'available').length;
  const busyResponders = responders.filter((r) => ['assigned', 'arrived'].includes(r.status)).length;
  const respondingResponders = responders.filter((r) => r.status === 'responding').length;

  return (
    <DashboardLayout >
      <div className="max-w-[1280px] mx-auto space-y-8">
            {/* KPIs */}
            {stats && (
              <section className="grid grid-cols-1 md:grid-cols-4 gap-6">
                <StatCard
                  title="Active Incidents"
                  value={stats.activeIncidents}
                  icon="warning"
                />
                <StatCard
                  title="Critical"
                  value={criticalCount}
                  icon="emergency"
                  variant="critical"
                />
                <StatCard
                  title="Responders Available"
                  value={stats.availableResponders}
                  icon="local_police"
                />
                <StatCard
                  title="Devices Online"
                  value={stats.onlineDevices}
                  icon="router"
                />
              </section>
            )}

            {/* Live Campus Map */}
            <section className="bg-surface-container-lowest border border-outline-variant rounded-lg p-4 h-[520px] flex flex-col relative overflow-hidden">
              <div className="flex justify-between items-center mb-4 z-10">
                <h3 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface">Live Campus Map</h3>
                <div className="flex gap-2">
                  {criticalCount > 0 && (
                    <Badge variant="critical">
                      <span className="w-2 h-2 rounded-full bg-error mr-1.5 inline-block" />
                      {criticalCount} Critical
                    </Badge>
                  )}
                  <Badge variant="warning">
                    <span className="w-2 h-2 rounded-full bg-on-tertiary-container mr-1.5 inline-block" />
                    1 Warning
                  </Badge>
                </div>
              </div>
              <div className="flex-1 relative z-0">
                <CampusMap markers={markers} className="h-full" />
              </div>
            </section>

            {/* Lower Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 pb-8">
              {/* Active Incidents Table */}
              <section className="lg:col-span-2 bg-surface-container-lowest border border-outline-variant rounded-lg p-6">
                <h3 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface mb-4">Active Incidents</h3>
                <div className="overflow-x-auto">
                  <table className="w-full text-left">
                    <thead>
                      <tr className="border-b border-outline-variant">
                        <th className="py-2 font-label-md text-label-md text-on-surface-variant">ID</th>
                        <th className="py-2 font-label-md text-label-md text-on-surface-variant">Type</th>
                        <th className="py-2 font-label-md text-label-md text-on-surface-variant">Severity</th>
                        <th className="py-2 font-label-md text-label-md text-on-surface-variant">Location</th>
                        <th className="py-2 font-label-md text-label-md text-on-surface-variant">Status</th>
                        <th className="py-2 font-label-md text-label-md text-on-surface-variant text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {activeIncidents.slice(0, 5).map((incident) => (
                        <tr key={incident.id} className="border-b border-outline-variant hover:bg-surface-container-low transition-colors group">
                          <td className="py-3 font-technical-sm text-technical-sm text-on-surface">
                            {incident.id.toUpperCase()}
                          </td>
                          <td className="py-3 font-body-md text-body-md text-on-surface">
                            {EMERGENCY_TYPE_LABELS[incident.type]}
                          </td>
                          <td className="py-3">
                            <Badge variant={incident.priority === 1 ? 'critical' : incident.priority === 2 ? 'high' : 'medium'}>
                              {incident.priority === 1 ? 'Critical' : incident.priority === 2 ? 'High' : 'Medium'}
                            </Badge>
                          </td>
                          <td className="py-3 font-body-md text-body-md text-on-surface">
                            {incident.location_description || '-'}
                          </td>
                          <td className="py-3 font-body-md text-body-md text-on-surface capitalize">
                            {incident.status}
                          </td>
                          <td className="py-3 text-right">
                            <button className="px-4 py-2 rounded text-primary border border-primary hover:bg-primary-fixed-dim/10 font-label-md text-label-md transition-colors">
                              Manage
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </section>

              {/* Sidebar Stack */}
              <div className="space-y-6">
                {/* Responder Status */}
                <section className="bg-surface-container-lowest border border-outline-variant rounded-lg p-6">
                  <h3 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface mb-4">Responder Status</h3>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-primary" />
                        <span className="font-body-md text-body-md text-on-surface">Available</span>
                      </div>
                      <span className="font-label-md text-label-md text-on-surface-variant">{availableResponders}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-on-tertiary-container" />
                        <span className="font-body-md text-body-md text-on-surface">Busy</span>
                      </div>
                      <span className="font-label-md text-label-md text-on-surface-variant">{busyResponders}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-error" />
                        <span className="font-body-md text-body-md text-on-surface">Responding</span>
                      </div>
                      <span className="font-label-md text-label-md text-on-surface-variant">{respondingResponders}</span>
                    </div>
                  </div>
                </section>

                {/* System Events */}
                <section className="bg-surface-container-lowest border border-outline-variant rounded-lg p-6">
                  <h3 className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface mb-4">System Events</h3>
                  <div className="space-y-4 border-l-2 border-outline-variant ml-2 pl-4">
                    {systemEvents.map((event, index) => (
                      <div key={index} className="relative">
                        <span className={`absolute -left-[21px] top-1 w-2.5 h-2.5 ${event.color} rounded-full border-2 border-surface-container-lowest`} />
                        <p className="font-technical-sm text-technical-sm text-on-surface-variant mb-1">{event.time}</p>
                        <p className="font-body-md text-body-md text-on-surface">{event.description}</p>
                      </div>
                    ))}
                  </div>
                </section>
              </div>
            </div>
          </div>
    </DashboardLayout>
  );
}
