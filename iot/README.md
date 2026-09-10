# CampusSafe — IoT & Hardware Architecture

This directory contains the firmware, wiring guides, and hardware documentation for the CampusSafe IoT layer.

---

## 1. Hardware Strategy

The IoT layer uses an **optimized two-board architecture**:

| Board | Role | Network |
|---|---|---|
| **ESP8266 NodeMCU Amica v2** | Main Controller — push button + sensors + Supabase | Wi-Fi (HTTPS) |
| **Arduino Uno R3** | Display Controller — 2× LCD displays + status LEDs | None (Serial RX only) |
| **ESP32-CAM** | Independent camera event node (future) | Wi-Fi (HTTPS) |

**Rationale:** The push button and two sensors (MQ-2 analog + DHT11 digital) consume very few GPIO pins, so one ESP8266 handles all sensing. Driving two LCD displays requires more GPIO/I2C bandwidth than the ESP8266 can comfortably provide alongside its sensing and Wi-Fi duties, so an Arduino Uno R3 serves as a dedicated display controller. This eliminates one ESP8266 from the design while maintaining clear separation of concerns.

**Prototyping:** Breadboards, resistors, LEDs, and basic discrete electronics. The design has been validated in the **Wokwi VS Code extension** simulator.

---

## 2. System Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│              ESP8266 Amica v2 (Main Controller)             │
│                                                             │
│   [Push Button] ──→ Debounce ──→ SOS_TRIGGERED event        │
│   [MQ-2 Gas]    ──→ Read     ──→ Threshold check            │
│   [DHT11 Temp]  ──→ Read     ──→ Threshold check            │
│   [Status LED]  ←── Visual Feedback                         │
│   [Buzzer]      ←── Audio Feedback                          │
│                                                             │
│   ──→ Wi-Fi HTTPS POST → Supabase REST API                  │
│   ──→ Serial TX → Arduino RX (display commands)             │
└──────────────┬──────────────────────────┬───────────────────┘
               │ Wi-Fi                    │ Serial (UART)
               ▼                          ▼
    ┌───────────────────┐      ┌────────────────────────────┐
    │  SUPABASE BACKEND │      │    Arduino Uno R3          │
    │  (REST API +      │      │    (Display Controller)    │
    │   Realtime)       │      │                            │
    └───────────────────┘      │  [LCD 1] ← SOS Status     │
                               │  [LCD 2] ← Sensor Data    │
                               │  [LEDs]  ← Status         │
                               └────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              ESP32-CAM (Independent Device — Future)        │
│   [Camera] ──→ Capture ──→ Wi-Fi ──→ HTTPS ──→ Supabase    │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Directory Structure

```text
iot/
├── main-controller/           # ESP8266 Amica v2 firmware
│   └── main-controller.ino
├── display-controller/        # Arduino Uno R3 firmware
│   └── display-controller.ino
├── esp32-cam/                 # ESP32-CAM firmware (future)
│   └── .gitkeep
└── README.md                  # This file
```

---

## 4. ESP8266 Amica v2 — Pinout

| Function | NodeMCU Pin | ESP8266 GPIO | Notes |
|---|---|---|---|
| **SOS Push Button** | `D5` | `GPIO 14` | `INPUT_PULLUP`, safe boot pin |
| **MQ-2 Gas Sensor** | `A0` | `ADC 0` | Analog 0–3.3V (NodeMCU internal divider) |
| **DHT11 Temperature** | `D2` | `GPIO 4` | Digital, 1-Wire protocol |
| **Status LED** | `D6` | `GPIO 12` | Output, 220Ω–330Ω resistor |
| **Active Buzzer** | `D8` | `GPIO 15` | Must be LOW at boot; use NPN transistor if >12mA |
| **Serial TX → Arduino** | `TX` | `GPIO 1` | 9600 baud, connect to Arduino RX |

---

## 5. Arduino Uno R3 — Pinout

| Function | Arduino Pin | Notes |
|---|---|---|
| **Serial RX ← ESP8266** | `Pin 0 (RX)` | 9600 baud, connect to ESP8266 TX |
| **I2C SDA** | `A4` | Shared I2C bus for both LCDs |
| **I2C SCL** | `A5` | Shared I2C bus for both LCDs |
| **LCD 1 (SOS Status)** | I2C `0x27` | 16×2 character LCD |
| **LCD 2 (Sensor Data)** | I2C `0x26` | 16×2 character LCD (address adjusted) |
| **SOS Status LED** | `Pin 8` | Red LED, 220Ω resistor |
| **Sensor Alert LED** | `Pin 9` | Yellow LED, 220Ω resistor |
| **Ready LED** | `Pin 10` | Green LED, 220Ω resistor |

> **Note:** I2C addresses vary by LCD module. Use an I2C scanner sketch to determine your actual addresses and update the firmware constants accordingly.

---

## 6. Serial Communication Protocol

The ESP8266 sends structured text commands to the Arduino via Serial (UART) at **9600 baud**. Each command is a newline-terminated string.

| Command | Format | Action |
|---|---|---|
| SOS Triggered | `SOS:TRIGGERED:<timestamp>\n` | Arduino updates LCD 1 with SOS alert |
| Gas Reading | `SENSOR:GAS:<reading>:ppm\n` | Arduino updates LCD 2 gas value |
| Temp Reading | `SENSOR:TEMP:<reading>:C\n` | Arduino updates LCD 2 temperature |
| System Ready | `STATUS:READY\n` | Arduino resets LCD 1 to ready state |
| System Booting | `STATUS:BOOTING\n` | Arduino shows booting message |
| Gas Alert | `ALERT:GAS\n` | Arduino flashes LCD 2, shows gas alert |
| Temp Alert | `ALERT:TEMP\n` | Arduino flashes LCD 2, shows heat alert |

