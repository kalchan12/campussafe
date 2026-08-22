# CampusSafe — Project Definition

## Project Identity

**Project Name:** CampusSafe  
**Formal Title:** Campus Safety & Emergency Response System  
**Type:** Integrated Engineering Team Project

CampusSafe is a campus-wide emergency communication, incident coordination, and safety monitoring platform connecting students, staff, responders, university operators, and IoT devices.

> **Goal: get the right information to the right responder at the right place as quickly as possible.**

It is a university prototype, not a replacement for professional emergency services or certified life-safety equipment.

## Problems Addressed

Campus emergencies can be difficult to coordinate because people may not know whom to contact, may struggle to communicate their location, or may not know which responder is closest. Operators may also lack a centralized real-time view of incidents, responder availability, and physical safety events.

CampusSafe aims to improve:
- Emergency reporting.
- Responder selection and coordination.
- Location-aware response.
- Real-time incident visibility.
- Anonymous safety reporting.
- Physical safety monitoring.
- Incident history and auditing.

## Main Components

### 1. Mobile Application

Built with Flutter/Dart.

Normal users can:
- Register and manage profiles.
- Identify their campus role.
- Provide relevant campus information.
- Allow location access.
- Send SOS alerts.
- Track active incidents.
- Receive safety notifications.
- View incident history.
- Submit anonymous safety reports where appropriate.

Responders can:
- Set availability.
- Receive relevant incidents.
- Accept/decline incidents.
- View location and emergency information.
- Update response status.
- Mark incidents arrived/resolved.

### 2. Web Emergency Operations Dashboard

Built with Next.js/React/TypeScript.

Authorized operators can:
- Monitor active incidents.
- View a live campus map.
- Manage responders.
- Assign/escalate incidents.
- Monitor IoT devices.
- Review notifications.
- View reports and analytics.
- Inspect audit logs.
- Manage users and settings.

### 3. IoT / Hardware Layer

Prototype devices use ESP32.

Possible devices:

**SOS Station**
- ESP32
- Physical SOS button
- LEDs
- Buzzer

**Environmental Node**
- ESP32
- MQ-2 smoke/gas sensor
- DHT22 temperature/humidity sensor
- PIR motion sensor

**Security/Access Node**
- ESP32
- RC522 RFID reader
- RFID tags
- Magnetic reed switch
- PIR sensor

**Optional Warning Node**
- ESP32
- Buzzer
- LEDs
- Optional display

Hardware is prototype/educational equipment and is not certified life-safety equipment.

## High-Level Architecture

```text
                    CAMPUSSAFE
                         |
        +----------------+----------------+
        |                |                |
        v                v                v
   MOBILE APP       WEB DASHBOARD      IoT DEVICES
        |                |                |
        +----------------+----------------+
                         |
                         v
                  BACKEND / API
                         |
        +----------------+----------------+
        |                |                |
        v                v                v
   INCIDENT         RESPONDER        DEVICE/EVENT
    ENGINE          MANAGEMENT        PROCESSING
        |                |                |
        +----------------+----------------+
                         |
                         v
                    PostgreSQL
                         |
                         v
                  Audit / History
```

## Emergency Workflow

```text
Student/User
    |
    v
SOS
    |
    v
GPS + Campus Location
    |
    v
Backend creates incident
    |
    v
Emergency type + responder availability + proximity
    |
    v
Relevant responder selected
    |
    v
Responder notified
    |
    v
Responder accepts
    |
    v
Dashboard and user status update
    |
    v
Response / Arrival
    |
    v
Incident resolved
    |
    v
History + audit record
```

## Location-Aware Response

The system can combine:
- User GPS coordinates.
- Campus building/block information.
- Responder location.
- Responder role/specialization.
- Responder availability.
- Emergency type.

Example:

```text
Medical SOS
+
Engineering Block B
+
Available medical responders
+
Proximity
        |
        v
Nearest suitable responder
```

A future optional capability can notify nearby campus blocks or people within a configurable 100–200 meter radius. This should be implemented only after the core workflow is stable.

## Anonymous Reporting

Guests or users may report:
- Suspicious activity.
- Security concerns.
- Fire/hazard observations.
- Other safety concerns.

Reports can contain location, description, optional media, and timestamp.

Anonymous reporting is different from SOS: SOS is an emergency-response mechanism, while anonymous reporting is primarily for safety/security information.

## Technology Stack

| Area | Technology |
|---|---|
| Mobile | Flutter / Dart |
| Web | Next.js / React / TypeScript |
| UI | Tailwind CSS or selected UI system |
| Backend | Supabase |
| Database | PostgreSQL |
| Authentication | Supabase Auth |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage where required |
| IoT | ESP32 |
| Firmware | C/C++ |
| Networking | Wi-Fi / HTTPS |
| Location | Mobile GPS/location services |
| Version Control | Git / GitHub |

## Security

CampusSafe handles identity, contact details, roles, location, emergency information, responder information, device credentials, and administrative actions.

Security design includes:
- Authentication.
- Authorization.
- Role-based access control.
- Least privilege.
- HTTPS/TLS.
- Input validation.
- Secure credential handling.
- Audit logging.
- Privacy-aware location handling.
- Device authentication where implemented.

Never claim production-grade security without testing and evidence.

## HCI Principles

Emergency UI must prioritize:
- Visibility of system status.
- Recognition over recall.
- Consistency.
- Error prevention.
- Immediate feedback.
- Accessible contrast.
- Large touch targets.
- Predictable navigation.
- Minimal cognitive load.

Red should primarily communicate critical emergency states rather than act as the general brand color.

## Expected Prototype

The prototype should demonstrate:
- Authentication and roles.
- Mobile SOS.
- Location capture.
- Incident creation.
- Responder notification and response.
- Real-time dashboard.
- Campus map.
- Anonymous reporting.
- At least one ESP32 SOS station.
- At least one sensor/device prototype.
- Incident history.
- Audit logging.

## Future Extensions

Potential future work:
- 100–200 meter proximity/community alerts.
- SMS fallback.
- More IoT nodes.
- Advanced geographic routing.
- Advanced event correlation.
- Computer vision.
- Official university emergency-service integration.
- Advanced analytics.

## Project Boundaries

CampusSafe does not:
- Replace emergency services.
- Guarantee response times.
- Provide certified medical/fire detection.
- Automatically determine every real-world emergency.
- Expose private location information to unauthorized users.

## Definition of Success

```text
Human or Device Event
        ↓
Event Received
        ↓
Incident Created
        ↓
Location Determined
        ↓
Relevant Responder Identified
        ↓
Responder Notified
        ↓
Responder Accepts
        ↓
Operator Sees Update
        ↓
Incident Resolved
        ↓
Audit/History Stored
```
