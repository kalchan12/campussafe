# CampusSafe — Master Development Plan

> **Living document:** Update this file whenever project progress, architecture, scope, or priorities change.

## 1. Overall Strategy

CampusSafe has three primary components:

```text
                 CAMPUSSAFE
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
    MOBILE       DASHBOARD        IoT
       |             |             |
       +-------------+-------------+
                     |
                  Backend
                     |
                 Database
```

Develop incrementally:

```text
Foundation
   ↓
Architecture/Data Model
   ↓
Backend
   ↓
Mobile + Dashboard Foundations
   ↓
End-to-End SOS
   ↓
Responder Workflow
   ↓
Realtime
   ↓
IoT
   ↓
Security Hardening
   ↓
Testing
   ↓
Demo/Documentation
```

## 2. Status Legend

```text
[ ] Not started
[~] In progress
[x] Completed
[!] Blocked
[-] Deferred
```

# Phase 0 — Project Foundation

## Global
- [ ] Repository structure.
- [ ] Documentation.
- [ ] Environment-variable strategy.
- [ ] Git workflow.
- [ ] Linting/formatting.
- [ ] Shared naming conventions.

## Mobile
- [x] Flutter project.
- [x] Folder architecture.
- [x] Theme/design system (Material 3 with CampusSafe tokens).
- [x] Navigation (GoRouter with bottom nav).
- [x] State-management approach (Riverpod).
- [x] API/service layer (Dio).

## Dashboard
- [x] Next.js project.
- [x] Dashboard architecture.
- [x] TypeScript.
- [x] UI system.
- [x] Sidebar/navigation.
- [x] API/service layer.

## IoT
- [ ] ESP32 board selection.
- [ ] Firmware structure.
- [ ] Device identity format.
- [ ] Event format.
- [ ] Hardware test workflow.

# Phase 1 — Architecture and Data Model

- [ ] User model.
- [ ] Role model.
- [ ] Responder model.
- [ ] Incident model.
- [ ] Device model.
- [ ] Safety report model.
- [ ] Audit event model.
- [ ] Campus location model.
- [ ] Incident lifecycle.
- [ ] Responder lifecycle.
- [ ] Device lifecycle.
- [ ] Shared API contracts.
- [ ] Realtime event contracts.

Incident lifecycle:

```text
Created → Received → Assigned → Responding → Arrived → Resolved
```

# Phase 2 — Backend Foundation

- [x] Supabase environment (supabase_flutter package integrated, Env.init() with Supabase.initialize()).
- [x] PostgreSQL (schema migration 20260828000001_initial_schema.sql).
- [x] Authentication (Supabase Auth — signIn, signUp, signOut, password reset, session restore).
- [x] Initial migrations (backend/migrations/ — 3 files: schema, RLS, seed).
- [x] User profiles (profiles table, profile auto-create trigger, ProfileRepository).
- [x] Roles (role column in profiles: student, medical_responder, security_responder, operator, administrator, staff).
- [x] Responders (represented via role on profiles; responder-specific queries in IncidentRepository).
- [x] Campus locations (campus_blocks table with seed data for 8 blocks).
- [x] Incidents (incidents table, IncidentRepository with create/read/update/stream).
- [x] Devices (devices table ready for IoT integration).
- [x] Safety reports (safety_reports table, SafetyReportRepository).
- [x] Audit events (incident_status_history table with auto-trigger).
- [x] Row Level Security (RLS migration 20260828000002_rls_policies.sql — all tables secured).
- [x] Realtime (Supabase Realtime enabled on incidents, history, reports, devices, device_events tables; watchActiveIncidents/watchIncident streams in IncidentRepository).
- [x] Backend services (AuthRepository, ProfileRepository, IncidentRepository, SafetyReportRepository, NotificationTokenService).
- [x] Error strategy (all repositories return Result<T> with Left/Right; UI receives understandable errors).
- [x] Seed/test data (campus_blocks and devices seeded in migration 3).

