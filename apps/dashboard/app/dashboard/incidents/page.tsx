'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { IncidentTable } from '@/components/incidents/incident-table';
import { Button } from '@/components/ui/button';
import { getIncidents } from '@/lib/mock';
import type { Incident, IncidentFilter } from '@/types/incident';

export default function IncidentsPage() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [filter, setFilter] = useState<IncidentFilter>({});
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function load() {
      const data = await getIncidents({ ...filter, search });
      setIncidents(data);
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
              <h1 className="text-2xl font-bold text-gray-900">Incidents</h1>
              <p className="text-sm text-gray-500 mt-1">
                {incidents.length} total incidents
              </p>
            </div>
            <Button>Export CSV</Button>
          </div>
        </header>

        <div className="p-6">
          {/* Filters */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4 mb-6">
            <div className="flex items-center gap-4">
              <input
                type="text"
                placeholder="Search incidents..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, status: e.target.value ? [e.target.value as Incident['status']] : undefined })
                }
              >
                <option value="">All Status</option>
                <option value="created">Created</option>
                <option value="received">Received</option>
                <option value="assigned">Assigned</option>
                <option value="responding">Responding</option>
                <option value="arrived">Arrived</option>
                <option value="resolved">Resolved</option>
              </select>
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, type: e.target.value ? [e.target.value as Incident['type']] : undefined })
                }
              >
                <option value="">All Types</option>
                <option value="medical">Medical</option>
                <option value="security">Security</option>
                <option value="fire">Fire</option>
                <option value="accident">Accident</option>
                <option value="other">Other</option>
              </select>
            </div>
          </div>

          {/* Table */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
            <IncidentTable incidents={incidents} />
          </div>
        </div>
      </main>
    </div>
  );
}
