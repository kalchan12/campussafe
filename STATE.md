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
- **Emergency Taxonomy Streamlining & Sensor Distinction**:
  - User-initiated mobile emergency categories are focused directly on:
    - 🚑 **Medical**: Severe trauma, acute medical emergencies, ambulance & first aid.
    - 🛡️ **Security**: Physical threats, assaults, harassment, theft, campus police & patrol.
  - **Fire Hazard & Accident Hazard** are designated for proactive automatic triggers via campus IoT environmental and collision sensors.
- **Direct Emergency Type Selection Flow (Zero-Friction SOS)**:
  - Eliminated intermediate "Confirm SOS Alert" modal dialogs and confirmation screens (`_showSOSConfirmation` and `_buildConfirmView`).
  - Pressing the SOS button on the home page or SOS page (or triggering via hands-free shake) directly navigates to the Emergency Type Selection screen for immediate classification without unnecessary cognitive friction in emergencies.
- **Hands-Free Shake-to-SOS Detection**:
  - Implemented using `sensors_plus` in `lib/core/services/shake_detection_service.dart`.
  - Configurable sensitivity threshold (`22.0 m/s²`) and minimum consecutive shakes (3 within 800ms) with vibration haptics.
  - Full user toggle in Settings screen (`shake_to_sos_enabled`).
- **Wearable & Smartwatch Vital Organ Monitoring Sentinel**:
  - Implemented `SmartwatchVitals` model (`apps/mobile/lib/shared/models/smartwatch_vitals.dart`) capturing telemetry from typical smartwatch sensors:
    - **Photoplethysmography (PPG)**: Real-time heart rate (BPM), pulse oximetry (SpO2), heart rate variability (HRV).
    - **Electrocardiogram (ECG / EKG)**: Sinus rhythm analysis, Atrial Fibrillation (AFib), and sudden cardiac arrest / loss of pulse.
    - **Inertial Measurement Unit (IMU - High-G Accelerometer + Gyroscope)**: Hard fall impact detection coupled with post-impact immobility (unresponsive user / physical collapse).
    - **Skin Temperature Sensor**: Core thermal monitoring detecting hypothermia ($<35.0^\circ\text{C}$) and heatstroke / hyperthermia ($>39.5^\circ\text{C}$).
    - **Electrodermal Activity (EDA / GSR)**: Sympathetic nervous system arousal & acute trauma shock.
  - Implemented `SmartwatchVitalService` (`apps/mobile/lib/core/sensors/smartwatch_vital_service.dart`) evaluating clinical emergency thresholds, streaming telemetry, and orchestrating a 15-second pre-alert grace period countdown with an "I'm OK" dismissal button to prevent accidental false alarms.
  - Automated Medical SOS escalation via `SosNotifier.triggerAutomatedVitalSos()`, attaching clinical telemetry diagnostics to the incident description, notifying responders, and alerting Parent & Campus Admin (`0920304050`) via online API or background SMS fallback.
  - Created `SmartwatchVitalCard` on `HomePage` featuring live pulsing heart rate, SpO2 badge, temperature indicator, fall sentinel arming, and an interactive sensor simulation test suite.
  - Configured settings in `SettingsPage` under "EMERGENCY TRIGGERS & HARDWARE SENSING" with persistence in `SharedPreferences`.
  - Displayed live patient vital telemetry on `ActiveEmergencyPage`.
  - Full test coverage with 15 dedicated unit tests (`smartwatch_vitals_test.dart` and `smartwatch_vital_service_test.dart`) - total 72/72 tests passing.
- **System Actors & Onboarding Streamlining**:
  - Defined two primary campus user actors: **Student** (undergraduate, graduate, or resident student) and **Staff** (faculty professors, administrative staff, technicians, and campus personnel).
  - Streamlined mobile registration affiliation step to directly offer **Student** and **Staff** options.
- **Mandatory Dual Emergency Contacts Onboarding & Database Schema**:
  - Integrated two critical life-safety contacts into registration and user profiles:
    1. **Parent / Guardian**: Phone number filled in by the user with real-time validation.
    2. **University Emergency Admin**: Pre-filled campus emergency operations center hotline (**`0920304050`**).
  - Added database migration `supabase/migrations/20260920000001_emergency_contacts_and_actors.sql` adding `parent_phone`, `parent_name`, and `campus_admin_phone` (default `'0920304050'`) to `public.profiles` and updating the `handle_new_user` trigger.
  - Mirrored fields across `User` models, `AuthRepository`, `ProfileRepository`, `ProfileNotifier`, and Web Dashboard types (`apps/dashboard/types/user.ts`).
  - Added contact display and edit support in the mobile Safety Profile (`ProfilePage`).
- **Automated Dual-Recipient Offline Cellular SMS Fallback**:
  - Implemented automated dispatch in `EmergencySmsService` (`dispatchAutomatedEmergencySms`):
    - Background sending via Android `MethodChannel` (`com.campussafe/sms` using native `SmsManager`) when `SEND_SMS` permission is granted.
    - Seamless fallback to launching the native cellular SMS messenger pre-filled with both recipients (**Parent** and **University Admin `0920304050`**) and standardized distress GPS coordinates.
  - Wired into `SosNotifier.sendSOS`: automatically triggers the dual-contact emergency SMS whenever network connectivity fails or is offline, without requiring manual intervention.
  - Updated SOS sent view and ready view with one-tap hotline dialing for `0920304050` and manual SMS re-send controls.

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
8cf3ccd4 fix(mobile): resolve all static analyzer issues, unawaited futures, unused imports, and deprecation warnings
11255c39 fix(mobile): resolve FCM token registration race condition, notification channel meta-data, and deep-link tap routing
732e1c49 feat(mobile): configure Firebase Cloud Messaging and update 11-member team matrix
9b0b7067 feat(mobile): direct emergency type selection and sensor-only fire/accident alerts
d2ec20b2 docs: document system actors, registration emergency contacts, and automated offline sms
c9bcb8ef test(mobile): add unit tests for emergency contacts storage and user model
ad02e8fa feat(mobile): implement automated offline emergency sms dispatch to parent and campus admin
b18d0605 feat(mobile): streamline student and staff registration and dual emergency contacts
ace98f95 feat(mobile): add user emergency contact fields and android native sms channel
7e1ce2bd feat(backend): add emergency contacts and system actors migration and types
80ac31c3 docs: update STATE.md with mobile full screen incident overflow resolution
74cf0fa5 fix(mobile): resolve pixel overflow in full screen incident detail and map views
cb4993f9 fix(mobile): resolve horizontal overflow in building block chip on SOS screen
ba6ba8c1 fix(mobile): resolve horizontal pixel overflow in SOS screen GPS status card
20c3d4dc fix(mobile): prevent schema cache errors when viewing and deleting incidents
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
