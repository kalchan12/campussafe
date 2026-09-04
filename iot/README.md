# CampusSafe — IoT & Hardware Architecture

This directory contains the firmware, wiring guides, and hardware documentation for the CampusSafe IoT layer.

---

## 1. Hardware Strategy

The hardware layer is streamlined into a minimal, reliable, and modular architecture:

- **Primary Controller:** ESP8266 NodeMCU (v2/v3, CP2102/CH340).
- **Prototyping Environment:** Breadboards, jumper wires, pull-up/pull-down resistors, and basic discrete electronics.
- **Sensor Limit:** Up to **two physical sensors** connected to an ESP8266 board to prevent GPIO contention and hardware complexity.
- **Independent Camera:** **ESP32-CAM** operates as an independent IoT device with its own dedicated Wi-Fi connection, communicating directly with the backend.
- **Auxiliary I/O:** Arduino boards (Uno/Nano) are used only if GPIO or ADC channel limits strictly require them.
- **Feedback:** Local LED indicators and active buzzer for immediate acknowledgement.
- **Optional Display:** 0.96" SSD1306 OLED or 1602 LCD via I2C (SDA/SCL) where visual status is desired.

---

## 2. Hardware Scenarios

```text
┌───────────────────────────┐      ┌───────────────────────────┐      ┌───────────────────────────┐
│     Manual SOS Station    │      │   Automatic Sensor Node   │      │         ESP32-CAM         │
│     (ESP8266 NodeMCU)     │      │     (ESP8266 NodeMCU)     │      │   (Independent Device)    │
│                           │      │                           │      │                           │
│  [Push Button] ─→ Debounce│      │  [Sensor 1: Heat/Temp]    │      │  [OV2640 Camera Sensor]   │
│  [LED] ─→ Visual Feedback │      │  [Sensor 2: Gas/Smoke]    │      │  [Onboard Flash LED]      │
│  [Buzzer] ─→ Audio Alert  │      │  [Threshold Check Engine] │      │  [Event Detection Logic]  │
│  [Optional I2C Display]   │      │                           │      │                           │
└─────────────┬─────────────┘      └─────────────┬─────────────┘      └─────────────┬─────────────┘
              │ Wi-Fi                            │ Wi-Fi                            │ Wi-Fi
              │ (HTTPS POST)                     │ (HTTPS POST)                     │ (HTTPS POST)
              ▼                                  ▼                                  ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                       SUPABASE BACKEND                                          │
│                         (REST API: /rest/v1/device_events & Realtime)                           │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Scenario 1: Manual SOS Station (`iot/sos-station/`)
- **Controller:** ESP8266 NodeMCU
- **Components:**
  - Physical momentary push button (industrial or arcade-style button with 10kΩ pull-up/pull-down resistor or internal pull-up)
  - Status LED (Green = Wi-Fi Connected, Red = SOS Triggered)
  - Active Buzzer (audible trigger confirmation)
  - Optional I2C OLED display (showing connection status and SOS confirmation)
- **Workflow:**
  1. User presses physical SOS button.
  2. Software debounce confirms deliberate press (e.g. holding for 500ms–1s).
  3. ESP8266 triggers local buzzer and red LED.
  4. ESP8266 issues an HTTPS POST request over campus Wi-Fi directly to Supabase.
  5. Backend generates a critical `incident` and logs a `device_event` (`SOS_TRIGGERED`).
  6. Responders and Operators receive instant updates via Supabase Realtime and FCM push notifications.

### Scenario 2: Automatic Incident Detection (`iot/sensor-node/`)
- **Controller:** ESP8266 NodeMCU
- **Sensors:** Up to **two physical sensors**:
  - **Sensor 1 (Heat/Temperature):** Analog/digital heat detection (e.g., thermistor, LM35, or DHT sensor).
  - **Sensor 2 (Gas/Smoke):** Gas/smoke sensor (e.g., MQ-2 or MQ-135).
- **Workflow:**
  1. ESP8266 periodically samples connected sensors (every 2–5 seconds).
  2. Onboard threshold logic checks if readings exceed critical safety levels.
  3. If threshold is breached for consecutive samples (filtering transient noise), an automatic incident event is triggered.
  4. Local buzzer/LED alert warns people in immediate proximity.
  5. HTTPS POST is sent to Supabase with sensor readings in JSON payload.
  6. Backend creates an emergency incident (`type: fire` or `hazard`) and alerts operators.

### Independent Camera Node (`iot/esp32-cam/`)
- **Controller:** ESP32-CAM module (with OV2640 camera).
- **Network:** Independent Wi-Fi connection.
- **Workflow:**
  - Operates as a standalone camera event node.
  - Does **not** route traffic through the ESP8266.
  - Can stream snapshots or trigger security events directly to the Supabase Storage / backend REST endpoint.

---

## 3. Recommended Pinout Guidelines (ESP8266 NodeMCU)

The ESP8266 has limited GPIOs, with several having special boot state requirements (GPIO 0, 2, 15):

| Function | NodeMCU Pin | ESP8266 GPIO | Electrical Notes |
|---|---|---|---|
| **SOS Push Button** | `D5` | `GPIO 14` | Configured with `INPUT_PULLUP` or external 10kΩ resistor. Safe boot pin. |
| **Status LED (Red/Green)** | `D6`, `D7` | `GPIO 12`, `GPIO 13` | Output through 220Ω–330Ω current limiting resistor. Safe boot pins. |
| **Active Buzzer** | `D8` | `GPIO 15` | Must be pulled LOW at boot; drive with NPN transistor (2N2222) if buzzer draws >12mA. |
| **Sensor 1 (Heat/Analog)**| `A0` | `ADC 0` | Dedicated 0–1.0V (0–3.3V on NodeMCU boards with internal divider). |
| **Sensor 2 (Gas/Digital)**| `D2` | `GPIO 4` | Digital threshold input from comparator module or 1-Wire digital sensor. |
| **Optional I2C Display**  | `D1` (SCL), `D2` (SDA) | `GPIO 5`, `GPIO 4` | Standard I2C bus with 4.7kΩ pull-ups. |

---

## 4. Network & Backend Data Protocol

### HTTP Endpoint
All devices communicate with the Supabase PostgREST endpoint:
- **URL:** `https://<SUPABASE_PROJECT_ID>.supabase.co/rest/v1/device_events`
- **Method:** `POST`
- **Headers:**
  - `apikey: <SUPABASE_ANON_OR_DEVICE_KEY>`
  - `Authorization: Bearer <SUPABASE_ANON_OR_DEVICE_KEY>`
  - `Content-Type: application/json`
  - `Prefer: return=representation`

