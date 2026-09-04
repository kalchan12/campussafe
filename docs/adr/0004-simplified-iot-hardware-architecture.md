# ADR 0004: Simplified IoT Hardware Architecture (ESP8266 & ESP32-CAM)

## Status
Accepted

## Date
2026-09-04

## Context
The previous hardware architecture outlined a multi-tier IoT network involving complex ESP32 nodes (3-in-1 environmental nodes with DHT22, MQ-2, and PIR, multi-peripheral security access nodes with RC522 RFID readers and reed switches, and standalone warning nodes).

In practice, prototyping and deploying such densely configured nodes on campus leads to high hardware complexity, increased points of failure, GPIO contention, and unnecessary software overhead. Furthermore, camera capabilities were ambiguously tied to general nodes.

## Decision
Simplify the IoT hardware architecture to two core operational scenarios using the **ESP8266 NodeMCU**, with the **ESP32-CAM** operating as a dedicated, independent network device:

1. **Manual SOS Station (ESP8266 NodeMCU):**
   - Focus: Reliable physical emergency activation.
   - Peripherals: Physical push button (with debounce), status LED, active buzzer, and optional I2C display.
   - Network: Direct Wi-Fi to Supabase REST endpoint (`POST /rest/v1/device_events`).

2. **Automatic Incident Detection (ESP8266 NodeMCU):**
   - Focus: Early warning for environmental incidents (heat and smoke/gas).
   - Constraint: Maximum of **two physical sensors** per board (e.g. analog heat sensor and digital gas sensor) to prevent GPIO and processing bottlenecks.
   - Logic: Local threshold check with consecutive-reading filtering, then direct Wi-Fi dispatch to Supabase.

3. **Independent Camera Node (ESP32-CAM):**
   - Focus: Camera-based visual event capture.
   - Constraint: Standalone network device with its own Wi-Fi connection. Does **not** communicate through or route traffic via the ESP8266.

4. **Prototyping & Expansion Strategy:**
   - Prototyping on breadboards with basic discrete components.
   - Arduino boards are reserved only if external GPIO/ADC expansion becomes strictly necessary.
   - Modular architecture: additional ESP8266 or ESP32-CAM devices can be added simply by registering their unique `device_id` in Supabase without modifying backend logic.

## Consequences

### Positive
- **Reduced Hardware Complexity:** Fewer peripherals per board minimize wiring faults, power instability, and pin conflicts.
- **Lower Bill of Materials:** ESP8266 NodeMCU modules are cost-effective and readily available for rapid breadboard prototyping.
- **Clear Separation of Concerns:** Physical push-button emergencies, sensor thresholds, and camera feeds are decoupled.
- **Clean Backend Interface:** All devices use standard HTTPS POST requests with JSON payloads directly to Supabase.
- **Zero Mobile / Web Regressions:** The existing database schema (`devices`, `device_events`, `incidents`) and Realtime subscriptions remain 100% compatible.

### Negative / Trade-offs
- The ESP8266 possesses only one native ADC pin (`A0`), meaning only one analog sensor can be sampled directly without an external I2C ADC (e.g. ADS1115) or digital sensor interfaces.
- ESP8266 lacks Bluetooth/BLE, which is acceptable since communication is exclusively Wi-Fi/HTTPS.