**Milestone:** Backend can safely create and retrieve a complete incident.

# Phase 3 — Mobile

## Foundation
- [x] Welcome/splash (Animated splash screen with router transition).
- [x] Login (Supabase Auth connected — real signIn with dev bypass; loading state; error snackbar).
- [x] Registration (Supabase Auth connected — real signUp with 4-step onboarding; dev bypass).
- [x] Role selection.
- [x] Profile (UI implemented; ProfileRepository ready for backend connection).
- [ ] Permissions.
- [x] Location permissions & GPS capture (Geolocator position stream and live permission checks).
- [x] Notifications (FCM initialized in main.dart; NotificationService with foreground/background/tap handling; token stored in Supabase notification_tokens; flutter_local_notifications for foreground display).
- [x] Navigation (AppBottomNavBar; auth-aware GoRouter redirect added).
- [ ] Loading/error/empty states.

## User Features
- [x] Home (per Stitch design with SOS, emergency types, safety network).
- [x] SOS activation (press-and-hold with progress ring).
- [x] Emergency type selection (bento grid).
- [ ] Incident submission.
- [x] Active incident tracking (per Stitch tracking design).
- [x] Realtime GPS Incident Map & Live Navigation (Interactive FlutterMap with live user pulsing beacon, 380px full-width embedded map, fullscreen modal, and native Google Maps navigation launcher).
- [ ] History.
- [x] Alerts & Campus Broadcasts Hub (Live broadcasts, severity color badges, acknowledge flow, filter chips, and interactive advisory details).
- [x] Safety Action Protocols & 24/7 Escort Guide (Expandable emergency guidelines and night safety escort helpline quick dial).
- [x] Anonymous reporting & hazard submission (Confidential safety concern form with category selection, anonymous switch, and live state integration).
- [ ] Settings.

## Responder Features
- [ ] Responder home.
- [ ] Availability.
- [ ] Active incidents.
- [ ] Incident detail.
- [ ] Accept/decline.
- [ ] En route.
- [ ] Arrived.
- [ ] Resolve.

**Milestone:** User can submit an SOS and responder can receive/update it.

# Phase 4 — Web Dashboard

## Foundation
- [x] Authentication (Stitch EOC login UI implemented 2026-08-26).
- [~] Role-based access.
- [x] Sidebar (Stitch Material Design 3 light layout with Material Symbols).
- [x] Overview (Stitch Operations Center KPI metrics, live preview, incident/responder summary).
- [x] System status.

## Operations
- [x] Live incidents (Stitch incident management table with severity badges, filters, pagination).
- [x] Incident detail (Stitch live map drawer & incident cards).
- [x] Live campus map (Dedicated interactive map with layer toggles, marker pulses, and detail drawer).
- [x] Responder management (Responder directory with status indicators and search filters).
- [~] Assignment.
- [~] Escalation.
- [~] Resolution.
- [~] Notifications.

## Infrastructure
- [x] Device management (IoT node monitoring grid with type and status filters).
- [x] Device status.
- [~] Telemetry.
- [~] Device events.

## Administration
- [~] User management.
- [x] Reports (Safety report review table with anonymous flags).
- [~] Analytics.
- [~] Audit logs.
- [x] Settings (Configurable audio alerts, map display, refresh interval).

**Milestone:** Operator can monitor, assign, follow, and resolve incidents (Stitch UI foundation fully integrated).

# Phase 5 — Core Emergency Workflow

This is the highest-value milestone.

```text
Mobile SOS
   ↓
Location
   ↓
Backend Incident
   ↓
Relevant Responder
   ↓
Notification
   ↓
Acceptance
   ↓
Dashboard Update
   ↓
User Update
   ↓
Arrival
   ↓
Resolution
```

- [ ] Mobile incident creation.
- [ ] Validation.
- [ ] Location storage.
- [ ] Emergency type.
- [ ] Eligible responders.
- [ ] Responder ranking.
- [ ] Notification.
- [ ] Status updates.
- [ ] Realtime updates.
- [ ] Dashboard visibility.
- [ ] User visibility.
- [ ] Incident timeline.

