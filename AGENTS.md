# CampusSafe — AGENTS.md

## 1. Purpose

This file defines how human developers and AI coding agents must work on CampusSafe.

CampusSafe has three primary engineering components:

1. **Mobile Application**
2. **Web Emergency Operations Dashboard**
3. **IoT / Embedded Hardware**

They are separate implementation areas but one system.

The technical architecture is documented in `ARCHITECTURE.md`.

The project definition is documented in `PROJECT.md`.

The development roadmap is documented in `PLAN.md`.

---

# 2. Source-of-Truth Hierarchy

Use the following hierarchy:

```text
PROJECT.md
    ↓
What CampusSafe is and why it exists

ARCHITECTURE.md
    ↓
How CampusSafe is technically structured

AGENTS.md
    ↓
How people and AI agents should work

PLAN.md
    ↓
What should be built and in what order

README.md
    ↓
Developer/public-facing project overview
```

If documentation conflicts:

1. Identify the conflict.
2. Do not blindly choose one.
3. Determine which document reflects the intended current architecture.
4. Update the affected documentation.
5. Then modify code.

Never knowingly leave documentation and implementation contradictory.

---

# 3. Golden Rule

> **Understand before changing.**

Before modifying code:

1. Read the relevant documentation.
2. Read `PLAN.md`.
3. Identify the component.
4. Inspect the existing implementation.
5. Search for consumers/dependencies.
6. Understand existing conventions.
7. Determine whether the task affects shared contracts.
8. Implement the smallest coherent change.
9. Test it.
10. Update documentation if required.

Do not rewrite working code merely because you personally prefer another pattern.

---

# 4. Component Boundaries

## Mobile

Typical location:

```text
apps/mobile/
```

Owns:
- Flutter UI.
- Authentication screens.
- Registration.
- User profile.
- SOS.
- GPS/location.
- Notifications.
- Incident tracking.
- Responder workflows.
- Anonymous reporting.

## Dashboard

Typical location:

```text
apps/dashboard/
```

Owns:
- Next.js UI.
- Incident monitoring.
- Campus map.
- Responder management.
- Device monitoring.
- Reports.
- Analytics.
- User administration.
- Audit visualization.

## IoT

Typical location:

```text
iot/
```

Owns:
- ESP8266 NodeMCU & ESP32-CAM firmware.
- SOS stations (physical push button).
- Sensor nodes (heat/gas, max 2 sensors per ESP8266).
- ESP32-CAM independent camera event node.
- Device communication (Wi-Fi / HTTPS).
- Heartbeats.
- Device telemetry/events.

## Shared/Backend

Typical locations:

```text
backend/
packages/shared/
```

Owns:
- Backend services.
- Database interactions.
- Shared types.
- Contracts.
- Validation.
- Business rules.
- Authorization.
- Realtime coordination.

---

# 5. Current Technology Baseline

Current baseline:

```text
Mobile       → Flutter / Dart
Dashboard    → Next.js / React / TypeScript
Backend      → Supabase
Database     → PostgreSQL
Auth         → Supabase Auth
Realtime     → Supabase Realtime
Storage      → Supabase Storage
IoT          → ESP8266 NodeMCU / ESP32-CAM
Firmware     → C/C++ (Arduino IDE)
Network      → Wi-Fi / HTTPS
Location     → Mobile GPS
```

This is not immutable.

Technology changes must follow the Technology Change Protocol.

---

# 6. Technology Change Protocol

When a developer says:

> "Replace X with Y."

or:

> "Add/remove/change a technology."

Do **not** immediately modify code.

## Step 1 — Search

Search the entire repository for:
- Technology name.
- Packages.
- Imports.
- Configuration.
- Environment variables.
- Documentation.
- CI/CD references.
- Tests.
- Deployment scripts.
- Architecture diagrams.

## Step 2 — Impact Analysis

Check:

```text
Mobile?
Dashboard?
Backend?
Database?
IoT?
Authentication?
Realtime?
Storage?
Security?
Testing?
Deployment?
Documentation?
```

## Step 3 — Explain the Impact

Before a major architectural change, summarize:

```text
Current:
X

Proposed:
Y

Affected components:
...

Benefits:
...

Risks:
...

Migration work:
...

Testing required:
...
```

Do not make a major architecture decision silently.

## Step 4 — Update Architecture

Update:

```text
ARCHITECTURE.md
```

for technical architecture changes.

## Step 5 — Update Project Definition

Update:

```text
PROJECT.md
```

if the change affects the system's defined technology, capabilities, scope, or architecture.

