'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { Badge } from '@/components/ui/badge';
import { getReports } from '@/lib/mock';
import { REPORT_TYPE_LABELS, REPORT_STATUS_LABELS, REPORT_STATUS_COLORS } from '@/types/report';
import type { SafetyReport, ReportFilter } from '@/types/report';
import { formatDateTime } from '@/lib/utils';

export default function ReportsPage() {
  const [reports, setReports] = useState<SafetyReport[]>([]);
  const [filter, setFilter] = useState<ReportFilter>({});
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function load() {
      const data = await getReports({ ...filter, search });
      setReports(data);
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
              <h1 className="text-2xl font-bold text-gray-900">Safety Reports</h1>
              <p className="text-sm text-gray-500 mt-1">
                {reports.length} total reports
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
                placeholder="Search reports..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, status: e.target.value ? [e.target.value as SafetyReport['status']] : undefined })
                }
              >
                <option value="">All Status</option>
                <option value="submitted">Submitted</option>
                <option value="under_review">Under Review</option>
                <option value="resolved">Resolved</option>
                <option value="dismissed">Dismissed</option>
              </select>
              <select
                className="px-4 py-2 border border-gray-300 rounded-lg"
                onChange={(e) =>
                  setFilter({ ...filter, is_anonymous: e.target.value === 'true' ? true : e.target.value === 'false' ? false : undefined })
                }
              >
                <option value="">All Reports</option>
                <option value="true">Anonymous</option>
                <option value="false">Named</option>
              </select>
            </div>
          </div>

          {/* Table */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">ID</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Type</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Status</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Description</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Location</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Anonymous</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Time</th>
                </tr>
              </thead>
              <tbody>
                {reports.map((report) => (
                  <tr
                    key={report.id}
                    className="border-b border-gray-100 hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="py-3 px-4 text-sm font-mono text-gray-600">
                      {report.id.slice(0, 8)}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-600">
                      {REPORT_TYPE_LABELS[report.type]}
                    </td>
                    <td className="py-3 px-4">
                      <Badge className={REPORT_STATUS_COLORS[report.status]}>
                        {REPORT_STATUS_LABELS[report.status]}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-600 max-w-[200px] truncate">
                      {report.description}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-600">
                      {report.location_description || '-'}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-600">
                      {report.is_anonymous ? '🔒 Yes' : 'No'}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-500">
                      {formatDateTime(report.created_at)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  );
}
