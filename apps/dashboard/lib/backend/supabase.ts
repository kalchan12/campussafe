import { createClient } from '../supabase/client';
import type { SupabaseClient } from '@supabase/supabase-js';

// Guard the module-level initialization to avoid crashes
export const supabase: SupabaseClient = (typeof process !== 'undefined' && process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)
  ? createClient()
  : {} as SupabaseClient;

export async function checkConnection(): Promise<boolean> {
  try {
    if (!supabase.from) return false;
    const { error } = await supabase.from('incidents').select('id').limit(1);
    return !error;
  } catch {
    return false;
  }
}
