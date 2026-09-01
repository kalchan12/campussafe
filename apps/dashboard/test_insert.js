const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
async function run() {
  const insertData = {
    type: 'medical',
    status: 'created',
    priority: 1,
    latitude: 8.5,
    longitude: 39.2,
    location_description: 'Test',
    campus_block: 'Block A',
    description: 'Test description',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };
  const { data, error } = await supabase.from('incidents').insert(insertData).select();
  if (error) console.error("Insert Error:", error);
  else console.log("Insert Success:", data);
}
run();
