# CampusSafe — ARCHITECTURE.md

> **Technical source of truth:** This document describes how CampusSafe is technically structured, how its components communicate, and where technology decisions belong.  
> If the implementation changes, update this document so it remains consistent with the codebase.

---

## 1. Architecture Overview

CampusSafe is a distributed campus safety platform composed of three primary client/device components connected through a backend platform:

1. **Mobile Application** — user and responder interface.
2. **Web Emergency Operations Dashboard** — operator/administrator interface.
3. **IoT / Embedded Layer** — physical SOS stations and safety sensor devices.

The three components communicate through the backend rather than directly coupling the clients together.

```text
                         ┌─────────────────────────┐
                         │       CAMPUSSAFE        │
                         │  Emergency Platform     │
                         └────────────┬────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
              ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
              │   MOBILE    │   │  DASHBOARD  │   │     IoT     │
              │ Flutter     │   │ Next.js     │   │ ESP8266 /   │
              │ / Dart      │   │ React/TS    │   │ ESP32-CAM   │
              └──────┬──────┘   └──────┬──────┘   └──────┬──────┘
                    │                 │                 │
                    └─────────────────┼─────────────────┘
                                      │
                                      ▼
                           ┌─────────────────────┐
                           │   BACKEND PLATFORM  │
                           │     Supabase        │
                           └──────────┬──────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
              PostgreSQL          Auth             Realtime
                    │
                    ▼
              Storage / Data
```

---

# 2. Architectural Principles

## 2.1 Separation of Concerns

Each component has a clear responsibility.

```text
Mobile
  → Human interaction

Dashboard
  → Operational monitoring and administration

IoT
  → Physical event detection/input

Backend
  → Data, authorization, business logic, realtime coordination

Database
  → Persistent source of truth
```

No component should become responsible for functionality belonging to another layer without an explicit architectural reason.

## 2.2 Backend-Mediated Communication

The mobile app, dashboard, and IoT devices should communicate through the backend.

Avoid:

```text
Mobile ───────────────→ IoT
Dashboard ────────────→ Mobile
IoT ──────────────────→ Dashboard
```

Prefer:

```text
Mobile ───┐
          │
Dashboard ├──→ Backend ──→ Database / Realtime
          │
IoT ──────┘
```

This reduces coupling and gives the backend one place to enforce authorization, validation, auditing, and incident rules.

## 2.3 Shared Contracts

The following are cross-component contracts:

- User model.
- Role model.
- Responder model.
- Campus location model.
- Incident model.
- Incident status values.
- Emergency types.
- Device model.
- Device event model.
- Safety report model.
- Audit event model.
- Realtime event names.
- API/service interfaces.

Changing these requires checking every consumer.

---

# 3. Technology Stack

## Current Baseline

| Layer | Technology |
|---|---|
| Mobile | Flutter / Dart |
| Web Dashboard | Next.js / React / TypeScript |
| UI | Tailwind CSS or selected UI component system |
| Backend | Supabase |
| Database | PostgreSQL |
| Authentication | Supabase Auth |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage where required |
| IoT (Primary) | ESP8266 NodeMCU |
| IoT (Camera) | ESP32-CAM (independent) |
| Firmware | C/C++ (Arduino IDE) |
| Network | Wi-Fi / HTTPS |
| Location | Mobile GPS/location services |
| Version Control | Git / GitHub |

This is the **current baseline**, not an immutable requirement.

If a technology is replaced, follow the Technology Change Protocol in `AGENTS.md`.

---

# 4. Repository Architecture

Recommended structure:

```text
campussafe/
│
├── apps/
│   ├── mobile/
│   │   └── Flutter application
│   │
│   └── dashboard/
│       └── Next.js application
│
├── backend/
│   ├── services/
│   ├── functions/
│   └── configuration/
│
├── iot/
│   ├── sos-station/         # ESP8266 — SOS push button + feedback
│   ├── sensor-node/         # ESP8266 — up to 2 sensors (heat/gas)
│   └── esp32-cam/           # ESP32-CAM — independent camera device
│
├── packages/
│   └── shared/
│       ├── types/
│       ├── contracts/
│       └── constants/
│
├── docs/
│
├── PROJECT.md
├── ARCHITECTURE.md
├── AGENTS.md
├── PLAN.md
└── README.md
```