## Step 6 — Update Plan

Update:

```text
PLAN.md
```

to:
- Remove obsolete tasks.
- Add migration tasks.
- Add replacement implementation tasks.
- Update dependencies.
- Update priorities.
- Record blockers.

## Step 7 — Update Agent Rules

Update:

```text
AGENTS.md
```

only if the development workflow, tooling, security rules, or coding rules changed.

## Step 8 — Update README

Update:

```text
README.md
```

for public-facing stack/setup/architecture changes.

## Step 9 — Implement

Only after the change is understood and documented.

## Step 10 — Verify

Search again for obsolete references.

Example:

```text
Old technology references remaining?
        ↓
      YES → investigate
        ↓
       NO
        ↓
Run tests
        ↓
Verify end-to-end workflow
```

---

# 7. When to Create an ADR

For significant architecture decisions, create:

```text
docs/adr/
```

Examples:
- Replacing Supabase.
- Replacing Flutter.
- Changing realtime architecture.
- Changing database technology.
- Changing IoT communication protocol.
- Introducing a major external service.

Do not create an ADR for trivial dependency updates.

---

# 8. Shared Contracts

Treat these as cross-component contracts:

- User.
- Role.
- Responder.
- Campus location.
- Incident.
- Emergency type.
- Incident status.
- Device.
- Device event.
- Safety report.
- Audit event.
- Realtime events.

Before changing a shared contract:

1. Search all consumers.
2. Identify mobile impact.
3. Identify dashboard impact.
4. Identify backend impact.
5. Identify IoT impact.
6. Update shared definitions.
7. Update affected clients.
8. Test end-to-end.

Never silently rename/remove a shared field or event.

---

# 9. Development Priorities

Use:

```text
Correctness
    ↓
Security
    ↓
Maintainability
    ↓
Simplicity
    ↓
Performance
```

Prefer:
- Small changes.
- Reusable components.
- Strong typing.
- Clear interfaces.
- Existing dependencies.
- Incremental testing.
- Existing project conventions.

Avoid:
- Unnecessary rewrites.
- Duplicate logic.
- Premature abstraction.
- Unnecessary dependencies.
- Unrelated refactors.

---

# 10. Developer Preferences and Existing Patterns

Agents must adapt to the codebase.

Before introducing a new:
- State-management approach.
- API pattern.
- Folder structure.
- Component style.
- Error-handling pattern.
- Testing framework.
- UI component pattern.

inspect how the existing project solves the same problem.

If an existing approach is sound:

> **Reuse it.**

If it is problematic:

> Explain why before replacing it.

Do not create two competing patterns for the same problem.

---

# 11. Multi-Agent Collaboration

Multiple agents may work simultaneously.

Each agent should declare:

```text
Component:
Task:
Files likely affected:
Shared contracts affected:
Dependencies:
Tests required:
Plan item:
```

Prefer isolated branches/worktrees when available.

Avoid editing the same files concurrently without coordination.

---

# 12. Commit Rules

Use focused commits.

Examples:

```text
feat(mobile): add SOS incident creation
feat(dashboard): add live incident panel
feat(iot): add ESP32 SOS heartbeat
fix(auth): enforce responder authorization
fix(incident): prevent duplicate SOS events
docs: update architecture for realtime changes
```

Avoid:

```text
update
changes
stuff
fix
```

Do not commit secrets.

---

# 13. Security Rules

Never commit:

```text
.env
.env.local
private keys
service-role keys
API secrets
passwords
tokens
device credentials
```

Use:

```text
.env.example
```

Never rely exclusively on frontend/client-side checks for authorization.

Security-sensitive rules must be enforced by the backend/database/device layer as appropriate.

Never log:
- Passwords.
- Access tokens.
- Refresh tokens.
- Sensitive personal data unnecessarily.
- Private location data unnecessarily.

---

# 14. SOS Rules

The SOS feature is the primary system workflow.

It must:

- Be easy to activate.
- Minimize accidental activation.
- Provide immediate feedback.
- Handle network failure.
- Show submission state.
- Never claim dispatch unless confirmed.
- Never invent responder status.
- Never invent ETA.
- Preserve useful information during failures.

Preferred state model:

```text
READY
  ↓
ACTIVATING
  ↓
SENT
  ↓
RECEIVED
  ↓
ASSIGNING
  ↓
ASSIGNED
  ↓
RESPONDING
  ↓
ARRIVED
  ↓
RESOLVED
```

Exceptional states may include:

```text
CANCELLED
ESCALATED
FAILED
UNASSIGNED
```

