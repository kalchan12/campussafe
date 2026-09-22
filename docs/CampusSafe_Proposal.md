# Project Proposal: CampusSafe
## An Integrated Real-Time Campus Safety, Environmental Monitoring, and Emergency Response System

**Course:** Integrated Team and Engineering Project  
**Institution:** Adama Science and Technology University (ASTU)  
**Department:** Department of Software Engineering  
**Project Lead / Coordinator:** Kaleb Chanchal  
**Date:** September 2026  
**Document Version:** 2.0  

---

## 1. Executive Summary

CampusSafe is an integrated, multi-disciplinary engineering solution engineered to transform emergency communication, situational awareness, and incident response across university campuses. Modern campus environments face critical life-safety challenges: slow and manual emergency reporting channels, lack of spatial visibility for dispatchers, absence of continuous environmental hazard monitoring, vulnerability to cellular data or Wi-Fi network outages, inability to detect trauma or unconscious collapse, and justified student resistance against invasive administrative surveillance.

Developed within the practical context of Adama Science and Technology University (ASTU), CampusSafe connects students, staff, emergency responders, campus safety administrators, and autonomous physical sensors into a unified operational ecosystem. The system bridges three core engineering tiers through a centralized cloud backend:

1. **Cross-Platform Mobile Application (Flutter / Dart):** Equips students and staff with rapid SOS activation mechanisms—including a deliberate 3-second hold gesture and a hands-free accelerometer-based Shake-to-SOS trigger (`sensors_plus`) for physical incapacitation. It features a transparent **5-step registration onboarding flow** (`Account` → `Role` → `Contacts` → `Consent` → `Campus`), mandatory dual life-safety emergency contacts (personal Parent/Guardian phone and the University Emergency Admin Hotline `0920304050`), a zero-friction Direct Emergency Selection flow (Medical and Security), and automated dual-channel offline resilience combining a local SQLite transaction queue (`campussafe_queue.db`) with automated background cellular SMS dispatch containing exact GPS coordinates and clickable Google Maps links.
2. **Privacy-First Architecture & Zero Passive Tracking Guarantee:** University operators and administrators have **zero technical capability** to passively track, monitor, or poll real-time GPS locations or biometric vitals of students during normal campus routines. Sensor monitoring defaults to **OFF (`false`)** for healthy students. Device motion and wearable vitals are evaluated 100% locally on the student's personal phone and watch (edge heuristics), and data leaves the personal device **strictly and solely** when an emergency occurs and an active SOS is dispatched. Consent can be revoked or toggled anytime in Settings.
3. **Wearable & Smartwatch Vital Organ Monitoring Sentinel:** Continuously tracks physiological telemetry across Photoplethysmography (PPG Heart Rate, SpO2, HRV), Electrocardiogram (ECG sinus rhythm, AFib, asystole / cardiac arrest), 6-axis IMU (hard fall impact and immobility collapse), and core skin temperature (hypothermia and heatstroke). Incorporates a **15-second pre-alert countdown window** with an audible siren and "I'm OK" false-alarm dismissal, automatically escalating to a Medical SOS with attached clinical diagnostics if uncancelled. When disconnected or unpaired, organ readings safely zero out (`0 BPM`, `0.0% SpO2`, `0.0°C Temp`), clinical alarms are suppressed, and an intuitive pairing banner guides the user.
4. **Web Emergency Operations Center (Next.js 14 / TypeScript / Tailwind CSS):** Serves as a centralized GIS monitoring console for security dispatchers. It delivers high-accuracy campus mapping (Leaflet / OpenStreetMap), turn-by-turn multi-modal route navigation (OSRM), live in-browser responder patrol and convergence simulation (`[▶ Simulate Responders]`), direct table-row action buttons (`[⚡ Dispatch]`, `[En Route]`, `[Arrived]`, `[Resolve]`), and inline responder allocation.
5. **Autonomous IoT Call-Box Station (ESP8266 + Arduino Uno R3):** A physical embedded hardware station deployed at campus landmarks. An ESP8266 NodeMCU handles Wi-Fi connectivity, TLS-encrypted BearSSL HTTPS communication to Supabase, push button debounce, and continuous gas (MQ-2) and temperature (DHT11) monitoring with consecutive-breach noise filtering (`BREACH_CONFIRM_COUNT = 3`). An isolated Arduino Uno R3 drives dual 16×2 I2C LCD displays and status LEDs via an inter-board UART serial protocol.
6. **Cloud Backend & Intelligent Dispatch Engine (Supabase & Firebase):** Utilizes PostgreSQL with Row Level Security (RLS) across all tables, an automated database trigger calculating Haversine geodesic proximity to dispatch the nearest qualified responder, real-time WebSocket state synchronization, and secure serverless Edge Functions for Firebase Cloud Messaging (FCM) push notifications.

