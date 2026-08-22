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
- [ ] Flutter project.
- [ ] Folder architecture.
- [ ] Theme/design system.
- [ ] Navigation.
- [ ] State-management approach.
- [ ] API/service layer.

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

- [ ] Supabase environment.
- [ ] PostgreSQL.
- [ ] Authentication.
- [ ] Initial migrations.
- [ ] User profiles.
- [ ] Roles.
- [ ] Responders.
- [ ] Campus locations.
- [ ] Incidents.
- [ ] Devices.
- [ ] Safety reports.
- [ ] Audit events.
- [ ] Row Level Security.
- [ ] Realtime.
- [ ] Backend services.
- [ ] Error strategy.
- [ ] Seed/test data.

**Milestone:** Backend can safely create and retrieve a complete incident.

# Phase 3 — Mobile

## Foundation
- [ ] Welcome/splash.
- [ ] Login.
- [ ] Registration.
- [ ] Role selection.
- [ ] Profile.
- [ ] Permissions.
- [ ] Location permissions.
- [ ] Notifications.
- [ ] Navigation.
- [ ] Loading/error/empty states.

## User Features
- [ ] Home.
- [ ] SOS activation.
- [ ] Emergency type.
- [ ] Incident submission.
- [ ] Active incident tracking.
- [ ] History.
- [ ] Notifications.
- [ ] Anonymous reporting.
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
- [x] Authentication.
- [~] Role-based access.
- [x] Sidebar.
- [x] Overview.
- [x] System status.

## Operations
- [x] Live incidents.
- [~] Incident detail.
- [~] Live campus map.
- [x] Responder management.
- [~] Assignment.
- [~] Escalation.
- [~] Resolution.
- [~] Notifications.

## Infrastructure
- [x] Device management.
- [x] Device status.
- [~] Telemetry.
- [~] Device events.

## Administration
- [~] User management.
- [x] Reports.
- [~] Analytics.
- [~] Audit logs.
- [x] Settings.

**Milestone:** Operator can monitor, assign, follow, and resolve incidents.

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
- [ ] GPS capture.
- [ ] Coordinate normalization.
- [ ] Role filtering.
- [ ] Availability filtering.
- [ ] Distance calculation.
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

# Current Priority Queue

This section must always reflect the actual project state.

1. [ ] Project foundation.
2. [ ] Shared architecture.
3. [ ] Database/data model.
4. [ ] Backend authentication/core entities.
5. [ ] Mobile foundation.
6. [ ] Dashboard foundation.
7. [ ] End-to-end mobile SOS.
8. [ ] Responder workflow.
9. [ ] Realtime.
10. [ ] First ESP32 SOS station.
11. [ ] Location-aware routing.
12. [ ] Anonymous reporting.
13. [ ] Environmental IoT.
14. [ ] Security/access IoT.
15. [ ] Security hardening.
16. [ ] Analytics.
17. [ ] Advanced proximity features.

# Plan Update Rules

Whenever major work changes:
1. Update task status.
2. Add notes for important decisions/blockers.
3. Add newly discovered dependencies.
4. Keep the priority queue accurate.
5. Record meaningful scope/architecture changes.
6. Do not create a competing master plan.