The exact implementation may evolve. Architecture changes must be reflected here.

---

# 5. Mobile Architecture

```text
UI
 │
 ▼
Presentation / State
 │
 ▼
Application Services
 │
 ├── Authentication
 ├── Incident/SOS
 ├── Location
 ├── Notifications
 └── Reports
 │
 ▼
Backend Service Layer
 │
 ▼
Supabase / API
```

The mobile app should not contain privileged backend credentials or rely on client-side authorization as its security boundary.

## Main Mobile Domains

### Authentication
- Login.
- Registration.
- Session management.
- Role-aware navigation.

### Profile
- Name.
- Role.
- Block/work location.
- Phone.
- Email.
- Other required emergency information.

Only collect information justified by the project requirements.

### SOS
- Emergency type.
- Current location.
- User identity where applicable.
- Timestamp.
- Optional context.
- Submission status.

### Responder
- Availability.
- Incident queue.
- Incident details.
- Accept/decline.
- En route.
- Arrived.
- Resolved.

### Anonymous Reporting

Guest users may submit safety reports without exposing unnecessary identity information.

Anonymous reporting must remain separate from authenticated emergency response where appropriate.

---

# 6. Web Dashboard Architecture

```text
Dashboard UI
    │
    ▼
Pages / Components
    │
    ▼
Dashboard Services
    │
    ├── Incidents
    ├── Responders
    ├── Devices
    ├── Users
    ├── Reports
    └── Audit
    │
    ▼
Backend
```

## Main Dashboard Areas

### Operations
- Active incidents.
- Incident details.
- Incident timeline.
- Campus map.
- Responder status.

### Responders
- Availability.
- Current assignments.
- Location where permitted.
- Response state.

### IoT
- Device list.
- Online/offline status.
- Device events.
- Telemetry.
- Firmware/device metadata.

### Administration
- Users.
- Roles.
- Permissions.
- Reports.
- Audit logs.

---

# 7. IoT Architecture

The IoT layer consists of physical devices that generate events and send them to the backend over Wi-Fi. Devices are event producers only — they do not receive commands or run bidirectional communication.

## Hardware Strategy

```text
Primary Controller:  ESP8266 NodeMCU
Camera Device:       ESP32-CAM (independent, own Wi-Fi)
Auxiliary:           Arduino boards only if GPIO/I/O limits require
Prototyping:         Breadboards and basic electronics
Connectivity:        Wi-Fi → HTTPS → Supabase REST API
```

## Device Types

### 1. Manual SOS Station (ESP8266)

A physical panic button station deployed at fixed campus locations.

```text
┌──────────────────────────────────────┐
│          SOS STATION (ESP8266)       │
│                                      │
│   Push Button ──→ Debounce           │
│                      │               │
│                      ▼               │
│               Create Event           │
│                      │               │
│              ┌───────┼───────┐       │
│              ▼       ▼       ▼       │
│            LED    Buzzer   Wi-Fi     │
│         (feedback)        → HTTPS    │
│                           → Supabase │
└──────────────────────────────────────┘
```

Components:
- ESP8266 NodeMCU.
- Physical SOS push button.
- LED (visual feedback).
- Buzzer (audio feedback).
- Optional: I2C display for status.

### 2. Automatic Sensor Node (ESP8266)

Detects environmental incidents using up to **two sensors** connected to one ESP8266.

```text
┌──────────────────────────────────────┐
│        SENSOR NODE (ESP8266)         │
│                                      │
│   Sensor 1 ──→ Read                  │
│   Sensor 2 ──→ Read                  │
│                  │                   │
│                  ▼                   │
│          Threshold Check             │
│                  │                   │
│             ┌────┴────┐              │
│             ▼         ▼              │
│          Normal    Incident          │
│         (no-op)       │              │
│                       ▼              │
│                   Wi-Fi → HTTPS      │
│                         → Supabase   │
└──────────────────────────────────────┘
```

Current sensor focus:
- Heat / temperature detection.
- Gas / smoke detection.

