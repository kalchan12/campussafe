'use client';

import { Sidebar } from '@/components/layout/sidebar';
import { StatCard } from '@/components/ui/stat-card';
import { IncidentCard } from '@/components/incidents/incident-card';
import { ResponderCard } from '@/components/responders/responder-card';
import { DeviceCard } from '@/components/devices/device-card';
import { CampusMap } from '@/components/maps/campus-map';
import { getIncidents, getResponders, getDevices, getDashboardStats } from '@/lib/mock';
import { getIncidentMarkers, getResponderMarkers } from '@/lib/maps';
import { useEffect, useState } from 'react';
import type { Incident } from '@/types/incident';
import type { Responder } from '@/types/responder';
import type { Device } from '@/types/device';

export default function DashboardPage() {
  const [stats, setStats] = useState<Awaited<ReturnType<typeof getDashboardStats>> | null>(null);
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [responders, setResponders] = useState<Responder[]>([]);
  const [devices, setDevices] = useState<Device[]>([]);

  useEffect(() => {
    async function loadData() {
      const [statsData, incidentsData, respondersData, devicesData] = await Promise.all([
        getDashboardStats(),
        getIncidents(),
        getResponders(),
        getDevices(),
      ]);
      setStats(statsData);
      setIncidents(incidentsData);
      setResponders(respondersData);
      setDevices(devicesData);
    }
    loadData();
  }, []);

  const activeIncidents = incidents.filter(
    (i) => !['resolved', 'cancelled'].includes(i.status)
  );

  const markers = [
    ...getIncidentMarkers(activeIncidents),
    ...getResponderMarkers(responders),
  ];

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <header className="bg-white border-b border-gray-200 px-6 py-4">
          <h1 className="text-2xl font-bold text-gray-900">Operations Dashboard</h1>
          <p className="text-sm text-gray-500 mt-1">Real-time campus safety monitoring</p>
        </header>

        <div className="p-6">
          {/* Stats */}
          {stats && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
              <StatCard
                title="Active Incidents"
                value={stats.activeIncidents}
                icon="🚨"
              />
              <StatCard
                title="Available Responders"
                value={stats.availableResponders}
                icon="👥"
              />
              <StatCard
                title="Online Devices"
                value={stats.onlineDevices}
                icon="📡"
              />
              <StatCard
                title="Pending Reports"
                value={stats.pendingReports}
                icon="📋"
              />
            </div>
          )}

          {/* Main Content */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Map */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h2 className="text-lg font-semibold text-gray-900">Campus Map</h2>
                </div>
                <div className="p-4">
                  <CampusMap markers={markers} className="h-[500px]" />
                </div>
              </div>
            </div>

            {/* Active Incidents */}
            <div className="lg:col-span-1">
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h2 className="text-lg font-semibold text-gray-900">Active Incidents</h2>
                </div>
                <div className="p-4 max-h-[500px] overflow-y-auto space-y-3">
                  {activeIncidents.slice(0, 5).map((incident) => (
                    <IncidentCard key={incident.id} incident={incident} />
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Bottom Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
            {/* Responders */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Responders</h2>
              </div>
              <div className="p-4 grid grid-cols-1 md:grid-cols-2 gap-4 max-h-[400px] overflow-y-auto">
                {responders.slice(0, 4).map((responder) => (
                  <ResponderCard key={responder.id} responder={responder} />
                ))}
              </div>
            </div>

            {/* Devices */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Devices</h2>
              </div>
              <div className="p-4 grid grid-cols-1 md:grid-cols-2 gap-4 max-h-[400px] overflow-y-auto">
                {devices.slice(0, 4).map((device) => (
                  <DeviceCard key={device.id} device={device} />
                ))}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