### Payload Schema: Manual SOS
```json
{
  "device_id": "SOS-ENG-01",
  "event_type": "SOS_TRIGGERED",
  "location_id": "engineering-block",
  "payload": {
    "source": "physical_push_button",
    "battery_level": 100,
    "uptime_seconds": 3600
  }
}
```

### Payload Schema: Automatic Sensor Incident
```json
{
  "device_id": "SENSOR-LIB-01",
  "event_type": "SMOKE_DETECTED",
  "location_id": "library-block",
  "payload": {
    "sensor_type": "MQ-2",
    "reading": 620,
    "threshold": 450,
    "unit": "ppm"
  }
}
```

### Payload Schema: Heartbeat Telemetry
```json
{
  "device_id": "SOS-ENG-01",
  "event_type": "HEARTBEAT",
  "payload": {
    "rssi": -65,
    "firmware": "1.0.0",
    "uptime_seconds": 86400
  }
}
```

---

## 5. Modularity & Scalability

1. **Independent Nodes:** Adding a new SOS station or sensor node only requires assigning a unique `device_id` (e.g. `SOS-ADMIN-02`, `SENSOR-DORM-01`) and registering it in the `devices` table.
2. **Decoupled Backend:** The backend treats all incoming HTTP events neutrally based on `device_type` and `event_type`.
3. **No Mesh Overhead:** Direct Wi-Fi station mode simplifies firmware, eliminating complex mesh routing protocols.
4. **Independent Camera Nodes:** ESP32-CAM units can be deployed, upgraded, or removed without impacting the ESP8266 stations.