Do not introduce states without checking all clients.

---

# 15. HCI Rules

Emergency interfaces must prioritize:

- Visibility of system status.
- Recognition over recall.
- Error prevention.
- Consistency.
- Accessibility.
- Clear hierarchy.
- Large touch targets.
- Immediate feedback.
- Minimal cognitive load.

Semantic colors:

```text
Red     → Critical
Amber   → Warning
Green   → Healthy / Resolved
Blue    → Information
Gray    → Inactive
```

Color must never be the only indicator of state.

---

# 16. Mobile Rules

Mobile agents must consider:

- Small screens.
- Touch interaction.
- Network loss.
- GPS permission denial.
- Notification permission denial.
- Battery constraints.
- Background limitations.
- Accessibility.

Never assume:
- GPS always works.
- Internet always works.
- Notifications are always enabled.

---

# 17. Dashboard Rules

Dashboard agents must prioritize:

- Situational awareness.
- Clear incident hierarchy.
- Real-time status.
- Map readability.
- Responder status.
- Critical information visibility.
- Operator efficiency.

Avoid visually overwhelming operators with unnecessary animation or information.

---

# 18. IoT Rules

Each device should have, where applicable:

```text
Device ID
Device Type
Location
Firmware Version
Connection State
Heartbeat
Timestamp
Event Type
Payload
```

Example:

```json
{
  "device_id": "SOS-ENG-01",
  "event_type": "SOS_TRIGGERED",
  "timestamp": "...",
  "location_id": "engineering-block",
  "payload": {}
}
```

Devices must not be treated as automatically trustworthy.

Validate device events on the backend.

A sensor reading is not automatically a confirmed emergency.

---

# 19. Database Rules

Use migrations for schema changes.

Before changing schema:

1. Search consumers.
2. Check migrations.
3. Update shared types.
4. Update queries.
5. Update authorization/RLS.
6. Test affected workflows.
7. Consider rollback.

Do not perform destructive schema changes casually.

---

# 20. Error Handling

Design for:

```text
Network failure
GPS failure
Backend failure
Notification failure
Permission denial
Responder unavailable
Device offline
Duplicate event
Invalid input
Unauthorized request
```

Errors should be:
- Understandable.
- Actionable.
- Safe.
- Logged appropriately.

Do not silently swallow critical errors.

---

# 21. Testing

Important features should have appropriate:

- Unit tests.
- Widget/component tests.
- Integration tests.
- Authorization tests.
- End-to-end tests.

Critical end-to-end workflow:

```text
Mobile SOS
    ↓
Backend
    ↓
Incident
    ↓
Responder selection
    ↓
Notification
    ↓
Responder action
    ↓
Dashboard realtime update
    ↓
Resolution
```

Test failure cases too.

---

# 22. Definition of Done

A task is complete when:

- [ ] Implementation is complete.
- [ ] Relevant tests pass.
- [ ] Security impact considered.
- [ ] Error states handled.
- [ ] Existing conventions followed.
- [ ] UI follows design system.
- [ ] Shared contracts updated if required.
- [ ] Documentation updated if required.
- [ ] `PLAN.md` updated.
- [ ] No obsolete references remain.
- [ ] Feature works in its intended end-to-end workflow.

---

# 23. PLAN.md Rules

`PLAN.md` is the living development roadmap.

Update it when:

- A task completes.
- A task changes.
- A task becomes blocked.
- A new major task appears.
- Architecture changes.
- Scope changes.
- Dependencies change.

Do not create a competing master plan.

The master plan remains:

```text
PLAN.md
```

Detailed component plans may exist, but they must remain consistent with it.

---

# 24. Before Starting Any Task

Every agent should establish:

```text
Component:
Current state:
Requested change:
Relevant architecture:
Files affected:
Shared contracts:
Dependencies:
Security implications:
Testing:
PLAN.md item:
```

Then implement.

---

# 25. Final System Principle

CampusSafe is not:

```text
Mobile + Dashboard + Random IoT
```

It is:

```text
                 ONE SYSTEM
                     │
       ┌─────────────┼─────────────┐
       │             │             │
    MOBILE       DASHBOARD        IoT
       │             │             │
       └─────────────┼─────────────┘
                     │
                  BACKEND
                     │
                  DATABASE
                     │
                  INCIDENT
                     │
                 RESPONSE
```

Every engineering decision should be evaluated by asking:

> **Does this make CampusSafe more correct, secure, maintainable, testable, and effective as one integrated emergency-response system?**
