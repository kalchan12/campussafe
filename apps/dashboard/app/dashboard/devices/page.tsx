'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { DeviceCard } from '@/components/devices/device-card';
import { getDevices } from '@/lib/mock';
import type { Device, DeviceFilter } from '@/types/device';

export default function DevicesPage() {
  const [devices, setDevices] = useState<Device[]>([]);
  const [filter, setFilter] = useState<DeviceFilter>({});
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function load() {
      const data = await getDevices({ ...filter, search });
      setDevices(data);
    }
    load();
  }, [filter, search]);

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <header className="bg-white border-b border-gray-200 px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Devices</h1>
              <p className="text-sm text-gray-500 mt-1">
                {devices.length} total devices
              </p>
            </div>
          </div>
        </header>

        <div className="p-6">
          {/* Filters */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4 mb-6">
            <div className="flex items-center gap-4">
              <input
                type="text"
                placeholder="Search devices..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, type: e.target.value ? [e.target.value as Device['type']] : undefined })
                }
              >
                <option value="">All Types</option>
                <option value="sos_station">SOS Station</option>
                <option value="environmental_node">Environmental Node</option>
                <option value="security_node">Security Node</option>
                <option value="warning_node">Warning Node</option>
              </select>
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, status: e.target.value ? [e.target.value as Device['status']] : undefined })
                }
              >
                <option value="">All Status</option>
                <option value="online">Online</option>
                <option value="offline">Offline</option>
                <option value="maintenance">Maintenance</option>
                <option value="error">Error</option>
              </select>
            </div>
          </div>

          {/* Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {devices.map((device) => (
              <DeviceCard key={device.id} device={device} />
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
