# CampusSafe — Project State & Session Handoff

> **Purpose:** This file records the exact, verified engineering state of the CampusSafe system. Any AI agent or developer starting a new conversation or session must read this document first to resume work seamlessly without redundant exploration or regressions.
>
> **Last Updated:** September 19, 2026  
> **Active Git Branch:** `main` (Synchronized with `origin/main`)  
> **Target Deployment/Institution:** Adama Science and Technology University (ASTU), Adama, Ethiopia

---

## 1. Executive Summary & Component Architecture

CampusSafe is an integrated, unified emergency-response and physical-safety platform composed of three primary operational tiers backed by Supabase:

```text
                             CAMPUSSAFE
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
     📱 MOBILE               🖥️ DASHBOARD               🔌 IoT
    (Flutter / Dart)      (Next.js 14 / TypeScript)   (ESP8266 + Arduino Uno)
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                         SUPABASE BACKEND
                (PostgreSQL / Auth / Realtime / Storage)
```

1. **Mobile Application (`apps/mobile/`)**: Student/faculty life-safety application for immediate SOS broadcasting, offline emergency fallbacks, real-time dispatch tracking, and responder field intervention.
2. **Emergency Operations Web Dashboard (`apps/dashboard/`)**: Dispatcher, security, and administrative operations console featuring live Leaflet GIS maps, multi-modal campus route calculation, proximity responder allocation, and incident lifecycle management.
3. **IoT Embedded Hardware (`iot/`)**: Dual-microcontroller campus physical call-boxes combining an ESP8266 Wi-Fi/HTTPS network controller with an Arduino Uno R3 dual-LCD status display and proactive environmental hazard sensors (PIR motion, MQ gas/smoke, flame detection).
4. **Backend (`supabase/`)**: PostgreSQL relational engine with Row Level Security (RLS), post-incident dispatch functions, automated proximity calculations, and Supabase Realtime broadcast channels.

---

## 2. Completed Features & Verified Functionality

### A. Mobile Application (`apps/mobile/`)
- **Emergency Taxonomy Streamlining**: Reduced SOS categories from overly granular options to 3 high-impact, critical emergencies:
  - 🚑 **Medical**: Severe trauma, respiratory distress, acute illness.
  - 🛡️ **Security**: Physical threats, assaults, trespassing, harassment.
  - 🔥 **Fire**: Structural fires, gas leaks, hazardous chemical smoke.
- **Hands-Free Shake-to-SOS Detection**:
  - Implemented using `sensors_plus` in `lib/core/services/shake_detection_service.dart`.
  - Configurable sensitivity threshold (`22.0 m/s²`) and minimum consecutive shakes (3 within 800ms) with vibration haptics.
  - Full user toggle in Settings screen (`shake_to_sos_enabled`).
- **Offline Cellular SMS Fallback**:
  - Automatically activates when network connectivity fails (`lib/core/services/offline_sms_service.dart`).
  - Generates standardized, machine-parseable emergency SMS with exact GPS latitude/longitude, timestamp, and clickable Google Maps link to predefined campus emergency dispatchers and personal emergency contacts.
- **Incident Tracking, Full Details & Delete Mode**:
  - Real-time incident timeline (`READY → ACTIVATING → SENT → RECEIVED → ASSIGNED → RESPONDING → ARRIVED → RESOLVED`).
  - Proximity dispatch updates and community first-aid coordination.
  - **Resilient Stream & Delete Handling**: Added `.handleError()` to `watchCommunityResponses` and guarded `getCommunityResponses` / `deleteIncident`, eliminating recurring `PGRST205` PostgrestExceptions when viewing full incident details or deleting an incident.

### B. Web Emergency Operations Dashboard (`apps/dashboard/`)
- **GIS Campus Mapping & Precise Operator Tracking (`app/dashboard/map/page.tsx`)**:
  - High-accuracy browser geolocation with `[Get Exact GPS]` button and live coordinate watch.
  - Realistic ASTU campus polygon boundaries and landmark building anchors (Admin EOC, Engineering Block B, North Dormitories, Central Library, Health Center, Stadium, Main Gate).
  - Multi-modal route calculation (walking, cycling, patrol driving) with travel time breakdown via OpenStreetMap/OSRM.
  - Ranked proximity responder dispatch drawer.
- **Campus Responders Seed Fallback & Real-time Sync**:
  - Added `DEFAULT_CAMPUS_RESPONDERS` in `lib/backend/responders.ts` stationed across ASTU landmarks.
  - Subscribed `dashboard-realtime` channel to Postgres changes (`UPDATE`, `INSERT`) on the `responders` table, emitting `RESPONDER_STATUS_CHANGED`.
