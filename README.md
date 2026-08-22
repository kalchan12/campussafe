# CampusSafe

## Campus Safety & Emergency Response System

CampusSafe is a campus-wide emergency communication, incident coordination, and safety monitoring platform connecting students, staff, responders, university operators, and ESP32-based IoT devices.

> **Get the right help to the right place as quickly as possible.**

## What It Does

A user can send an SOS from the mobile app. The system can use location, emergency type, responder role, availability, and proximity to identify appropriate help.

Authorized operators monitor incidents through a real-time web dashboard.

Physical ESP32 devices can generate safety events or provide dedicated SOS controls.

## Three Main Components

### Mobile Application
**Flutter / Dart**

- Login and registration.
- User roles and profiles.
- SOS.
- GPS/location.
- Active incident tracking.
- Notifications.
- Incident history.
- Anonymous safety reporting.
- Responder workflows.

### Emergency Operations Dashboard
**Next.js / React / TypeScript**

- Live incidents.
- Campus map.
- Responder management.
- Device monitoring.
- Notifications.
- User management.
- Reports and analytics.
- Audit logs.
- Settings.

### IoT / Hardware
**ESP32 / C/C++**

Possible prototype devices:
- SOS station.
- Environmental sensor node.
- Security/access node.
- Optional warning node.

## Core Architecture

```text
                         CAMPUSSAFE
                             |
             +---------------+---------------+
             |               |               |
             v               v               v
        Mobile App      Web Dashboard     IoT Devices
             |               |               |
             +---------------+---------------+
                             |
                             v
                       Supabase Backend
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
          PostgreSQL     Realtime       Storage/Auth
              |
              v
        Incident / User /
        Responder / Device /
        Audit Data
```

## Emergency Example

```text
Student
   ↓
Press SOS
   ↓
Mobile captures location
   ↓
Backend creates incident
   ↓
Relevant responder selected
   ↓
Responder receives alert
   ↓
Responder accepts
   ↓
Dashboard updates
   ↓
Response tracked
   ↓
Incident resolved
```

## Hardware Example

```text
Physical Button
      ↓
    ESP32
      ↓
     Wi-Fi
      ↓
  Backend/API
      ↓
Incident Processing
      ↓
Dashboard + Mobile + Responders
```

## Technology Stack

| Area | Technology |
|---|---|
| Mobile | Flutter / Dart |
| Web | Next.js / React / TypeScript |
| UI | Tailwind CSS or selected UI system |
| Backend | Supabase |
| Database | PostgreSQL |
| Auth | Supabase Auth |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage where required |
| IoT | ESP32 |
| Firmware | C/C++ |
| Networking | Wi-Fi / HTTPS |
| Location | Mobile GPS/location services |
| Version Control | Git / GitHub |

## Security

CampusSafe handles identity, contact details, roles, location, emergency information, responder information, device credentials, and administrative actions.

Security concerns include:
- Authentication.
- Authorization.
- RBAC.
- Least privilege.
- HTTPS/TLS.
- Input validation.
- Secure credential handling.
- Audit logging.
- Privacy-aware location handling.
- Device authentication where implemented.

Never commit secrets or `.env` files. Use `.env.example`.

## HCI

Emergency interfaces prioritize:
- Clear hierarchy.
- Large touch targets.
- Immediate feedback.
- Error prevention.
- Accessibility.
- Predictable navigation.
- Minimal cognitive load.
- Visibility of system status.

## Repository Structure

```text
campussafe/
├── apps/
│   ├── mobile/
│   └── dashboard/
├── backend/
├── iot/
│   ├── sos-station/
│   ├── environmental-node/
│   └── security-node/
├── packages/
│   └── shared/
├── docs/
├── PROJECT.md
├── AGENTS.md
├── PLAN.md
└── README.md
```

The exact structure may evolve. `PLAN.md` is the source of truth for development priorities.

## Development Order

```text
Foundation
   ↓
Architecture/Data Model
   ↓
Backend
   ↓
Mobile + Dashboard
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
Final Demo
```

Do not prioritize advanced features over a reliable core emergency workflow.

## Project Boundary

CampusSafe is a university engineering prototype. It does not replace emergency services, guarantee response times, provide certified life-safety detection, or expose private location information to unauthorized users.

## Documentation

- `PROJECT.md` — project definition, goals, architecture, boundaries, users, and technology.
- `AGENTS.md` — human/AI development and collaboration rules.
- `PLAN.md` — living master development plan and current priorities.

## Definition of Success

```text
PERSON OR DEVICE
       ↓
EVENT DETECTED
       ↓
INCIDENT CREATED
       ↓
LOCATION IDENTIFIED
       ↓
RESPONDER SELECTED
       ↓
RESPONDER NOTIFIED
       ↓
RESPONSE TRACKED
       ↓
OPERATOR MONITORS
       ↓
INCIDENT RESOLVED
       ↓
HISTORY + AUDIT
```

CampusSafe's main strength is the integration of **mobile, web, backend, location services, cybersecurity, and physical IoT devices into one coherent emergency-response system.**