This proposal outlines the problem context, engineering objectives, technical architecture, integrated team structure, work breakdown, and implementation plan for the Integrated Team and Engineering Project course.

---

## 2. Problem Statement and Motivation

### 2.1 The Operational Challenge
University campuses resemble dense urban micro-environments where thousands of students, faculty, and personnel live and work across numerous facilities, dormitories, and research laboratories. During emergencies—such as severe trauma, violent assault, building fires, toxic chemical spills, or laboratory gas leaks—every passing second directly influences life-safety outcomes.

### 2.2 Critical Vulnerabilities in Current Systems
A comprehensive field and engineering analysis reveals several systemic vulnerabilities in conventional campus emergency handling:

* **Fragmented, Ambiguous Reporting:** Traditional reporting relies on direct phone calls to gatehouse phones or verbal word-of-mouth. Distressed callers must describe their location verbally under acute stress, resulting in spatial ambiguity, disorientation, and prolonged search times for responders.
* **Lack of Spatial Awareness & Manual Dispatch:** Dispatchers possess no real-time telemetry regarding responder locations or duty status. Finding and routing the nearest qualified guard or medical personnel requires slow radio communication.
* **Network Fragility as a Single Point of Failure:** Typical smartphone safety apps rely completely on active Wi-Fi or mobile data connections (4G/5G). During localized power outages, network congestion, or SIM data exhaustion, these applications fail completely, stranding users without a lifeline.
* **Cognitive Delay Under Panic (Hick's Law):** High-stress emergencies induce acute cognitive freeze and motor impairment. Emergency user interfaces that require filling out complex forms, navigating multi-level menus, or clicking secondary confirmation dialogues induce dangerous decision paralysis.
* **Incapacity and Unconscious Collapse:** Victims of sudden physical trauma, cardiac arrest, respiratory failure, or violent assault cannot unlock a phone or hold a touchscreen button. Without automated physiological monitoring, these incidents remain undetected until bystanders notice.
* **Student Privacy and Surveillance Apprehension:** Mandating campus safety software that continuously tracks GPS locations or streams biometric telemetry creates an invasive surveillance apparatus. Students routinely uninstall or reject safety apps that violate their personal privacy.
* **Unmonitored Infrastructure Hazards:** Laboratories, server rooms, and kitchen facilities remain unmonitored for environmental threats during off-hours, allowing smoke, fires, or gas leaks to cause catastrophic damage before being visually noticed.

```text
CURRENT CAMPUS DEFICIENCIES                CAMPUSSAFE ENGINEERING SOLUTION
┌────────────────────────────────┐         ┌────────────────────────────────┐
│ Slow verbal phone reporting    │  ────→  │ GPS-tagged 1-tap & shake SOS   │
│ Inaccurate location estimates  │  ────→  │ Automated Haversine dispatch   │
│ Total blackout during data loss│  ────→  │ Dual-channel offline SMS queue │
│ High cognitive decision delay  │  ────→  │ Direct zero-friction selection │
│ Unconscious medical collapse   │  ────→  │ Smartwatch Vital Organ Sentinel│
│ Invasive campus surveillance   │  ────→  │ Zero Passive Tracking / Opt-In │
│ Unmonitored night facilities   │  ────→  │ Autonomous IoT hazard nodes    │
└────────────────────────────────┘         └────────────────────────────────┘
```

---

## 3. Project Objectives

### 3.1 General Objective
To design, implement, integrate, and evaluate **CampusSafe**, an enterprise-grade emergency response platform uniting cross-platform mobile software, wearable biometrics, a web emergency operations dashboard, and IoT sensor stations to minimize incident reporting latency and automate responder coordination across the university campus under strict privacy-preserving principles.

### 3.2 Specific Technical Objectives
1. **Mobile Life-Safety & Wearable Client (Flutter):**
   * Deliver an accessible mobile client for Android and iOS supporting authenticated **Student** and **Staff** onboarding through a **5-step flow** (`Account` → `Role` → `Contacts` → `Consent` → `Campus`).
   * Implement mandatory dual life-safety emergency contacts: a user-entered Parent/Guardian contact and the pre-configured University Emergency Operations Hotline (`0920304050`).
   * Enforce **strict opt-in sensor defaults** (`false`) and a **Zero Passive Tracking Guarantee**, ensuring sensor heuristics run 100% locally on-device with zero passive operator polling in standby.
   * Engineer dual-activation SOS triggers: a deliberate 3-second hold gesture with a progress indicator, and an accelerometer-based hands-free Shake-to-SOS trigger (`sensors_plus` multi-spike thresholding $>22.0\text{ m/s}^2$) for sudden trauma or physical restraint.
   * Implement a zero-friction Direct Emergency Type Selection flow (Medical and Security), eliminating intermediate confirmation dialogs to minimize decision time under Hick's Law.
   * Deploy a **Wearable Smartwatch Vital Organ Monitoring Sentinel** tracking PPG (Heart Rate, SpO2, HRV), ECG (cardiac arrest, AFib), 6-axis IMU (hard fall & collapse), and skin temperature, with a 15-second false-alarm cancellation countdown, automated Medical SOS escalation, and zeroed values with alarm suppression when disconnected.
   * Guarantee 100% dispatch continuity during internet blackouts through automated dual-channel offline resilience: transactional local SQLite queueing (`campussafe_queue.db`) paired with automated background cellular SMS dispatch (native Android `MethodChannel` / `SmsManager` and `url_launcher`) with exact GPS coordinates and Google Maps links.
   * Harden mobile layouts against RenderBox/RenderFlex crashes on compact physical screens (e.g. 720×1344) and guarantee resilient startup against uninitialized Supabase assertions.
2. **Web Emergency Operations Center (Next.js 14):**
   * Construct a real-time GIS command dashboard utilizing Leaflet and OpenStreetMap bounded to university geography (`ADAMA_CAMPUS_BOUNDS`).
   * Implement direct row-level table action buttons (`[⚡ Dispatch]`, `[En Route]`, `[Arrived]`, `[Resolve]`) and an inline responder selector on the live incidents table.
   * Implement an interactive in-browser responder simulation toolbar (`[▶ Simulate Responders]`, `[⏸ Pause]`, `[↺ Reset]`) supporting dynamic multi-modal route calculations (OSRM) along campus pathways.
   * Align database constraints with dashboard responder availability states (`available`, `busy`, `offline`).
3. **Embedded IoT Hardware Call-Box (ESP8266 + Arduino Uno R3):**
   * Build a standalone two-board station combining an ESP8266 NodeMCU network controller (Wi-Fi, BearSSL TLS HTTPS REST client, push button debounce, and MQ-2 gas and DHT11 temp sensors) with an isolated Arduino Uno R3 display controller driving dual 16×2 I2C LCDs over a 9600-baud UART serial command protocol.
   * Implement autonomous incident creation for **Fire Hazard** and **Accident Hazard** with consecutive-breach software debouncing (`BREACH_CONFIRM_COUNT = 3`) to suppress sensor noise.
4. **Cloud Backend & Intelligent Dispatch Engine (Supabase):**
   * Architect a normalized PostgreSQL schema with Row Level Security (RLS) isolating user data, emergency contacts, and active incidents.
   * Implement a database-level PL/pgSQL trigger calculating geodesic Haversine distances to automatically rank and assign the closest available, qualified on-duty responder upon incident creation.
   * Configure a dual notification pipeline: Supabase Realtime WebSockets for active UI updates, and serverless Deno Edge Functions dispatching Firebase Cloud Messaging (FCM) push notifications to backgrounded responder devices.

---

## 4. System Architecture and Design

CampusSafe follows a modular, three-tier architecture organized around a centralized cloud backend. All three client layers communicate strictly through the backend, ensuring complete security isolation, auditability, and edge data minimization.

```text
                                  CAMPUSSAFE PLATFORM
                                           │
          ┌────────────────────────────────┼─────────────────────────────────┐
          │                                │                                 │
          ▼                                ▼                                 ▼
    MOBILE CLIENT                 OPERATIONS DASHBOARD               IoT CALL-BOX STATION
   (Flutter / Dart)            (Next.js 14 / TypeScript)         (ESP8266 + Arduino Uno R3)
   - 5-Step Consent Onboarding  - Leaflet GIS Campus Map         - Physical SOS Panic Button
   - Zero Passive Tracking      - Direct Row Action Buttons      - MQ-2 Gas / Smoke Sensor
   - 3s Hold & Shake-to-SOS     - Inline Quick Dispatch          - DHT11 Temp / Humidity
   - Smartwatch Vital Sentinel  - [▶ Simulate Responders]        - Dual 16x2 I2C LCDs
   - Direct Emergency Flow      - Availability Constraint Align  - 9600-Baud UART Protocol
   - Offline SMS / SQLite       - Seed Error Caching             - Consecutive Breach Debounce
          │                                │                                 │
          │  HTTPS / WebSockets            │  HTTPS / WebSockets             │  HTTPS POST (BearSSL)
          └───────────────────────┬────────┴─────────────────────────────────┘
                                  │
                                  ▼
                         SUPABASE CLOUD ENGINE
          ┌─────────────────────────────────────────────────────────────────┐
          │ - PostgreSQL 15+ Engine with Row Level Security (RLS)           │
          │ - PL/pgSQL Trigger: trigger_auto_dispatch (Haversine Formula)   │
          │ - Supabase Realtime Channels (PostgreSQL WAL WebSocket Pub/Sub) │
          │ - Supabase Auth & Role-Based Access Control (RBAC)              │
          │ - Serverless Edge Functions (Deno / TypeScript)                 │
          └───────────────────────────────┬─────────────────────────────────┘
                                          │
                                          ▼
                              FIREBASE CLOUD MESSAGING
                                (Background Wakeup)
                                          │
                                          ▼
                              FIELD RESPONDER DEVICES
```

### 4.1 Component Breakdown

#### A. Mobile Application (Flutter / Dart)
* **Presentation & State:** Riverpod 2.5 reactive state management and GoRouter 14.2 declarative routing.
* **Privacy-First Consent Architecture:** 5-step registration onboarding; strict opt-in sensor defaults; Zero Passive Tracking guarantee with on-device edge heuristics; revocable consent in Settings with legal rights modal dialog; non-intrusive Home Page opt-in card.
* **Wearable Smartwatch Vital Sentinel:** Continuously evaluates PPG (Heart Rate, SpO2, HRV), ECG (cardiac arrest, AFib), 6-axis IMU (hard fall & collapse), and skin temperature. Features a 15-second pre-alert countdown with "I'm OK" dismissal, escalating automatically to a Medical SOS with attached clinical diagnostics if uncancelled.
* **Safe Disconnected State:** When a smartwatch is unpaired, vitals zero out (`0 BPM`, `0.0% SpO2`, `0.0°C Temp`), clinical alarms are disarmed to eliminate false dispatches, and an intuitive pairing banner guides the user.
* **Dual-Activation Triggers:** 3-second hold button with progress ring and hands-free Shake-to-SOS (`sensors_plus` multi-spike thresholding $>22.0\text{ m/s}^2$).
* **Direct Emergency Selection:** Eliminates confirmation prompts under Hick's Law; routes directly to **Medical** or **Security** disciplines.
* **Offline Telephony Integration:** Background SMS dispatch via Android `MethodChannel` (`SmsManager`) when network data is lost, paired with a local `Sqflite` transactional queue (`campussafe_queue.db`) that auto-retries once data is restored.
* **Defensive Layout & Startup:** Resolved RenderBox and RenderFlex crashes across compact screens (720×1344 and 320px) using `Flexible`, `Expanded`, `FittedBox`, and `SingleChildScrollView`; hardened `Env.isConfigured` against uninitialized Supabase assertions.

#### B. Web Operations Dashboard (Next.js 14 / React / TypeScript)
* **Application Framework:** Next.js 14 App Router utilizing Server Components for performance and Client Components for map interactivity.
* **GIS Campus Mapping:** Leaflet 1.9 integrated with OpenStreetMap, displaying live incident beacons, campus polygon perimeters, and OSRM turn-by-turn routing.
* **Operations Table:** Direct action controls (`[⚡ Dispatch]`, `[En Route]`, `[Arrived]`, `[Resolve]`) and an inline responder selector for immediate intervention without modal navigation.
* **Simulation Suite:** In-browser simulation toolbar (`[▶ Simulate Responders]`) modeling responder patrol routines, convergence, and live ETA calculations, supported by `simulate_responders.js`.
* **Resilient Backend Fallbacks:** In-memory caching and default seeds (`DEFAULT_CAMPUS_INCIDENTS`, `DEFAULT_CAMPUS_RESPONDERS`) shielding operators from remote PostgREST schema cache errors.

#### C. IoT Embedded Hardware Layer (ESP8266 + Arduino Uno R3)
* **Two-Board Separation (ADR-0005):**
  * **ESP8266 NodeMCU (Master Controller):** Owns Wi-Fi communication, BearSSL TLS handshakes, HTTPS POST delivery to Supabase, push button debounce, and sensor sampling.
  * **Arduino Uno R3 (Display Controller):** Isolated from network interfaces; parses ASCII commands over a 9600-baud UART serial link to update dual 16×2 LCDs and optical status LEDs.
* **Consecutive-Breach Noise Filtering:** Enforces three consecutive threshold violations (`BREACH_CONFIRM_COUNT = 3`) before dispatching an autonomous incident, eliminating false positives from transient smoke or heat spikes.

#### D. Centralized Cloud Engine (Supabase & Firebase)
* **Data Storage & Authorization:** PostgreSQL database enforced by Row Level Security (RLS) policies. Authenticated profiles manage personal and emergency contact information (`parent_phone`, `parent_name`, `campus_admin_phone`). Migration `20260922000001` ensures database check constraints match dashboard responder availability updates.
* **Automated Proximity Dispatch:** A database trigger calculates spherical distance via the Haversine formula across candidate on-duty responders and assigns the nearest unit instantly.
* **Notification Engine:** Realtime WebSocket broadcast for active web/mobile clients, coupled with serverless Edge Functions delivering FCM push notifications to backgrounded devices.

### 4.2 Incident Finite State Machine

Every emergency incident progresses through a strictly audited state machine:

```text
 ┌─────────┐      ┌──────────┐      ┌──────────┐      ┌────────────┐      ┌─────────┐      ┌──────────┐
 │ CREATED │ ───→ │ RECEIVED │ ───→ │ ASSIGNED │ ───→ │ RESPONDING │ ───→ │ ARRIVED │ ───→ │ RESOLVED │
 └─────────┘      └──────────┘      └──────────┘      └────────────┘      └─────────┘      └──────────┘
      │                 │                 │                 │
      └─────────────────┴─────────────────┴─────────────────┴───────────→ CANCELLED / ESCALATED / FAILED
```

Every state transition generates an immutable record in `incident_status_history` and emits a WebSocket broadcast to all connected operators.

---

## 5. Integrated Team Organization and Roles

To satisfy the engineering requirements of an Integrated Team Project, responsibilities are organized across eleven specialized engineering roles simulating an enterprise product team:

| Team Member | Engineering Role | Core Responsibilities & Stack |
| :--- | :--- | :--- |
| **Kaleb Chanchal** | **Project Coordinator & System Architect** | Architecture design, ADR governance, system integration, project tracking |
| **Team Member 2** | **Lead Mobile App Developer** | Flutter UI, Riverpod state, GoRouter navigation, emergency flows |
| **Team Member 3** | **Mobile Systems & Telephony Engineer** | Android SMS channel, SQLite offline queue, `sensors_plus` shake, GPS |
| **Team Member 4** | **Lead Web / Dashboard Developer** | Next.js 14, TypeScript, incident triage table, Supabase Realtime sync |
| **Team Member 5** | **Web GIS & Simulation Engineer** | Leaflet mapping, OSRM routing, campus geofencing, responder simulation |
| **Team Member 6** | **IoT Firmware & Network Engineer** | ESP8266 firmware (C++), BearSSL HTTPS, Wi-Fi failover, button debounce |
| **Team Member 7** | **Embedded Hardware & Sensor Specialist** | Arduino Uno firmware, UART protocol, dual LCDs/buzzer, MQ-2 & DHT11 |
| **Team Member 8** | **Cloud Database & Security Architect** | PostgreSQL schema, Row Level Security (RLS), Supabase Auth / RBAC |
| **Team Member 9** | **Backend Services & Notifications Engineer** | Haversine dispatch triggers, Deno Edge Functions, Firebase push (FCM) |
| **Team Member 10** | **QA, Security & Test Automation Lead** | Flutter / Jest test suites, CI/CD, STRIDE threat modeling, RLS auditing |
| **Team Member 11** | **UI/UX & Documentation Specialist** | Figma design system, HCI workflows, technical documentation, schematics |

---

## 6. Work Breakdown Structure (WBS) & Implementation Roadmap

### 6.1 Work Breakdown Structure
* **1.0 Requirements & Architectural Foundations:** Define shared contracts, establish Git repository, configure environment variables, and draft Architecture Decision Records (ADRs).
* **2.0 Database & Cloud Backend Implementation:** Implement PostgreSQL schema migrations, Row Level Security policies, PL/pgSQL Haversine dispatch trigger, and Deno FCM Edge Functions.
* **3.0 Mobile Application Development:** Build 5-step onboarding with informed consent, Zero Passive Tracking architecture, dual emergency contacts, 3-second hold button, hands-free shake detector, direct emergency selector, and automated offline SMS service.
* **4.0 Wearable Biometrics & Health Sentinel:** Implement `SmartwatchVitalService` evaluating PPG, ECG, IMU fall, and skin temperature with a 15-second pre-alert countdown, un-paired zeroing, and automated Medical SOS escalation.
* **5.0 Operations Dashboard Development:** Construct Next.js console, Leaflet campus map, direct row action buttons, inline responder selector, and live responder movement simulation.
* **6.0 Embedded IoT Station Assembly:** Wire ESP8266 and Arduino Uno circuits, implement C++ firmware, establish UART command protocol, and verify BearSSL HTTPS event posting.
* **7.0 System Hardening & Verification:** Mobile layout overflow resolution (720×1344 and 320px screens), offline startup resilience, automated test suites (80/80 mobile tests passing), and full scenario validation.
* **8.0 Final Demonstration & Reporting:** Final project demonstration, video documentation, code review, and project report presentation.

### 6.2 12-Week Implementation Schedule

```text
Week 01 - 02: Requirements Analysis, Architecture Design & Data Contract Definition
Week 03 - 04: PostgreSQL Migrations, RLS Policies, Haversine Trigger & Edge Functions
Week 05 - 06: Mobile Core: 5-Step Consent Flow, Shake-to-SOS & Direct Emergency Selection
Week 07 - 08: Wearable Smartwatch Vital Sentinel, False-Alarm Cancellation & Disconnected State
Week 09 - 10: Next.js EOC Dashboard, Leaflet GIS Map & Responder Simulation Suite
Week 11:      IoT Station Firmware (ESP8266 + Arduino Uno) & Sensor Calibration
Week 12:      System Integration, Screen Layout Hardening, End-to-End Verification & Review
```

---

## 7. Technology Stack Matrix

| Tier / Subsystem | Technology | Version | Engineering Justification |
| :--- | :--- | :--- | :--- |
| **Mobile Client** | Flutter / Dart | 3.x / 3.x | High-performance compiled native UI across Android and iOS from a single codebase. |
| **State Management** | Flutter Riverpod | 2.5 | Compile-safe, testable reactive state management without UI tight-coupling. |
| **Mobile Navigation** | GoRouter | 14.2 | Declarative URL-based routing with authentication state guards. |
| **Inertial Sensing** | `sensors_plus` | 5.0 | High-frequency accelerometer stream analysis for hands-free Shake-to-SOS. |
| **Biometric Sentinel**| `SmartwatchVitalService` | Custom | On-device edge physiological evaluation (PPG, ECG, IMU, Temp) with 15s pre-alert. |
| **Offline Telephony** | Android `MethodChannel` / `url_launcher` | 6.2 | Direct hardware-level carrier SMS dispatch during total cellular data loss. |
| **Local Storage** | `sqflite` / `shared_preferences` | 2.4 | Transactional local queueing for offline resilience and emergency contact caching. |
| **Web Dashboard** | Next.js / React / TypeScript | 14.2 / 18 / 5.3 | Modern React Server Components architecture with strict type safety. |
| **Dashboard Styling**| Tailwind CSS | 3.4 | Utility-first responsive design tokens aligned with Material Design 3. |
| **Campus Mapping** | Leaflet / OpenStreetMap | 1.9 | Lightweight, open-source GIS engine with zero commercial licensing costs. |
| **Routing Service** | Open Source Routing Machine (OSRM) | v5 | Accurate multi-modal turn-by-turn routing for campus pedestrian and vehicle paths. |
| **Database Engine** | PostgreSQL (via Supabase) | 15+ | Relational data integrity, ACID compliance, and engine-level Row Level Security. |
| **Realtime Sync** | Supabase Realtime | WebSockets | Low-latency bi-directional pub/sub updates driven by PostgreSQL write-ahead logs. |
| **Serverless Engine**| Supabase Edge Functions | Deno / TS | Isolated, secure execution environment for Firebase Cloud Messaging dispatch. |
| **Push Notifications**| Firebase Cloud Messaging (FCM) | HTTP v1 | Industry-standard wake-up push notifications for backgrounded responder devices. |
| **IoT Controller** | ESP8266 NodeMCU Amica v2 | C++ | Low-cost 802.11 b/g/n Wi-Fi controller with BearSSL TLS HTTPS capabilities. |
| **Display Controller**| Arduino Uno R3 | C++ | Dedicated I/O expander for dual 16×2 LCD screens via isolated UART serial protocol. |

---

## 8. Resource Requirements & Bill of Materials (BOM)

### 8.1 Hardware Prototype Budget

| Component | Model / Specification | Qty | Unit Cost (ETB) | Total Cost (ETB) |
| :--- | :--- | :--- | :--- | :--- |
| **IoT Main Controller** | ESP8266 NodeMCU Amica v2 | 1 | 850 ETB | 850 ETB |
| **IoT Display Controller**| Arduino Uno R3 (ATmega328P) | 1 | 950 ETB | 950 ETB |
| **Gas / Smoke Sensor** | MQ-2 Combustible Gas Sensor | 1 | 450 ETB | 450 ETB |
| **Temperature / Humidity**| DHT11 Digital Sensor | 1 | 350 ETB | 350 ETB |
| **Alphanumeric Displays** | 16×2 I2C Character LCD Modules | 2 | 600 ETB | 1,200 ETB |
| **Acoustic Actuator** | 5V Active Buzzer Module | 1 | 150 ETB | 150 ETB |
| **Visual Indicators** | High-Brightness LEDs (R, Y, G) | 6 | 15 ETB | 90 ETB |
| **Manual Trigger** | Momentary Tactile Push Button | 2 | 30 ETB | 60 ETB |
| **Prototyping Media** | Solderless Breadboards & Jumper Wires | 1 Set | 400 ETB | 400 ETB |
| **Total Hardware BOM** | — | — | — | **~4,500 ETB** |

### 8.2 Software & Cloud Infrastructure
All software tools, frameworks, and cloud tiers utilized in the project are open-source or leverage free educational/developer tiers:
* **Operating Systems & IDEs:** Linux / Windows 11, VS Code, Android Studio, Arduino IDE 2.x.
* **Cloud Infrastructure:** Supabase Free Developer Tier (PostgreSQL, Realtime, Auth, Edge Functions).
* **Push Services:** Google Firebase Cloud Messaging (Free Tier).
* **Mapping Services:** OpenStreetMap tile servers and public OSRM routing endpoints.

---

## 9. Risk Analysis and Mitigation Strategies

| Risk Identifier | Potential Threat | Severity | Likelihood | Engineering Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **TECH-01: Connectivity Collapse** | Campus Wi-Fi and mobile data networks drop during active crisis. | **Critical** | High | **Dual-Channel Offline Resilience:** App buffers request in SQLite (`campussafe_queue.db`) and automatically fires background carrier SMS with exact GPS links to Parent and Admin (`0920304050`). |
| **TECH-02: Human Cognitive Delay** | Distressed individuals freeze when confronted with complex menus. | **High** | High | **Zero-Friction Selection (Hick's Law):** Eliminated intermediate confirmation dialogs; focused user choices directly on Medical and Security. |
| **TECH-03: Physical Incapacitation** | Victim is physically restrained or injured and cannot touch the screen. | **Critical** | Medium | **Hands-Free Shake Trigger:** Accelerometer stream monitoring (`sensors_plus`) triggering alerts upon rapid multi-spike deceleration ($>22.0\text{ m/s}^2$). |
| **TECH-04: False Sensor Alarms** | Dust or transient temperature spikes trigger false emergency alerts. | **Medium** | High | **Consecutive-Breach Debounce:** Firmware requires 3 consecutive threshold breaches (`BREACH_CONFIRM_COUNT = 3`) before raising an alarm. |
| **TECH-05: Microcontroller Pin Depletion**| ESP8266 lacks GPIOs to drive dual LCDs and read sensors concurrently. | **High** | High | **Decoupled Two-Board Architecture (ADR-0005):** Arduino Uno R3 serves as dedicated display controller over a 9600-baud UART serial protocol. |
| **TECH-06: Viewport Pixel Overflows** | RenderBox and RenderFlex errors crash UI on compact mobile devices (720×1344, 320px). | **Medium** | High | **Defensive Layout Refactoring:** Replaced rigid rows with responsive `Wrap` widgets, added scroll views, applied `Expanded`/`Flexible` ellipsis guards, and scaled buttons with `FittedBox`. |
| **TECH-07: Schema Cache Discrepancies** | Remote PostgREST schema cache errors (`PGRST205`) cause client crashes. | **Medium** | Medium | **Resilient Fallback Caching:** Guarded repository stream error handling (`.handleError`) and implemented default fallback data models in the dashboard. |
| **TECH-08: Passive Surveillance Concerns** | Students fear administrative tracking and reject safety software. | **Critical** | High | **Zero Passive Tracking Architecture:** 5-step consent flow, strict opt-in defaults (`false`), 100% on-device edge heuristics, and zero administrative polling in standby. |
| **TECH-09: False Smartwatch Dispatches** | Smartwatch un-pairing or dropped watch triggers accidental medical dispatch. | **High** | High | **Disconnected State Zeroing:** Telemetry zeroes out (`0 BPM`, `0% SpO2`, `0°C`) with alarms suppressed when un-paired, backed by a 15-second pre-alert cancellation window. |

---

## 10. Expected Deliverables and Verification Plan

At the completion of the Integrated Team and Engineering Project course, the team will deliver:

1. **Fully Functional Cross-Platform Mobile Application:** Android APK supporting 5-step privacy consent onboarding, Zero Passive Tracking, dual emergency contacts, 3s hold and shake-to-SOS, Wearable Smartwatch Vital Sentinel with 15s pre-alert countdown, zero-friction emergency selection, and automated offline SMS fallback—supported by **80/80 passing unit/widget tests** and 0 analyzer issues.
2. **Operational Web Operations Dashboard:** Production Next.js dashboard deployed with live campus map tracking, direct row action buttons, inline responder dispatch, and live responder movement simulation.
3. **Operational IoT Call-Box Station:** Assembled dual-board prototype with functional push-button SOS trigger, MQ-2 gas sensing, DHT11 thermal monitoring, consecutive-breach noise debouncing, and dual LCD status display.
4. **Centralized Cloud Backend:** Fully configured Supabase project with version-controlled migrations, RLS policies, PL/pgSQL Haversine auto-dispatch trigger, aligned responder availability constraints, and FCM notification edge functions.
5. **Comprehensive Technical Documentation & Codebase:** Fully documented, modular GitHub repository with unit tests, hardware wiring diagrams, and a complete system demonstration video.

### Verification Scenarios
The integrated system will be validated through seven end-to-end demonstration scenarios:
1. **Scenario 1 (Medical SOS):** Mobile hold/shake trigger $\rightarrow$ Haversine proximity auto-dispatch $\rightarrow$ Real-time dashboard update and FCM responder notification $\rightarrow$ Incident resolution.
2. **Scenario 2 (Physical IoT SOS):** Hardware button press $\rightarrow$ ESP8266 HTTPS POST to Supabase $\rightarrow$ Dashboard alert beacon $\rightarrow$ Arduino LCD status update (`TRIGGERED`).
3. **Scenario 3 (Autonomous Environmental Alert):** Gas/smoke $>400\text{ ppm}$ sustaining 3 consecutive breaches $\rightarrow$ Automatic incident creation $\rightarrow$ EOC alert and LCD telemetry display (`ALERT:GAS`).
4. **Scenario 4 (Anonymous Safety Report):** Student submits hazard report with photo attachment $\rightarrow$ Stored anonymously in backend $\rightarrow$ Triaged in dashboard safety reports view.
5. **Scenario 5 (Automated Offline SMS Fallback):** Airplane mode activated $\rightarrow$ SOS triggered $\rightarrow$ SQLite queue buffers request $\rightarrow$ Native Android SMS automatically transmits GPS coordinates and Google Maps link to Parent and University Admin (`0920304050`).
6. **Scenario 6 (Smartwatch Vital Emergency & Fall Sentinel):** Biometric breach or fall detected $\rightarrow$ 15-second pre-alert countdown $\rightarrow$ Automated Medical SOS with clinical diagnostics transmitted to responders, Parent, and Admin.
7. **Scenario 7 (Privacy Consent & Revocation):** User completes registration with sensors OFF $\rightarrow$ Reviews Zero Passive Tracking banner in Settings $\rightarrow$ Opts in or revokes consent $\rightarrow$ Live status reflects on Home Page card.

---

## 11. Conclusion

CampusSafe demonstrates how integrated software engineering, mobile computing, wearable physiological sensing, real-time cloud infrastructure, and low-cost embedded hardware can be synthesized to solve a critical real-world challenge. By prioritizing fail-safe offline mechanisms, zero-friction interaction design under Hick's Law, automated spatial dispatch, and uncompromising privacy-first data minimization through its Zero Passive Tracking Guarantee, the project delivers a practical, highly scalable, and cost-effective emergency management platform suited to university campuses in developing regions.