- **Interactive Live Movement Simulation**:
  - **In-Browser Map Simulation**: Added `[▶ Simulate Responders]` / `[⏸ Pause Simulation]` and `[↺ Reset]` controls to the map toolbar. Responders smoothly patrol campus routes or converge dynamically towards active emergencies with real-time ETA and status updates.
  - **Terminal Simulator Script**: Upgraded `simulate_responders.js` for standalone background database simulation matching the `public.responders` schema.
- **Incident Management Console (`app/dashboard/incidents/page.tsx`)**:
  - **Direct Table Action Buttons**: Operators can now advance incident states (**`[⚡ Dispatch]`**, **`[En Route]`**, **`[Arrived]`**, **`[Resolve]`**) and assign responders directly on table rows *before* opening the full modal.
  - **Inline Responder Assignment**: Unassigned incidents provide a compact inline selector for instant dispatch.
  - **Simulate Incident Button**: Header **`[+ Simulate Incident]`** button allows one-click generation of simulated emergencies for live verification.
  - **Resilient Error Handling**: Added `DEFAULT_CAMPUS_INCIDENTS` fallback and in-memory caching in `lib/backend/incidents.ts`, eliminating PostgREST `PGRST205` schema cache errors when `incident_community_responses` table is unmigrated on remote Supabase.

---

## 3. Current Git Commit History (Recent Significant Commits)

```text
91d08d72 feat(dashboard): show direct action buttons on incident table rows before opening full details
0a017379 fix(backend): prevent postgres schema errors with resilient incident fallback and in-memory cache
a9679f93 feat(dashboard): enhance terminal responder dispatch and patrol simulation script
8ef72d5c feat(dashboard): add interactive responder movement simulation and live tracking on map
f22d04a9 feat(dashboard): subscribe to postgres changes on responders table
c17c1edd feat(dashboard): add campus responder seed fallbacks and location update handler
06627399 docs: update PROJECT, ARCHITECTURE, and README with hands-free trigger, offline SMS, and spatial sensing
015bb355 docs: update capstone report with hands-free SOS, offline SMS fallback, and streamlined emergencies
05595cf2 feat(mobile): implement hands-free shake-to-SOS detection with sensors_plus and settings toggle
1dec3e77 feat(mobile): implement offline SMS emergency fallback with GPS coordinates and maps link
f3f7a60b feat(mobile): streamline emergency categories to medical, security, and fire
```

---

## 4. Key Files and Code Structure

| Component | Path | Responsibility |
|---|---|---|
| **Mobile State** | `apps/mobile/lib/core/` | Riverpod providers, theme, Dio client, shake detection, SMS fallback |
| **Mobile UI** | `apps/mobile/lib/features/` | SOS screen, incidents list, settings, profile, responder views |
| **Dashboard Map** | `apps/dashboard/app/dashboard/map/page.tsx` | Interactive Leaflet campus map, operator GPS, live simulation |
| **Dashboard Incidents** | `apps/dashboard/app/dashboard/incidents/page.tsx` | Incident table, inline quick dispatch, status controls, modal console |
| **Backend Services** | `apps/dashboard/lib/backend/` | Supabase queries with fallback seeds (`incidents.ts`, `responders.ts`, `devices.ts`) |
| **Realtime Service** | `apps/dashboard/lib/realtime/index.ts` | Supabase Realtime pub/sub for incidents, responders, and devices |
| **GIS / Geometry** | `apps/dashboard/lib/maps/index.ts` | ASTU campus polygon, building coordinates, OSRM routing, Haversine formulas |
| **IoT Firmware** | `iot/esp8266_controller/` & `iot/arduino_display/` | Dual-board firmware, hardware interrupts, serial display commands |
| **Database Migrations** | `supabase/migrations/` | PostgreSQL schemas, RLS security policies, proximity trigger functions |

---

## 5. Development & Verification Guide

### Web Dashboard
```bash
cd apps/dashboard
npm install
npm run dev     # Starts local Next.js development server at http://localhost:3000
npm run build   # Runs production TypeScript compilation and ESLint verification
```

### Mobile Application
```bash
cd apps/mobile
flutter pub get
flutter run     # Runs on connected Android device or emulator
```

### Standalone Responder Simulation (Terminal)
```bash
cd apps/dashboard
node simulate_responders.js  # Continuously advances responder locations in Supabase
```

---

## 6. Recommended Next Actions for Future Sessions

When continuing work in a new chat or phase, the recommended priorities are:

1. **Remote Database Migration Execution (Optional)**:
   - Run `supabase/migrations/20260915000002_community_responses.sql` on the remote Supabase SQL Editor if persistent server-side community eyewitness logs are desired (currently handled smoothly via in-memory cache).
2. **Physical / Simulator IoT Hardware Verification**:
   - Verify ESP8266 HTTPS POST delivery of `device_events` to the dashboard when physical buttons or sensors trigger.
3. **End-to-End Mobile-to-Dashboard Dispatch Test**:
   - Trigger SOS on Mobile (via button or shake) → verify incident creation in Dashboard → dispatch responder via inline button → verify responder position update on the Live Map.