Maximum: 2 sensors per ESP8266 board to avoid hardware complexity.

### 3. ESP32-CAM (Independent Device)

The ESP32-CAM operates as an **independent IoT device** with its own Wi-Fi connection. It does not communicate through the ESP8266.

```text
┌──────────────────────────────────────┐
│        ESP32-CAM (Independent)       │
│                                      │
│   Camera ──→ Capture                 │
│                 │                    │
│                 ▼                    │
│          Event Detection             │
│                 │                    │
│                 ▼                    │
│          Wi-Fi → HTTPS               │
│                → Supabase            │
└──────────────────────────────────────┘
```

The ESP32-CAM may act as a camera-based event source. Its exact capabilities depend on the implementation phase.

## IoT Data Flow

All IoT devices follow the same backend integration pattern:

```text
Physical Event (button press / sensor reading / camera trigger)
       │
       ▼
   ESP8266 or ESP32-CAM
       │
       ├── Local feedback (LED / buzzer)
       ├── Create event payload (JSON)
       └── Device validation
       │
       ▼
     Wi-Fi
       │
       ▼
  HTTPS POST → Supabase REST API
       │
       ▼
  Backend validates event
       │
       ├── Insert into device_events table
       ├── Create incident (if SOS or threshold breach)
       └── Trigger realtime notification
       │
       ▼
  Dashboard + Mobile consume via Realtime
```

## Event Payload Format

All devices send events in a standard JSON format:

```json
{
  "device_id": "SOS-ENG-01",
  "event_type": "SOS_TRIGGERED",
  "timestamp": "2026-01-01T12:00:00Z",
  "location_id": "engineering-block",
  "payload": {}
}
```

Sensor node example:

```json
{
  "device_id": "SENSOR-LIB-01",
  "event_type": "SMOKE_DETECTED",
  "timestamp": "2026-01-01T12:05:00Z",
  "location_id": "library-block",
  "payload": {
    "sensor": "MQ-2",
    "reading": 850,
    "threshold": 500,
    "unit": "ppm"
  }
}
```

## Modularity

The architecture is designed so additional ESP8266 boards or sensors can be added later without redesigning the backend:

- Each device has a unique `device_id`.
- The `device_type` field in the `devices` table distinguishes device roles.
- The `device_events` table accepts events from any registered device.
- New sensor types can be added by extending the `event_type` check constraint.
- New device types can be added by extending the `device_type` check constraint.

## IoT Security

- Devices must not be treated as automatically trustworthy.
- Validate all device events on the backend.
- A sensor reading is not automatically a confirmed emergency.
- Device authentication should be implemented when feasible (API key or device token).
- Device credentials must never be hardcoded in public firmware repositories.

---

# 8. Backend Architecture

The backend is the central coordination layer.

```text
             ┌──────────────┐
             │    Mobile    │
             └──────┬───────┘
                    │
             ┌──────▼───────┐
             │    Backend   │
             │              │
             │ Validation   │
             │ Auth         │
             │ Authorization│
             │ Business     │
             │ Logic        │
             │ Events       │
             └──────┬───────┘
                    │
       ┌────────────┼─────────────┐
       ▼            ▼             ▼
 PostgreSQL      Realtime       Storage
```

The backend should be responsible for authoritative decisions such as:

- Whether a user can access a resource.
- Whether a responder can accept an incident.
- Which incident data is exposed.
- Whether a device event is accepted.
- Which responders are eligible.
- How incident state changes are recorded.

---

# 9. Core Data Model

Conceptual model:

```text
USER
 │
 ├── ROLE
 ├── PROFILE
 └── RESPONDER (optional)
          │
          ▼
       INCIDENT
          │
    ┌─────┼─────┐
    ▼     ▼     ▼
 LOCATION EVENT AUDIT
    │
    ▼
 CAMPUS BLOCK


DEVICE
   │
   ├── DEVICE_EVENT
   └── LOCATION


SAFETY_REPORT
   │
   ├── LOCATION
   └── AUDIT_EVENT
```

## Core Entities

### User
Stores account/profile information.

### Role
Examples:
- Student.
- Doctor/medical responder.
- Security responder.
- Operator.
- Administrator.

