# ADR 0006: Removal of ESP32-CAM from IoT Scope

## Status
Accepted (supersedes camera node component in ADR 0004 & ADR 0005)

## Date
2026-09-18

## Context
ADR 0004 and ADR 0005 specified an independent camera event node using the **ESP32-CAM** module to provide automated visual incident detection directly to the CampusSafe backend.

During the hardware acquisition and prototyping phase, the team was unable to procure the ESP32-CAM module. Furthermore, incorporating visual verification through an independent embedded camera introduced extraneous hardware sourcing constraints without being strictly necessary for core campus emergency workflows.

## Decision
Remove the **ESP32-CAM** module from the active CampusSafe IoT and hardware prototype scope:
1. The IoT hardware implementation is exclusively focused on the optimized dual-board station:
   - **NodeMCU ESP8266 Amica v2** (Master Controller: push button, MQ-2 gas/smoke sensor, DS18B20 temperature probe, local buzzer alert, and direct Supabase incident dispatch).
   - **Arduino Uno R3** (Display Controller: driving two 1602 LCD displays via UART serial commands).
2. Visual documentation and photographic incident reporting remain fully supported via the CampusSafe Mobile Application (Flutter), where users and responders submit photo attachments directly during emergency reports.
3. Remove the placeholder `iot/esp32-cam/` directory from the repository.

## Consequences

### Positive
- **Streamlined Bill of Materials:** Eliminates dependency on unprocured hardware and simplifies wiring/power considerations.
- **Zero Risk to Core Safety Operations:** The critical emergency SOS button, environmental hazard detection (gas/heat), local audio/visual alarms, and cloud incident dispatching are entirely unaffected.
- **Clean Architectural Alignment:** Documentation across `ARCHITECTURE.md`, `PROJECT.md`, `PLAN.md`, `AGENTS.md`, and `README.md` now accurately reflects physical hardware capabilities.

### Negative / Trade-offs
- No automated visual image feed is triggered from fixed IoT stations upon emergency button press; responders rely on user-submitted photos or mobile responder observations.
