const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: 'apps/dashboard/.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
  console.log("Starting Responder Simulation...");
  
  setInterval(async () => {
    // get active incidents
    const { data: incidents } = await supabase.from('incidents').select('*').in('status', ['created', 'received', 'assigned', 'responding']);
    const { data: responders } = await supabase.from('responders').select('*').in('availability', ['available', 'busy']);
    
    if (!incidents || incidents.length === 0) {
      console.log("No active incidents. Responders standing by...");
      return;
    }
    
    const incident = incidents[0];
    const targetLat = incident.latitude || 8.5582;
    const targetLng = incident.longitude || 39.2895;
    
    for (const r of responders) {
      // Move towards incident
      const latDiff = targetLat - (r.latitude || 8.5520);
      const lngDiff = targetLng - (r.longitude || 39.2900);
      
      const step = 0.05; // 5% of the distance per tick
      
      let newLat = (r.latitude || 8.5520) + (latDiff * step);
      let newLng = (r.longitude || 39.2900) + (lngDiff * step);
      
      let newStatus = 'busy';
      if (Math.abs(latDiff) < 0.0001 && Math.abs(lngDiff) < 0.0001) {
        newLat = targetLat;
        newLng = targetLng;
      }
      
      const { error } = await supabase.from('responders').update({
        latitude: newLat,
        longitude: newLng,
        availability: newStatus,
        current_incident_id: incident.id,
        last_location_update: new Date().toISOString()
      }).eq('id', r.id);
      
      if (error) console.error("Update error for responder", r.id, error);
    }
    console.log(`Moved ${responders.length} responders towards incident ${incident.id}`);
  }, 2000);
}

run();
