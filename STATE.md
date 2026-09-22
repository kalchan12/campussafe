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

- **HomePage White Screen & Resilient Supabase Initialization Resolution**:
  - Resolved blank white screen on `HomePage` caused by an unhandled assertion failure (`You must initialize the supabase instance before calling Supabase.instance`) when `ProfileNotifier` and repository providers accessed `Env.supabase` before Supabase was initialized or when offline.
  - Hardened `Env.isConfigured` in `apps/mobile/lib/core/config/env.dart` to check that `Supabase.instance` is safely initialized, preventing premature client access and enabling graceful offline/mock fallback.
  - Wrapped `Env.init()` in `main.dart` with `try-catch` to eliminate startup exceptions.
  - Added widget test suite in `apps/mobile/test/features/home/home_page_test.dart` verifying `HomePage` rendering, greetings, SOS triggers, vital sentinel cards, emergency type tiles, and guest mode banners.
  - Full test coverage across entire mobile app suite (78/78 unit and widget tests passing with 0 analyzer issues).
- **Privacy-First Informed Consent & Sensor Opt-In Architecture**:
  - Re-architected mobile registration onboarding into a **5-step flow** (`Account` → `Role` → `Contacts` → `Consent` → `Campus`).
  - Strict **opt-in by default** for phone motion sensors (Shake-to-SOS) and wear biometric telemetry (Smartwatch Vital Sentinel). Both default to `false` for healthy students/staff who do not require health sensor monitoring.
  - Transparent informed consent agreement: *"I give informed consent for local emergency sensor processing on this device. I understand my data is processed on-device and I can toggle or revoke this consent at any time in Settings."*
  - **Zero Passive Tracking Guarantee**: University operators and administrators CANNOT passively track real-time locations or monitor student health vitals during normal routines. Accelerometer spikes and smartwatch biometrics are evaluated strictly on-device, and are transmitted ONLY when an emergency occurs and an active SOS is dispatched.
  - **Revocable Consent & Settings Controls**: Added *"Zero Passive Tracking Architecture"* banner in `SettingsPage`, allowing students to toggle sensors ON/OFF anytime. Added *"Sensor Consent & Legal Rights"* dialog detailing GDPR/medical data minimization principles.
  - **HomePage Opt-In Card**: When monitoring is disabled, `SmartwatchVitalCard` displays a non-intrusive opt-in card with an *"Opt In"* button and informed consent modal dialog for users with medical conditions.
  - Created widget test `apps/mobile/test/features/auth/registration_consent_test.dart` verifying 5-step flow and consent step.
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
  - **Disconnected State & Zeroed Organ Values**:
    - When a smartwatch is not paired or disconnected, organ metric readings are zeroed (`0 BPM`, `0.0% SpO2`, `0.0°C Temp`, and `0.0 ms HRV`).
    - Emergency alarm thresholds explicitly check `isConnected`: 0 readings when disconnected are safely suppressed and never trigger accidental medical dispatch.
    - Clinical summary returns `No Smartwatch Connected (Vitals Unavailable - Sensor Offline)`.
    - `SmartwatchVitalCard` displays a persistent guidance banner: *"Connect your smartwatch to see live vital data"* with a quick-action **[Connect Watch]** button.
    - Added interactive **[Connect Smartwatch Sensor]** and **[Disconnect Smartwatch]** toggles in the bottom testing sheet.
    - Resolved async preference loading race conditions ensuring state changes and test simulations are reliably retained.
  - Automated Medical SOS escalation via `SosNotifier.triggerAutomatedVitalSos()`, attaching clinical telemetry diagnostics to the incident description, notifying responders, and alerting Parent & Campus Admin (`0920304050`) via online API or background SMS fallback.
  - Created `SmartwatchVitalCard` on `HomePage` featuring live pulsing heart rate, SpO2 badge, temperature indicator, fall sentinel arming, and an interactive sensor simulation test suite.
  - Configured settings in `SettingsPage` under "EMERGENCY TRIGGERS & HARDWARE SENSING" with persistence in `SharedPreferences`.
  - Displayed live patient vital telemetry on `ActiveEmergencyPage`.
  - Full test coverage across entire mobile app suite (76/76 unit and widget tests passing with 0 analyzer issues).
- **SOS Page Layout & Text RenderFlex Overflow Resolution**:
  - Resolved RenderFlex overflow warnings on compact mobile screens (320px–360px widths) across all SOS page views (`apps/mobile/lib/features/sos/presentation/pages/sos_page.dart`):
    - Wrapped long action button labels (`Direct Dial Campus Dispatch (0920304050)`, `Send Offline Emergency SMS (Parent & Admin)`, `Continue to Location Confirmation`, `Open SMS Messenger...`, `Track Active Emergency on Map`, etc.) in `FittedBox(fit: BoxFit.scaleDown)` to guarantee dynamic downscaling without clipping.
    - Replaced fixed padding columns in `_buildSendingView` and `_buildReceivedView` with `SingleChildScrollView` to prevent vertical overflows on small devices.
    - Constrained header title and situation details with `Expanded` and `TextOverflow.ellipsis`.
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
a8c2d651 feat(privacy): enforce opt-in default for phone and wear sensors with zero passive tracking guarantee
23e49ca3 feat(auth): add 5-step registration onboarding with opt-in health sensors and informed consent
81b90392 feat(mobile): zero organ readings when smartwatch is disconnected with pairing banner
c1da7c06 fix(mobile): resolve layout and text RenderFlex overflow issues in SOS page views
15e3d6ec feat(mobile): add smartwatch vital organs and health monitoring sentinel with automated emergency escalation
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
