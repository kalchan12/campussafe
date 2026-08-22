import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export async function checkConnection(): Promise<boolean> {
  try {
    const { error } = await supabase.from('incidents').select('id').limit(1);
    return !error;
  } catch {
    return false;
  }
}
