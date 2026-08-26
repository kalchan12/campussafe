'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
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
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 h-screen">
        <TopNav showSearch searchPlaceholder="Search devices..." onSearch={setSearch} />
        <main className="flex-1 overflow-y-auto bg-background p-6">
          <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header */}
            <div>
              <h1 className="font-headline-lg text-headline-lg text-on-surface">Devices</h1>
              <p className="font-body-md text-body-md text-on-surface-variant mt-1">
                {devices.length} total devices
              </p>
            </div>

            {/* Filters */}
            <div className="bg-surface-container-lowest border border-outline-variant rounded-lg p-4">
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2 text-on-surface-variant">
                  <span className="material-symbols-outlined text-lg">tune</span>
                  <span className="font-label-md text-label-md">Filters:</span>
                </div>
                <select
                  className="px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-label-md text-label-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
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
                  className="px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-label-md text-label-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
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
    </div>
  );
}