Roles should not be treated as sufficient by themselves; permissions must also be enforced.

### Incident
Represents an emergency requiring response.

Potential fields:

```text
id
type
status
priority
reporter_id
location
created_at
updated_at
assigned_responder
resolved_at
```

### Responder
Represents an individual capable of responding.

### Device
Represents a physical IoT device.

### Device Event
Represents an event generated by a device.

### Safety Report
Represents a non-SOS safety/security report.

### Audit Event
Records security-sensitive or operational actions.

---

# 10. Incident State Machine

```text
             ┌──────────────┐
             │    CREATED   │
             └──────┬───────┘
                    ▼
             ┌──────────────┐
             │   RECEIVED   │
             └──────┬───────┘
                    ▼
             ┌──────────────┐
             │   ASSIGNED   │
             └──────┬───────┘
                    ▼
             ┌──────────────┐
             │  RESPONDING  │
             └──────┬───────┘
                    ▼
             ┌──────────────┐
             │   ARRIVED    │
             └──────┬───────┘
                    ▼
             ┌──────────────┐
             │   RESOLVED   │
             └──────────────┘
```

Exceptional states may be added when requirements justify them, for example:

```text
CANCELLED
ESCALATED
UNASSIGNED
FAILED
```

Do not add states casually because every client must understand them.

---

# 11. Location Architecture

CampusSafe can use multiple location concepts:

```text
GPS Coordinates
      │
      ▼
Campus Location
      │
      ├── Block
      ├── Building
      └── Area
```

Responder selection can consider:

```text
Emergency Type
      +
Responder Role
      +
Availability
      +
Location
      +
Distance
      ↓
Eligible Responders
      ↓
Ranking
      ↓
Notification
```

Future optional proximity functionality:

```text
Incident
   │
   ├── Nearby Block A
   ├── Nearby Block B
   └── 100–200m Radius
```

This is intentionally a later feature. Core emergency response must work first.

---

# 12. Realtime Architecture

Realtime is used for operational updates.

Example:

```text
Mobile
  │
  │ creates incident
  ▼
Backend
  │
  │ database change/event
  ▼
Realtime
  │
  ├───────────────┐
  ▼               ▼
Dashboard       Responder
```

Possible realtime events:

```text
INCIDENT_CREATED
INCIDENT_ASSIGNED
INCIDENT_ACCEPTED
INCIDENT_STATUS_CHANGED
RESPONDER_STATUS_CHANGED
DEVICE_STATUS_CHANGED
DEVICE_EVENT_RECEIVED
```

Event names are shared contracts and must be changed carefully.

---

# 13. Notification Architecture

## Two separate mechanisms

```text
                        Incident
                           │
              ┌────────────┴─────────────┐
              │                          │
              ▼                          ▼
       Supabase Realtime               FCM
              │                          │
              ▼                          ▼
     Dashboard live update       Responder phone
     Mobile incident update      (push notification)
```

### Supabase Realtime
Used for live application state updates while the app is open:
- Dashboard receives incident changes without polling.
- Mobile app receives incident status updates for the active incident.
- Implemented via `IncidentRepository.watchActiveIncidents()` and `watchIncident()`.

### Firebase Cloud Messaging (FCM)
Used to wake up a device that is not currently in the foreground:
- Sends push notifications to responders when a new incident is created.
- Handled server-side ONLY via the `send-notification` Supabase Edge Function.
- Flutter client registers its token; the server reads the token and sends via FCM.

## Notification flow

```text
Incident Created
      ↓
Supabase (IncidentRepository.createIncident)
      ↓
invoke Edge Function: send-notification
      ↓
Edge Function reads notification_tokens for eligible responders
      ↓
Edge Function sends via FCM HTTP API (using server-side FCM_SERVER_KEY)
      ↓
FCM delivers push to responder device
      ↓
Responder taps notification
      ↓
Mobile app navigates to incident detail
```

## Security

- `FCM_SERVER_KEY` and `SUPABASE_SERVICE_ROLE_KEY` live **only** in Supabase Edge Function secrets.
- Flutter uses `supabase_flutter` with the **anon** key only.
- `firebase_messaging` on Flutter handles device-side token management and incoming notifications.
- The `NotificationTokenService` stores FCM tokens in the `notification_tokens` table.
- RLS ensures users can only read/write their own tokens.

