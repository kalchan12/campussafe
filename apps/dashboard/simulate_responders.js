const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Try loading env from multiple candidate paths
const envPaths = [
  path.resolve(process.cwd(), '.env.local'),
  path.resolve(process.cwd(), 'apps/dashboard/.env.local'),
  path.resolve(__dirname, '.env.local'),
];

for (const p of envPaths) {
  if (fs.existsSync(p)) {
    require('dotenv').config({ path: p });
    break;
  }
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Missing NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY in environment.");
  console.error("Please ensure .env.local exists in apps/dashboard/ with Supabase credentials.");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

// Adama Science & Technology University (ASTU) campus landmarks for simulated patrol
const CAMPUS_PATROL_STATIONS = [
  { name: 'Admin EOC', lat: 8.5565, lng: 39.2910 },
  { name: 'Engineering Complex', lat: 8.5582, lng: 39.2895 },
  { name: 'North Dormitories', lat: 8.5620, lng: 39.2925 },
  { name: 'Campus Health Center', lat: 8.5595, lng: 39.2940 },
  { name: 'Student Union', lat: 8.5540, lng: 39.2935 },
  { name: 'Main Campus Gate', lat: 8.5515, lng: 39.2950 },
];

async function run() {
  console.log("==================================================");
  console.log("CampusSafe Responder Live Dispatch & Movement Simulator");
  console.log(`Supabase URL: ${supabaseUrl}`);
  console.log("==================================================");

  let tickCount = 0;

  setInterval(async () => {
    try {
      tickCount++;

      // 1. Fetch active incidents requiring response
      const { data: incidents, error: incError } = await supabase
        .from('incidents')
        .select('*')
        .in('status', ['created', 'received', 'assigned', 'responding'])
        .order('created_at', { ascending: false });

      if (incError) {
        console.error("Error fetching incidents:", incError.message);
        return;
      }

      // 2. Fetch responders
      const { data: responders, error: respError } = await supabase
        .from('responders')
        .select('*');

      if (respError) {
        console.error("Error fetching responders:", respError.message);
        return;
      }

      if (!responders || responders.length === 0) {
        console.log("No responders found in public.responders table.");
        console.log("Run migration 20260829000000_seed_mock_responders.sql or use the Web Dashboard simulation button.");
        return;
      }

      const activeIncident = incidents && incidents.length > 0 ? incidents[0] : null;

      for (let i = 0; i < responders.length; i++) {
        const r = responders[i];
        let targetLat;
        let targetLng;
        let newStatus;
        let incidentId = null;

        if (activeIncident && (r.current_incident_id === activeIncident.id || i === 0)) {
          // Responder assigned or closest responder moving towards incident
          targetLat = activeIncident.latitude || 8.5565;
          targetLng = activeIncident.longitude || 39.2910;
          incidentId = activeIncident.id;
          newStatus = 'responding';
        } else {
          // Responder on campus patrol loop
          const stationIdx = (Math.floor(tickCount / 4) + i) % CAMPUS_PATROL_STATIONS.length;
          const station = CAMPUS_PATROL_STATIONS[stationIdx];
          targetLat = station.lat;
          targetLng = station.lng;
          newStatus = 'available';
        }

        const currentLat = r.latitude || 8.5565;
        const currentLng = r.longitude || 39.2910;
        const latDiff = targetLat - currentLat;
        const lngDiff = targetLng - currentLng;
        const dist = Math.hypot(latDiff, lngDiff);

        let nextLat;
        let nextLng;

        if (dist < 0.0002) {
          nextLat = targetLat;
          nextLng = targetLng;
          if (newStatus === 'responding') {
            newStatus = 'arrived';
          }
        } else {
          const stepSize = 0.00025; // ~25 meters per step
          const ratio = Math.min(stepSize / dist, 1);
          nextLat = Number((currentLat + latDiff * ratio).toFixed(6));
          nextLng = Number((currentLng + lngDiff * ratio).toFixed(6));
        }

        await supabase
          .from('responders')
          .update({
            latitude: nextLat,
            longitude: nextLng,
            availability: newStatus,
            current_incident_id: incidentId,
            last_location_update: new Date().toISOString(),
          })
          .eq('id', r.id);
      }

      if (activeIncident) {
        console.log(`[Tick ${tickCount}] Dispatched responders moving towards incident #${activeIncident.id.slice(0, 8)} (${activeIncident.type})`);
      } else {
        console.log(`[Tick ${tickCount}] Patrolling campus: ${responders.length} active responders moving along campus routes.`);
      }
    } catch (err) {
      console.error("Simulation tick error:", err);
    }
  }, 2000);
}

run();