**Rule:** Do not prioritize advanced IoT features over a reliable core SOS workflow.

# Phase 6 — Location and Routing

- [ ] Campus buildings.
- [ ] Responder work/base locations.
- [x] GPS capture (Live mobile Geolocator position stream and permission checks).
- [ ] Coordinate normalization.
- [ ] Role filtering.
- [ ] Availability filtering.
- [x] Distance calculation (Haversine formula distance computation and formatting in meters/km).
- [x] External Map & Turn-by-Turn Navigation (Google Maps URL launcher for turn-by-turn directions).
- [ ] Responder ranking.
- [ ] Configurable rules.
- [ ] Missing-location handling.
- [ ] No-responder handling.

Optional:
- [ ] Nearby-block alerts.
- [ ] 100 m radius.
- [ ] 200 m radius.
- [ ] Community assistance.

# Phase 7 — Realtime

- [ ] Incident updates.
- [ ] Responder updates.
- [ ] Dashboard live updates.
- [ ] Mobile active-incident updates.
- [ ] Device status updates.
- [ ] Notifications.
- [ ] Reconnection handling.
- [ ] Offline/error states.

# Phase 8 — IoT

## SOS Station
- [ ] ESP32.
- [ ] Physical button.
- [ ] LEDs.
- [ ] Buzzer.
- [ ] Device ID.
- [ ] Wi-Fi.
- [ ] Backend communication.
- [ ] SOS event.
- [ ] Heartbeat.
- [ ] Dashboard status.

## Environmental Node
- [ ] DHT22.
- [ ] MQ-2.
- [ ] PIR.
- [ ] Telemetry.
- [ ] Backend ingestion.
- [ ] Device status.
- [ ] Event rules.

## Security Node
- [ ] RC522.
- [ ] RFID tags.
- [ ] Reed switch.
- [ ] PIR.
- [ ] Access events.
- [ ] Suspicious-event logic.

## Optional Warning Node
- [ ] Buzzer.
- [ ] LEDs.
- [ ] Backend command.
- [ ] Acknowledgement.

# Phase 9 — Anonymous Reporting

- [ ] Guest mode.
- [ ] Anonymous report.
- [ ] Location.
- [ ] Description.
- [ ] Optional image.
- [ ] Optional voice note.
- [ ] Report ID.
- [ ] Dashboard visibility.
- [ ] Status.
- [ ] Privacy controls.

# Phase 10 — Security Hardening

- [ ] Authentication review.
- [ ] Authorization review.
- [ ] RBAC review.
- [ ] RLS review.
- [ ] API validation.
- [ ] Secret handling.
- [ ] Device authentication.
- [ ] Location privacy.
- [ ] Anonymous-report privacy.
- [ ] Audit logging.
- [ ] Session management.
- [ ] Unauthorized-access tests.
- [ ] IDOR tests.
- [ ] Privilege-escalation tests.
- [ ] Invalid-device-event tests.
- [ ] Malicious-input tests.

# Phase 11 — Testing and Integration

## Unit
- [ ] Mobile.
- [ ] Dashboard.
- [ ] Backend.
- [ ] Routing.
- [ ] Device parsing.

## Integration
- [ ] Mobile ↔ Backend.
- [ ] Dashboard ↔ Backend.
- [ ] IoT ↔ Backend.
- [ ] Realtime.
- [ ] Authentication.
- [ ] Notifications.

## End-to-End
- [ ] Mobile SOS.
- [ ] Responder assignment.
- [ ] Dashboard.
- [ ] Response.
- [ ] Resolution.
- [ ] Anonymous report.
- [ ] IoT SOS.
- [ ] IoT event.

## Failure Testing
- [ ] No network.
- [ ] GPS unavailable.
- [ ] Backend unavailable.
- [ ] Responder unavailable.
- [ ] Device offline.
- [ ] Notification failure.
- [ ] Duplicate event.
- [ ] Invalid event.
- [ ] Unauthorized request.

