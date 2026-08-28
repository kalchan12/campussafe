'use client';

import { useState, useEffect } from 'react';
import { Sidebar } from '@/components/layout/sidebar';
import { TopNav } from '@/components/layout/top-nav';
import { Badge } from '@/components/ui/badge';
import { fetchReports } from '@/lib/data-service';
import { REPORT_TYPE_LABELS, REPORT_STATUS_LABELS } from '@/types/report';
import type { SafetyReport, ReportFilter } from '@/types/report';
import { formatDateTime } from '@/lib/utils';

export default function ReportsPage() {
  const [reports, setReports] = useState<SafetyReport[]>([]);
  const [filter, setFilter] = useState<ReportFilter>({});
  const [search, setSearch] = useState('');

  useEffect(() => {
    async function load() {
      const data = await fetchReports({ ...filter, search });
      setReports(data);
    }
    load();
  }, [filter, search]);

  const getReportStatusVariant = (status: SafetyReport['status']) => {
    switch (status) {
      case 'submitted': return 'info' as const;
      case 'under_review': return 'warning' as const;
      case 'resolved': return 'success' as const;
      case 'dismissed': return 'default' as const;
      default: return 'default' as const;
    }
  };

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 h-screen">
        <TopNav showSearch searchPlaceholder="Search reports..." onSearch={setSearch} />
        <main className="flex-1 overflow-y-auto bg-background p-6">
          <div className="max-w-[1280px] mx-auto space-y-6">
            {/* Header */}
            <div>
              <h1 className="font-headline-lg text-headline-lg text-on-surface">Safety Reports</h1>
              <p className="font-body-md text-body-md text-on-surface-variant mt-1">
                {reports.length} total reports
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
                  className="px-4 py-2 border border-outline-variant rounded bg-surface-container-lowest text-on-surface font-label-md text-label-md focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
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
            <div className="bg-surface-container-lowest border border-outline-variant rounded-lg overflow-hidden">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-outline-variant bg-surface-container-low">
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">ID</th>
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Type</th>
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Status</th>
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Description</th>
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Location</th>
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Anonymous</th>
                    <th className="text-left py-3 px-4 font-label-md text-label-md text-on-surface-variant">Time</th>
                  </tr>
                </thead>
                <tbody>
                  {reports.map((report) => (
                    <tr
                      key={report.id}
                      className="border-b border-outline-variant hover:bg-surface-container-low cursor-pointer transition-colors"
                    >
                      <td className="py-3 px-4 font-technical-sm text-technical-sm text-on-surface">
                        {report.id.toUpperCase()}
                      </td>
                      <td className="py-3 px-4 font-body-md text-body-md text-on-surface">
                        {REPORT_TYPE_LABELS[report.type]}
                      </td>
                      <td className="py-3 px-4">
                        <Badge variant={getReportStatusVariant(report.status)}>
                          {REPORT_STATUS_LABELS[report.status]}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 font-body-md text-body-md text-on-surface max-w-[200px] truncate">
                        {report.description}
                      </td>
                      <td className="py-3 px-4 font-body-md text-body-md text-on-surface">
                        {report.location_description || '-'}
                      </td>
                      <td className="py-3 px-4">
                        {report.is_anonymous ? (
                          <span className="inline-flex items-center gap-1 font-technical-sm text-technical-sm text-on-surface-variant">
                            <span className="material-symbols-outlined text-sm">lock</span> Yes
                          </span>
                        ) : (
                          <span className="font-technical-sm text-technical-sm text-on-surface-variant">No</span>
                        )}
                      </td>
                      <td className="py-3 px-4 font-technical-sm text-technical-sm text-on-surface-variant">
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
    </div>
  );
}
