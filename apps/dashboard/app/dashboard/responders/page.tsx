'use client';

import { useState, useEffect } from 'react';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { fetchResponders } from '@/lib/data-service';
import type { Responder, ResponderFilter } from '@/types/responder';
import { timeAgo } from '@/lib/utils';

export default function RespondersPage() {
  const [responders, setResponders] = useState<Responder[]>([]);
  const [filter, setFilter] = useState<ResponderFilter>({});
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function load() {
      const data = await fetchResponders({ ...filter, search });
      setResponders(data);
    }
    load();
  }, [filter, search]);

  return (
    <DashboardLayout showSearch searchPlaceholder="Search responders..." onSearch={setSearch}>
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

            {/* Data Table */}
            <div className="bg-surface-container-lowest border border-outline-variant rounded-lg overflow-hidden shadow-sm">
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-surface-variant/50 border-b border-outline-variant">
                      <th className="px-6 py-4 font-label-md text-xs uppercase tracking-wider text-outline font-bold">Responder</th>
                      <th className="px-6 py-4 font-label-md text-xs uppercase tracking-wider text-outline font-bold">Role</th>
                      <th className="px-6 py-4 font-label-md text-xs uppercase tracking-wider text-outline font-bold">Status</th>
                      <th className="px-6 py-4 font-label-md text-xs uppercase tracking-wider text-outline font-bold">Current Assignment</th>
                      <th className="px-6 py-4 font-label-md text-xs uppercase tracking-wider text-outline font-bold text-right">Last Active</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-outline-variant/50">
                    {responders.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="px-6 py-12 text-center text-on-surface-variant font-body-md">
                          No responders found matching your criteria.
                        </td>
                      </tr>
                    ) : (
                      responders.map((responder) => {
                        const statusColor = 
                          responder.status === 'available' ? 'bg-success/10 text-success' :
                          responder.status === 'responding' ? 'bg-error/10 text-error' :
                          responder.status === 'offline' ? 'bg-surface-variant text-on-surface-variant' :
                          'bg-warning/10 text-warning-dark';
                        
                        return (
                          <tr key={responder.id} className="hover:bg-surface-variant/30 transition-colors group">
                            <td className="px-6 py-4">
                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-primary-fixed rounded-full flex items-center justify-center shrink-0">
                                  <span className="font-label-md text-label-md text-primary font-bold">
                                    {responder.name.split(' ').map(n => n[0]).join('')}
                                  </span>
                                </div>
                                <div>
                                  <p className="font-body-md text-sm text-on-surface font-semibold group-hover:text-primary transition-colors">{responder.name}</p>
                                  <p className="font-technical-sm text-xs text-on-surface-variant">{responder.email}</p>
                                </div>
                              </div>
                            </td>
                            <td className="px-6 py-4">
                              <span className="font-medium text-on-surface capitalize text-sm">{responder.role}</span>
                            </td>
                            <td className="px-6 py-4">
                              <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold capitalize ${statusColor}`}>
                                {responder.status}
                              </span>
                            </td>
                            <td className="px-6 py-4">
                              {responder.current_incident_type ? (
                                <div className="flex items-center gap-1.5">
                                  <span className="w-2 h-2 rounded-full bg-error animate-pulse"></span>
                                  <span className="font-medium text-on-surface capitalize text-sm">{responder.current_incident_type} Incident</span>
                                </div>
                              ) : (
                                <span className="text-outline text-sm">—</span>
                              )}
                            </td>
                            <td className="px-6 py-4 text-right">
                              <span className="font-medium text-on-surface text-sm">
                                {timeAgo(responder.last_active)}
                              </span>
                            </td>
                          </tr>
                        );
                      })
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
    </DashboardLayout>
  );
}
