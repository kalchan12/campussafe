'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { ResponderCard } from '@/components/responders/responder-card';
import { getResponders } from '@/lib/mock';
import type { Responder, ResponderFilter } from '@/types/responder';

export default function RespondersPage() {
  const [responders, setResponders] = useState<Responder[]>([]);
  const [filter, setFilter] = useState<ResponderFilter>({});
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function load() {
      const data = await getResponders({ ...filter, search });
      setResponders(data);
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
              <h1 className="text-2xl font-bold text-gray-900">Responders</h1>
              <p className="text-sm text-gray-500 mt-1">
                {responders.length} total responders
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
                placeholder="Search responders..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, status: e.target.value ? [e.target.value as Responder['status']] : undefined })
                }
              >
                <option value="">All Status</option>
                <option value="available">Available</option>
                <option value="assigned">Assigned</option>
                <option value="responding">Responding</option>
                <option value="arrived">Arrived</option>
                <option value="offline">Offline</option>
              </select>
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, role: e.target.value ? [e.target.value as Responder['role']] : undefined })
                }
              >
                <option value="">All Roles</option>
                <option value="medical">Medical</option>
                <option value="security">Security</option>
                <option value="operator">Operator</option>
                <option value="admin">Admin</option>
              </select>
            </div>
          </div>

          {/* Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {responders.map((responder) => (
              <ResponderCard key={responder.id} responder={responder} />
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