# Phase 12 — Final Demonstration

### Scenario 1 — Medical SOS
```text
Student → SOS → Location → Incident → Medical responder
→ Accept → Dashboard → Resolve
```

### Scenario 2 — Physical SOS
```text
Button → ESP32 → Wi-Fi → Backend → Incident
→ Dashboard → Responder
```

### Scenario 3 — Anonymous Report
```text
Guest → Anonymous report → Location → Dashboard → Security
```

### Scenario 4 — IoT Event
```text
Sensor → ESP32 → Backend → Event processing → Alert
→ Dashboard + responder
```

---

# Mobile UI Implementation (Stitch Design) — Completed 2026-08-25

## Screens Implemented
- **Splash Screen** - Animated splash with CampusSafe branding
- **Login Page** - Per Stitch design with email/phone, password, forgot password, guest mode, emergency SOS button
- **Registration Page** - 4-step onboarding (Account → Campus → Role → Prefs) with side-by-side layout on wide screens
- **Home Page** - Per Stitch design with:
  - Greeting & campus status
  - Emergency SOS button (press-and-hold 3s with progress ring and pulse animation)
  - Quick Emergency Types (bento grid: Medical, Security, Fire, General)
  - Safety Network status with nearby responders
- **Active Emergency/Tracking Page** - Per Stitch design with:
  - Emergency top app bar (red)
  - Urgency banner
  - Tracking map with user/responder markers and path
  - Responder card with contact action
  - Timeline status (SOS Sent → Alert Received → Responder Assigned → Responder En Route → Arrived)
  - Secondary actions (Update Emergency Details, Mark as False Alarm)

## Components Created
- **Design System** (`lib/core/constants/design_tokens.dart`):
  - Colors (Material 3 ColorScheme from DESIGN.md)
  - Typography (Geist, Inter, JetBrains Mono with proper sizing)
  - Spacing (8px base unit scale)
  - Radius (4px to 9999px)
  - Shadows (SOS, nav bar, card, elevated)
  - Durations
- **Buttons** (`lib/shared/widgets/buttons.dart`):
  - PrimaryButton, SecondaryButton, TertiaryButton
  - EmergencyButton (press-and-hold with animated progress ring and pulse)
- **Input Fields** (`lib/shared/widgets/input_fields.dart`):
  - AppTextField, AppPasswordField
- **Status Badge** (`lib/shared/widgets/status_badge.dart`):
  - StatusBadge (critical, warning, success, info, inactive, primary, secondary)
  - StatusDot with pulsing animation
  - Extensions for incident status and emergency types
- **Cards** (`lib/shared/widgets/cards.dart`):
  - AppCard, IncidentCard, ReportCard, ResponderCard, EmergencyTypeCard
  - SectionHeader, BentoGrid
- **Navigation** (`lib/shared/widgets/navigation.dart`):
  - AppTopAppBar, EmergencyTopAppBar
  - AppBottomNavBar with pill-style selected item
  - ScaffoldWithNav shell

