import { createClient } from '../supabase/client';

export const supabase = createClient();

export async function checkConnection(): Promise<boolean> {
  try {
    const { error } = await supabase.from('incidents').select('id').limit(1);
    return !error;
  } catch {
    return false;
  }
}
