export type ReportType =
  | 'suspicious_activity'
  | 'security_concern'
  | 'fire_hazard'
  | 'safety_concern'
  | 'other';

export type ReportStatus =
  | 'submitted'
  | 'under_review'
  | 'resolved'
  | 'dismissed';

export interface SafetyReport {
  id: string;
  reporter_id?: string;
  is_anonymous: boolean;
  type: ReportType;
  status: ReportStatus;
  description: string;
  latitude?: number;
  longitude?: number;
  location_description?: string;
  image_url?: string;
  created_at: string;
  updated_at: string;
  reviewed_by?: string;
  reviewed_at?: string;
}

export interface ReportFilter {
  type?: ReportType[];
  status?: ReportStatus[];
  is_anonymous?: boolean;
  date_from?: string;
  date_to?: string;
  search?: string;
}

export const REPORT_TYPE_LABELS: Record<ReportType, string> = {
  suspicious_activity: 'Suspicious Activity',
  security_concern: 'Security Concern',
  fire_hazard: 'Fire/Hazard',
  safety_concern: 'Safety Concern',
  other: 'Other',
};

export const REPORT_STATUS_LABELS: Record<ReportStatus, string> = {
  submitted: 'Submitted',
  under_review: 'Under Review',
  resolved: 'Resolved',
  dismissed: 'Dismissed',
};

export const REPORT_STATUS_COLORS: Record<ReportStatus, string> = {
  submitted: 'bg-blue-100 text-blue-800',
  under_review: 'bg-amber-100 text-amber-800',
  resolved: 'bg-green-100 text-green-800',
  dismissed: 'bg-gray-100 text-gray-500',
};