## Design System
- **Colors**: Full Material 3 ColorScheme matching DESIGN.md (Primary #000666, Secondary #005FAF, Error #BA1A1A, etc.)
- **Typography**: Geist for headings, Inter for body, JetBrains Mono for technical data
- **Spacing**: 8px base unit (xs=4, sm=8, md=16, lg=24, xl=32)
- **Components**: Consistent rounded corners (8px default, 16px large, full for pills)
- **Shadows**: Subtle depth for SOS button, nav bar, cards

## Assets
- **Fonts**: Geist (400, 500, 600, 700) and JetBrains Mono (400, 500) added to assets/fonts/

## Navigation
- GoRouter with ShellRoute for bottom navigation
- Routes: /, /login, /register, /forgot-password, /guest, /home, /incidents, /reports, /profile, /sos, /incident/:id, /reports/new, /responder, /responder/available, /responder/incident/:id, /settings, /emergency/active/:id
- Bottom nav: Home, Incidents, Alerts, Profile (matching Stitch design)

## Mock Data
- Mock incidents, reports, responders used for UI demonstration
- Mock services clearly isolated from production backend

## Tests
- `flutter analyze`: No errors (only info/warnings)
- `flutter test`: All 34 tests passed

## Documentation Updated
- PLAN.md - Updated mobile foundation and user features status
- Mobile priority queue updated

# Documentation

- [ ] README.
- [ ] PROJECT.md.
- [ ] AGENTS.md.
- [ ] PLAN.md.
- [ ] Architecture diagrams.
- [ ] Database docs.
- [ ] API docs.
- [ ] Hardware docs.
- [ ] Setup guide.
- [ ] Testing guide.
- [ ] Demo guide.

# Current Priority Queue — Mobile Sprint Focus

This section outlines the immediate mobile tasks to complete, in order of execution:

### Mobile Sprint Plan (In Order of Execution)
1. [x] **Step 1: Dynamic User Profile, Emergency Medical Info Editor & Sign-Out**
   - Implement `ProfileNotifier` to fetch real profile from `ProfileRepository.getProfile()`.
   - Wire `ProfilePage` to display dynamic data (name, email, role, building, emergency info).
   - Build interactive "Edit Safety & Medical Info" sheet (blood type, allergies, conditions, ICE contact) with direct saving to Supabase.
   - Connect Profile sign-out button to `AuthNotifier.signOut()`.

2. [x] **Step 2: Direct Emergency Dialing & Campus Helpline Integration**
   - Wire direct telephone dialer (`tel:911`, `tel:+1...`) for Campus Security, Health Center, and Night Safety Escort across SOS Page and Safety Guide views using `url_launcher`.
   - Add one-tap emergency call triggers with confirmation dialogs.

3. [ ] **Step 3: Responder Live Duty & Availability Synchronization**
   - Connect the availability switch in `ResponderHomePage` to persist `is_active` / on-duty status in Supabase.
   - Add status banner ("On Duty — Receiving Dispatch" vs "Off Duty") and auto-toggle when responder goes online.

4. [ ] **Step 4: App Settings, Password Reset & Security Controls**
   - Wire `SettingsPage` to show authenticated user email.
   - Connect "Change / Reset Password" to `AuthNotifier.sendPasswordReset()`.
   - Connect push notification permission status and location service toggles.

### Overall Long-Term Queue
1. [x] Project foundation.
2. [x] Shared architecture.
3. [x] Database/data model (migrations created, schema implemented).
4. [x] Backend authentication/core entities (Supabase Auth, AuthRepository, ProfileRepository, IncidentRepository, SafetyReportRepository).
5. [x] Mobile foundation (UI implementation per Stitch design + Supabase + FCM integration).
6. [x] Dashboard foundation & Supabase wiring (UI complete, Supabase client connected, Realtime Postgres channel subscribed).
7. [x] End-to-end mobile SOS (connected SOS page & home page emergency types to IncidentRepository.createIncident and location service).
8. [x] Replace mock incidents/reports list pages with real Supabase data streams (connected IncidentsNotifier to watchActiveIncidents and SafetyReportsNotifier to SafetyReportRepository).
9. [x] Anonymous reporting (connected SubmitReportPage to SafetyReportRepository).
10. [x] Responder workflow (connected available incidents, accept/decline actions, and status progression to IncidentRepository).
11. [ ] First ESP32 SOS station firmware.
12. [ ] Location-aware proximity auto-dispatch.
13. [ ] Environmental IoT nodes.
14. [ ] Security/access IoT nodes.
15. [ ] Security hardening & production checklist.

# Plan Update Rules

Whenever major work changes:
1. Update task status.
2. Add notes for important decisions/blockers.
3. Add newly discovered dependencies.
4. Keep the priority queue accurate.
5. Record meaningful scope/architecture changes.
6. Do not create a competing master plan.
