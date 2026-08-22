import { supabase } from './supabase';
import type { SafetyReport, ReportFilter } from '@/types/report';

export async function getReports(filter?: ReportFilter): Promise<SafetyReport[]> {
  let query = supabase
    .from('safety_reports')
    .select('*')
    .order('created_at', { ascending: false });

  if (filter?.type?.length) {
    query = query.in('type', filter.type);
  }
  if (filter?.status?.length) {
    query = query.in('status', filter.status);
  }
  if (filter?.is_anonymous !== undefined) {
    query = query.eq('is_anonymous', filter.is_anonymous);
  }
  if (filter?.date_from) {
    query = query.gte('created_at', filter.date_from);
  }
  if (filter?.date_to) {
    query = query.lte('created_at', filter.date_to);
  }
  if (filter?.search) {
    query = query.ilike('description', `%${filter.search}%`);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data || [];
}

export async function getReportById(id: string): Promise<SafetyReport | null> {
  const { data, error } = await supabase
    .from('safety_reports')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data;
}

export async function updateReportStatus(
  id: string,
  status: SafetyReport['status'],
  reviewedBy?: string
): Promise<SafetyReport> {
  const updateData: Partial<SafetyReport> = {
    status,
    updated_at: new Date().toISOString(),
  };
  if (reviewedBy) {
    updateData.reviewed_by = reviewedBy;
    updateData.reviewed_at = new Date().toISOString();
  }

  const { data, error } = await supabase
    .from('safety_reports')
    .update(updateData)
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getPendingReportsCount(): Promise<number> {
  const { count, error } = await supabase
    .from('safety_reports')
    .select('*', { count: 'exact', head: true })
    .in('status', ['submitted', 'under_review']);

  if (error) throw error;
  return count || 0;
}