## FCM token lifecycle

```text
App starts
  ↓
NotificationService.initialize(userId)
  ↓
FCM.getToken() → token
  ↓
NotificationTokenService.registerToken(userId, token, platform)
  ↓
Stored in notification_tokens table (UNIQUE on user_id + token)

Token refresh → onTokenRefresh → re-register

Sign out → NotificationTokenService.deactivateTokens(userId, token)
```


# 14. Security Architecture

Security boundaries:

```text
                 INTERNET
                    │
                    ▼
              Authentication
                    │
                    ▼
              Authorization
                    │
                    ▼
               Validation
                    │
                    ▼
             Business Logic
                    │
                    ▼
                Database
```

## Required Security Controls

- Authentication.
- Role-based access control.
- Least privilege.
- Database access policies.
- Input validation.
- Secure secrets.
- TLS/HTTPS.
- Audit logs.
- Session controls.
- Device authentication where implemented.

## Sensitive Data

Potentially sensitive data includes:

- Phone numbers.
- Email addresses.
- User roles.
- Location.
- Emergency information.
- Responder information.
- Incident history.

Only expose information to users who have a legitimate permission to access it.

---

# 15. Failure Architecture

The system must expect failure.

```text
                 EVENT
                   │
                   ▼
              Network?
             /        \
           YES         NO
            │           │
            ▼           ▼
        Send event   Local handling
            │           │
            ▼           ▼
         Backend     Retry/Queue
            │           │
            └─────┬─────┘
                  ▼
             Final status
```

Important failure cases:

- GPS unavailable.
- Wi-Fi unavailable.
- Mobile offline.
- Backend unavailable.
- Notification unavailable.
- Responder unavailable.
- IoT device offline.
- Duplicate event.
- Invalid event.
- Unauthorized request.

The system should never falsely report an action as completed when it has not been confirmed.

---

# 16. Technology Change Protocol

Technology decisions can change during development.

When changing a major technology:

```text
Proposal
   ↓
Impact Analysis
   ↓
Architecture Decision
   ↓
Update Documentation
   ↓
Update PLAN.md
   ↓
Implementation
   ↓
Testing
   ↓
Remove Obsolete References
   ↓
Architecture Verification
```

Affected documents normally include:

```text
PROJECT.md
ARCHITECTURE.md
PLAN.md
README.md
```

`AGENTS.md` changes only if development rules/workflows are affected.

---

# 17. Architecture Decision Records

For significant decisions, create an ADR under:

```text
docs/adr/
```

Recommended format:

```text
docs/adr/
├── 0001-mobile-framework.md
├── 0002-backend-platform.md
├── 0003-realtime-strategy.md
└── 0004-iot-protocol.md
```

Each ADR should include:

```text
# Decision

## Context

## Options Considered

## Decision

## Reasons

## Consequences

## Migration Plan
```

Use ADRs for meaningful architectural changes, not every dependency upgrade.

---

# 18. Architecture Validation Checklist

Before considering an architectural change complete:

- [ ] All three major components considered.
- [ ] Shared contracts checked.
- [ ] Security impact checked.
- [ ] Database impact checked.
- [ ] Realtime impact checked.
- [ ] Testing impact checked.
- [ ] Documentation updated.
- [ ] Old technology references removed where obsolete.
- [ ] Migration/rollback considered.
- [ ] End-to-end SOS workflow still works.

---

# 19. Current Architecture Goal

The architecture should enable this complete path:

```text
USER / DEVICE
      ↓
EVENT
      ↓
BACKEND
      ↓
INCIDENT
      ↓
LOCATION + TYPE + PRIORITY
      ↓
ELIGIBLE RESPONDERS
      ↓
NOTIFICATION
      ↓
RESPONDER
      ↓
DASHBOARD
      ↓
RESPONSE
      ↓
RESOLUTION
      ↓
AUDIT + HISTORY
```

The architecture is successful when the three major components behave as parts of **one system**, rather than three unrelated applications.
