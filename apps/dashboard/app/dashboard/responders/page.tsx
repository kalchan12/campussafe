'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
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
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 h-screen">
        <TopNav showSearch searchPlaceholder="Search responders..." onSearch={setSearch} />
        <main className="flex-1 overflow-y-auto bg-background p-6">
          <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header */}
            <div>
              <h1 className="font-headline-lg text-headline-lg text-on-surface">Responders</h1>
              <p className="font-body-md text-body-md text-on-surface-variant mt-1">
                {responders.length} total responders
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
                  className="px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-label-md text-label-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
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
    </div>
  );
}
