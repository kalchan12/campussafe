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

**Primary System User Actors:**
- **Students**: Undergraduate, graduate, and residential campus students requesting emergency assistance, monitoring safety broadcasts, and receiving incident status updates.
- **Staff**: Faculty professors, university administrative staff, lab technicians, and campus personnel representing all non-student members of the university community.

Normal users (Students & Staff) can:
- Register and onboard by selecting their campus affiliation (**Student** or **Staff**).
- Configure two primary life-safety emergency contacts during registration:
  - **Parent / Guardian Phone**: Filled in by the user for immediate family notification.
  - **University Emergency Admin Phone**: Pre-filled with the campus emergency dispatch hotline (`0920304050`).
- Allow location access and capture high-accuracy GPS coordinates.
- Send SOS alerts via 3-second hold or hands-free accelerometer shake detection (`sensors_plus`) for sudden incapacitating accidents.
- Direct emergency type selection without intermediate confirmation dialogs, focusing user-initiated emergencies on **Medical** and **Security**, while **Fire Hazard** and **Accident Hazard** are designated for proactive automated campus IoT sensor triggers.
- Rely on automated dual-channel offline resilience:
  - Local SQLite queue (`campussafe_queue.db`) for automatic incident retry upon reconnection.
  - Automated carrier SMS dispatch (`EmergencySmsService`): automatically transmits standardized distress messages containing exact GPS coordinates and clickable Google Maps links directly to both the **Parent** and **University Emergency Admin (`0920304050`)** in the background when mobile data/Wi-Fi is unavailable.
- Configure emergency preferences (Shake-to-SOS on/off) and edit emergency contacts in Safety Profile.
- Track active incidents in real time.
- Receive safety notifications.
- View incident history.
- Submit anonymous safety reports where appropriate.

Responders can:
- Set availability.
- Receive relevant incidents via automated proximity dispatch (Haversine formula).
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

Prototype devices use an ESP8266 NodeMCU Amica v2 as the main controller (sensing + communication) and an Arduino Uno R3 as a dedicated display controller. (Note: The ESP32-CAM camera node was removed from project scope due to component procurement unavailability).

**Main Controller Station (ESP8266 Amica v2)**
- ESP8266 NodeMCU Amica v2.
- Physical SOS push button.
- Up to 2 sensors (currently focused on heat/gas detection: MQ-2 + DHT11).
- LED (visual feedback).
- Sends events to Supabase via Wi-Fi HTTPS.
- Sends display data to Arduino via Serial.
- Automatic incident detection when sensor thresholds are breached.

**Display Controller (Arduino Uno R3)**
- Arduino Uno R3.
- 2× LCD displays.
- LCD 1: SOS push button status display.
- LCD 2: Sensor readings display (gas ppm, temperature °C).
- Status LEDs.
- Receives all data from ESP8266 via Serial (no network access).

The Arduino Uno R3 is used as a dedicated display controller because driving two LCDs requires more GPIO pins than the ESP8266 can provide. Breadboards, resistors, and basic electronics are used for prototyping.

Hardware is prototype/educational equipment and is not certified life-safety equipment.

### Complementary Spatial Sensing Architecture

The platform integrates three synergistic, complementary sentinel tiers within the unified safety mesh:
- **Wearable Health Sentinels (Smartwatches & Fitness Bands)**: Continuously monitor vital organs and biological distress on individuals:
  - **Photoplethysmography (PPG)**: Optical heart rate & pulse oximetry monitoring. Detects critical resting tachycardia (> 150 BPM), severe bradycardia (< 40 BPM), and acute respiratory hypoxia (SpO2 < 88%).
  - **Electrocardiogram (ECG / EKG)**: Detects cardiac arrhythmias, Atrial Fibrillation (AFib), and sudden cardiac arrest / loss of pulse.
  - **Inertial Measurement Unit (IMU - Accelerometer & Gyroscope)**: Detects high-G hard fall impacts coupled with subsequent immobility (unconscious or incapacitated user).
  - **Skin Temperature Sensors**: Detects thermal emergencies including hypothermia (< 35.0°C) and heatstroke / severe hyperthermia (> 39.5°C).
  - **Electrodermal Activity (EDA / GSR)**: Measures sympathetic nervous system arousal and acute physiological trauma.
  - **Pre-Alert Grace Period (15s)**: A 15-second audible and haptic countdown allows conscious users to dismiss benign false triggers ("I'm OK") before triggering automated Medical SOS dispatch with vital telemetry notes.
- **Personal & Mobile Sentinels (Smartphones)**: Roam dynamically across campus with students and staff. They capture human-centric distress, high-accuracy GPS coordinates, and sudden inertial impacts (violent grabs, falls, or sudden accidents).
- **Stationary & Environmental Sentinels (IoT Stations)**: Fixed permanently at high-hazard campus infrastructure (chemical laboratories, dorm kitchens, mechanical rooms). They autonomously monitor atmospheric hazards (toxic gas leaks, smoke, extreme temperature spikes) 24 hours a day without requiring human presence or manual intervention.

Unifying wearable vitals, smartphone telemetry, and stationary IoT streams through a single Supabase backend and Web Operations Center gives operators comprehensive situational awareness spanning human biological distress, active individual emergencies, and environmental building threats.

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
| IoT | ESP8266 NodeMCU Amica v2 / Arduino Uno R3 |
| Firmware | C/C++ (Arduino IDE) |
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
- ESP8266 Amica v2 main controller station (SOS button + heat/gas sensors).
- Arduino Uno R3 display controller (2× LCD: SOS status + sensor readings).
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
