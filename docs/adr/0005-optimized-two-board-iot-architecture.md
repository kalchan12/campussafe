# ADR 0005: Optimized Two-Board IoT Architecture (ESP8266 + Arduino Uno R3)

## Status
Accepted (supersedes ADR 0004 IoT board allocation)

## Date
2026-09-10

## Context
ADR 0004 established a simplified IoT architecture using two separate ESP8266 NodeMCU boards — one dedicated to a manual SOS push button station and another dedicated to an automatic sensor node (heat/gas). Each board communicated independently with Supabase over Wi-Fi.

During prototyping and Wokwi simulation, several practical issues were identified:

1. **GPIO efficiency:** The push button (1 digital pin) and two sensors (1 analog pin + 1 digital pin) together consume very few GPIOs. Using a dedicated ESP8266 for just a push button wastes most of its I/O capacity.
2. **Display requirements:** The design calls for two LCD displays — one showing SOS status and another showing sensor readings. Driving two LCDs requires more GPIO pins (or I2C addresses) than a single ESP8266 can comfortably provide alongside its sensing duties.
3. **Cost:** Using two ESP8266 boards when one can handle all sensing is an unnecessary hardware expense.
4. **Wokwi validation:** The optimized design has been validated in a Wokwi VS Code extension simulation.

## Decision
Consolidate the IoT hardware into a **two-board architecture** with clear separation of concerns:

### 1. Main Controller — ESP8266 NodeMCU Amica v2
- **Role:** All sensing, event detection, and backend communication.
- **Peripherals:**
  - Physical SOS push button (with hardware/software debounce).
  - MQ-2 gas/smoke sensor (analog, A0).
  - DHT11 temperature sensor (digital).
  - Status LED and buzzer (local feedback).
- **Communication:**
  - Wi-Fi → HTTPS POST → Supabase REST API (event reporting).
  - Serial (UART TX) → Arduino Uno R3 (display commands).
- **Events:** `SOS_TRIGGERED`, `SMOKE_DETECTED`, `HIGH_TEMP`, `HEARTBEAT`.

### 2. Display Controller — Arduino Uno R3
- **Role:** Local display output only. No network connectivity.
- **Peripherals:**
  - LCD 1 (I2C): SOS push button status display.
  - LCD 2 (I2C): Sensor readings display (gas ppm, temperature °C).
  - Status LEDs for visual feedback.
- **Communication:**
  - Serial (UART RX) ← ESP8266 (receives structured text commands).
- **Protocol:** Simple newline-delimited text commands:
  - `SOS:TRIGGERED:<timestamp>`
  - `SENSOR:GAS:<reading>:ppm`
  - `SENSOR:TEMP:<reading>:C`
  - `STATUS:READY`
  - `ALERT:GAS` / `ALERT:TEMP`

### 3. Independent Camera Node — ESP32-CAM (unchanged)
- Operates independently with its own Wi-Fi connection.
- No changes from ADR 0004.

## Consequences

### Positive
- **Reduced board count:** One fewer ESP8266 required (2 ESP8266 → 1 ESP8266 + 1 Arduino).
- **Better GPIO utilization:** The ESP8266's limited GPIOs are used efficiently for sensing + communication, while the Arduino's abundant digital pins handle display driving.
- **Clearer separation of concerns:** ESP8266 = intelligent controller (sensing + Wi-Fi); Arduino = dumb display terminal.
- **Lower cost:** Arduino Uno R3 is less expensive than an ESP8266 when Wi-Fi is not needed.
- **Zero backend impact:** The Supabase REST API, `device_events` table, `devices` table, and Realtime subscriptions require no changes. Events arrive in the same JSON format.
- **Validated design:** The architecture has been tested in Wokwi simulation.

### Negative / Trade-offs
- **Inter-board wiring:** Requires a Serial (UART) connection between ESP8266 TX and Arduino RX, plus common GND.
- **Arduino has no network access:** If the Arduino needs to report its own status, it cannot. This is acceptable because the Arduino is purely a display peripheral.
- **Single point of failure:** If the ESP8266 fails, both sensing and display stop. Previously, the sensor node would still function independently. This trade-off is acceptable for a prototype.

## Migration
- Remove `iot/sos-station/` directory (consolidated into `iot/main-controller/`).
- Remove `iot/sensor-node/` directory (consolidated into `iot/main-controller/`).
- Create `iot/main-controller/` with ESP8266 Amica v2 firmware.
- Create `iot/display-controller/` with Arduino Uno R3 firmware.
- Update all documentation: ARCHITECTURE.md, PROJECT.md, PLAN.md, README.md, AGENTS.md, iot/README.md.