### Example Serial Stream

```text
STATUS:BOOTING
STATUS:READY
SENSOR:GAS:120:ppm
SENSOR:TEMP:28:C
SENSOR:GAS:135:ppm
SENSOR:TEMP:29:C
SOS:TRIGGERED:3600
SENSOR:GAS:480:ppm
ALERT:GAS
SENSOR:TEMP:47:C
ALERT:TEMP
```

---

## 7. Wiring Guide

### ESP8266 ↔ Arduino Connection

```text
ESP8266 TX (GPIO 1) ──────→ Arduino RX (Pin 0)
ESP8266 GND ───────────────→ Arduino GND
```

> **Important:** Connect GND between both boards. Do NOT connect VCC between boards — each should be powered independently via USB.

### ESP8266 Components

```text
Push Button:  One leg → D5 (GPIO 14), other leg → GND
              (using INPUT_PULLUP, no external resistor needed)

MQ-2 Sensor:  VCC → 3.3V, GND → GND, AOUT → A0

DHT11:        VCC → 3.3V, GND → GND, DATA → D2 (GPIO 4)
              (10kΩ pull-up between VCC and DATA recommended)

Status LED:   Anode → D6 (GPIO 12) via 220Ω resistor, Cathode → GND

Buzzer:       Positive → D8 (GPIO 15) via NPN transistor, Negative → GND
```

### Arduino Components

```text
LCD 1 (I2C):  VCC → 5V, GND → GND, SDA → A4, SCL → A5
LCD 2 (I2C):  VCC → 5V, GND → GND, SDA → A4, SCL → A5

SOS LED:      Anode → Pin 8 via 220Ω resistor, Cathode → GND
Sensor LED:   Anode → Pin 9 via 220Ω resistor, Cathode → GND
Ready LED:    Anode → Pin 10 via 220Ω resistor, Cathode → GND
```

---

## 8. Supabase Backend Protocol

### HTTP Endpoint

All events are sent as HTTPS POST requests to Supabase:

- **URL:** `https://<PROJECT_ID>.supabase.co/rest/v1/device_events`
- **Method:** `POST`
- **Headers:**
  - `apikey: <SUPABASE_ANON_OR_DEVICE_KEY>`
  - `Authorization: Bearer <SUPABASE_ANON_OR_DEVICE_KEY>`
  - `Content-Type: application/json`
  - `Prefer: return=representation`

### Payload: SOS Triggered

```json
{
  "device_id": "STATION-ENG-01",
  "event_type": "SOS_TRIGGERED",
  "location_id": "engineering-block",
  "payload": {
    "source": "physical_push_button",
    "uptime_seconds": 3600
  }
}
```

### Payload: Sensor Alert

```json
{
  "device_id": "STATION-ENG-01",
  "event_type": "SMOKE_DETECTED",
  "location_id": "engineering-block",
  "payload": {
    "sensor": "MQ-2",
    "reading": 620,
    "threshold": 400,
    "unit": "ppm"
  }
}
```

### Payload: Heartbeat

```json
{
  "device_id": "STATION-ENG-01",
  "event_type": "HEARTBEAT",
  "payload": {
    "rssi": -65,
    "firmware": "1.0.0",
    "uptime_seconds": 86400
  }
}
```

---

## 9. Setup Instructions

### Prerequisites

- [Arduino IDE](https://www.arduino.cc/en/software) 2.x or later
- ESP8266 board package installed via Board Manager
  - URL: `http://arduino.esp8266.com/stable/package_esp8266com_index.json`
- Arduino Uno R3 board (built-in support)

### Required Libraries

| Library | Board | Install via |
|---|---|---|
| `ESP8266WiFi` | ESP8266 | Included with board package |
| `ESP8266HTTPClient` | ESP8266 | Included with board package |
| `ArduinoJson` | ESP8266 | Library Manager |
| `DHT sensor library` | ESP8266 | Library Manager (Adafruit) |
| `LiquidCrystal_I2C` | Arduino | Library Manager |
| `Wire` | Arduino | Built-in |

### Flashing

1. **ESP8266 (Main Controller):**
   - Board: `NodeMCU 1.0 (ESP-12E Module)`
   - Upload Speed: `115200`
   - Open `iot/main-controller/main-controller.ino`
   - Update WiFi and Supabase credentials
   - Upload

2. **Arduino Uno R3 (Display Controller):**
   - Board: `Arduino Uno`
   - Open `iot/display-controller/display-controller.ino`
   - Verify LCD I2C addresses match your hardware
   - Upload

> **Note:** Disconnect the Arduino RX wire from the ESP8266 TX pin before uploading to the Arduino, as the serial connection can interfere with USB programming.

---

## 10. Wokwi Simulation

The optimized two-board architecture has been validated using the **Wokwi VS Code extension**. The simulation verifies:

- Push button debounce and SOS event generation
- MQ-2 gas sensor analog reading and threshold detection
- DHT11 temperature reading and threshold detection
- Serial communication protocol between ESP8266 and Arduino
- LCD display updates for both SOS status and sensor data
- LED and buzzer feedback behavior

To run the simulation, use the Wokwi extension in VS Code with the project's simulation configuration.

---

## 11. Modularity & Scalability

1. **Independent Stations:** Adding a new station requires assigning a unique `device_id` (e.g. `STATION-ADMIN-02`) and registering it in the `devices` table.
2. **Decoupled Backend:** The backend treats all incoming events neutrally based on `device_type` and `event_type`.
3. **No Mesh Overhead:** Direct Wi-Fi station mode simplifies firmware.
4. **Independent Camera Nodes:** ESP32-CAM units can be deployed independently.
5. **Display Controller is Local:** The Arduino display controller does not affect the backend contract — it is a local peripheral only.
