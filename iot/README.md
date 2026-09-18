# CampusSafe — IoT & Hardware Architecture

This directory contains the production firmware, wiring specifications, Wokwi simulation files, and hardware documentation for the CampusSafe IoT hardware subsystem.

---

## 1. Hardware Overview & Strategy

The system uses an **optimized dual-board architecture**:

| Board | Role | Network / Link | Primary Purpose |
|---|---|---|---|
| **NodeMCU ESP8266** (ESP-12E Module) | IoT Master Controller | Wi-Fi (HTTPS / TLS) | Push button input, MQ-2 gas sensing, DS18B20 temperature probe, local buzzer alerts, and direct Supabase incident dispatching. |
| **Arduino Uno R3** | Dedicated Display Controller | UART Serial (115200 Baud) | Drives two simultaneous 1602 LCD displays (SOS station screen + live hazard & telemetry screen). |

### Architectural Rationale:
* **Separation of Concerns:** The ESP8266 focuses on sensor data acquisition, Wi-Fi networking, SSL/TLS handshakes, and cloud communications. The Arduino Uno manages display rendering and local visual state.
* **Pin & Bandwidth Optimization:** Driving two LCD displays (one parallel, one I2C) requires high GPIO availability and dedicated timing. Offloading this to an Arduino Uno keeps the ESP8266 responsive and prevents blocking during cloud HTTP requests.
* **Safety Isolation:** Even if Wi-Fi or Internet connectivity drops, the local alarm subsystem (piezo buzzer and dual LCD screens) continues operating seamlessly.

---

## 2. System Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                   ESP8266 NodeMCU (Master Controller)                   │
│                                                                         │
│   [Push Button]   ──→ Pin D3 (GPIO 0)  ──→ Debounce ──→ SOS Trigger     │
│   [MQ-2 Gas]      ──→ Pin A0 (ADC 0)   ──→ Analog Voltage (0-1023)      │
│   [DS18B20 Temp]  ──→ Pin D7 (GPIO 13) ──→ Dallas 1-Wire Bus (2.2kΩ PU) │
│   [Piezo Buzzer]  ←── Pin D5 (GPIO 14) ←── High/Low Audio Alarm         │
│   [Status LED]    ←── Built-in LED     ←── Heartbeat / Strobe Alarm     │
│                                                                         │
│   ──→ Wi-Fi HTTPS POST ──────────────────→ Supabase Cloud Incidents API│
│   ──→ Serial TX (GPIO 1) 115200 Baud ─────→ Arduino Uno RX (Pin 0)      │
└─────────────────────────────────────────────────────────────────────────┘
                                                       │
                                                       │ UART Link (115200)
                                                       ▼
                             ┌────────────────────────────────────────────┐
                             │       Arduino Uno R3 (Display Controller)   │
                             │                                            │
                             │   [LCD 1 - Parallel 1602] (Pins 7-12)      │
                             │     Line 0: "SOS System Ready"             │
                             │     Line 1: "Press button..."              │
                             │                                            │
                             │   [LCD 2 - I2C 1602 Backpack] (A4/A5)      │
                             │     Line 0: Live Telemetry "T:25.0C G:650" │
                             │     Line 1: Live Status    "Status: Normal"│
                             └────────────────────────────────────────────┘
```

---

## 3. Directory Structure

```text
campussafe/iot/
├── main-controller/
│   └── main-controller.ino      # ESP8266 Master Firmware (Button, Sensors, Supabase, Buzzer, TX)
├── display-controller/
│   └── display-controller.ino   # Arduino Uno R3 Display Firmware (Parallel LCD 1 + I2C LCD 2)
├── simulation/                  # Wokwi simulation workspace & test firmware
│   ├── diagram.json             # Wokwi wiring & component layout
│   ├── platformio.ini           # PlatformIO project configuration
│   ├── libraries.txt            # Wokwi dependency list
│   ├── wokwi.toml               # Wokwi simulator entry point
│   └── src/                     # Source modules & diagnostic firmware
│       ├── main_esp8266.cpp     # ESP8266 master source
│       ├── main_uno.cpp         # Arduino Uno master source
│       ├── diagnostics.cpp      # Live hardware pin diagnostics
│       ├── i2c_scanner.cpp      # I2C bus scanner
│       └── temp_debug.cpp       # Dallas 1-Wire scanner
└── README.md                    # This hardware documentation
```

---

## 4. Hardware Pin Mapping & Wiring Specification

### 4.1. ESP8266 NodeMCU (Master Controller)

| Component | Component Pin | ESP8266 Pin | Notes / Wiring |
|---|---|---|---|
| **SOS Push Button** | Pin 1 (Diagonal)<br>Pin 2 (Diagonal) | **`D3`** (`GPIO 0`)<br>**`GND`** | Configured with `INPUT_PULLUP`. Pressing ties `D3` to GND. |
| **MQ-2 Gas / Smoke Sensor** | `VCC`<br>`GND`<br>`AO` (Analog Out)<br>`DO` (Digital Out) | **`5V`** rail (from Arduino)<br>**`GND`** rail<br>**`A0`** (`ADC 0`)<br>*Unconnected* | Sensor heater requires 5V. Reads raw ADC (0–1023). Alarm threshold set to **`800`** to prevent warm-up false alarms. |
| **DS18B20 Temp Probe** | Red Wire (`VCC`)<br>Black Wire (`GND`)<br>Yellow Wire (`DATA`) | **`3V`** (3.3V)<br>**`GND`** rail<br>**`D7`** (`GPIO 13`) | **Crucial:** Red wire connects to 3.3V (NOT 5V). Requires a **2.2kΩ pull-up resistor** bridging Red (`3V`) and Yellow (`D7`). Heat threshold set to **`40.0°C`**. |
| **Piezo Buzzer** | Red Wire (`+`)<br>Black Wire (`-`) | **`D5`** (`GPIO 14`)<br>**`GND`** rail | 2000Hz chirp for SOS; 1000Hz continuous pulsing alarm for hazards. |
| **Serial Link to Arduino** | `TX` (Transmitter)<br>`G` (Ground) | **`TX`** (`GPIO 1`)<br>**`GND`** | Connects to Arduino Uno Pin 0 (`RX`). Common ground with Arduino. |

---

### 4.2. Arduino Uno R3 (Display Controller)

#### Screen 1: Parallel 1602 LCD (SOS Station Display)
* **Pin 1 (`VSS`)**: Breadboard `GND`
* **Pin 2 (`VDD`)**: Breadboard `5V`
* **Pin 3 (`V0`)**: Contrast — connected to `GND` through two 2.2kΩ resistors in series (4.4kΩ)
* **Pin 4 (`RS`)**: Arduino **Pin 7**
* **Pin 5 (`RW`)**: Breadboard `GND` (write mode)
* **Pin 6 (`E`)**: Arduino **Pin 8**
* **Pins 7–10 (`D0–D3`)**: *Unconnected (4-bit mode)*
* **Pin 11 (`D4`)**: Arduino **Pin 9**
* **Pin 12 (`D5`)**: Arduino **Pin 10**
* **Pin 13 (`D6`)**: Arduino **Pin 11**
* **Pin 14 (`D7`)**: Arduino **Pin 12**
* **Pin 15 (`A`)**: Breadboard `5V` (Backlight Anode)
* **Pin 16 (`K`)**: Breadboard `GND` (Backlight Cathode)

#### Screen 2: 4-Pin I2C 1602 LCD (Hazard & Telemetry Display)
* **`GND`**: Breadboard `GND`
* **`VCC`**: Breadboard `5V`
* **`SDA`**: Arduino **Pin `A4`** (Hardware I2C Data)
* **`SCL`**: Arduino **Pin `A5`** (Hardware I2C Clock)
* *(Contrast is adjusted using the blue potentiometer screw on the backpack)*

---

## 5. Serial Communication Protocol (UART)

The ESP8266 transmits state changes and telemetry to the Arduino Uno at **115200 baud**.

| Message Prefix | Payload / Format | Trigger Condition | Display Action on Arduino |
|---|---|---|---|
| **`SOS:1`** | None | Hardware push button pressed | **LCD 1:** Shows `"Sending SOS / signal..."` |
| **`SOS:0`** | None | Button released / 2.5s timeout | **LCD 1:** Returns to `"SOS System Ready / Press button..."` |
| **`HAZARD:GAS`** | None | Gas reading $\ge$ 800 | **LCD 2:** Line 1 shows `"Gas! Evacuate!"` |
| **`HAZARD:HEAT`** | None | Temperature $\ge$ 40.0°C | **LCD 2:** Line 1 shows `"Heat! Evacuate!"` |
| **`HAZARD:BOTH`** | None | Both Gas $\ge$ 800 & Temp $\ge$ 40°C | **LCD 2:** Line 1 shows `"Gas&Heat! Flee!"` |
| **`HAZARD:NORMAL`**| None | Readings below thresholds | **LCD 2:** Line 1 shows `"Status: Normal"` |
| **`DATA:`** | `<temp_c>,<gas_raw>` (e.g. `DATA:25.0,653`) | Sent every 1 second | **LCD 2:** Line 0 updates live: `"T:25.0C G:653"` |

> **Important Programming Note:** Always unplug the wire from Arduino Pin 0 (`RX`) before uploading code to the Arduino Uno via USB, as the serial connection from the ESP8266 interferes with the bootloader.

---

## 6. Sensor Calibration & ADC Units

### MQ-2 Gas / Smoke Sensor:
* The gas reading is a **dimensionless 10-bit ADC count (0–1023)** corresponding to a 0–3.3V input range ($3.22\text{ mV per count}$).
* **Normal Clean Air Baseline:** ~15–150 counts.
* **Warm-up Phase:** When cold, the sensor heater draws current and creates an initial reading of 600–750 counts before settling down.
* **Threshold (`800`):** Prevents false alarms during cold boots while reliably detecting direct smoke, lighter butane, alcohol, or combustible gas.

### DS18B20 Temperature Probe:
* Digital temperature measured directly in **Degrees Celsius (°C)** over Dallas 1-Wire protocol.
* **Threshold (`40.0°C`):** Distinguishes environmental ambient room heat from emergency heat/fire conditions.

---

## 7. Cloud Integration (Supabase REST API)

When an emergency occurs, the ESP8266 connects via Wi-Fi and sends an **HTTPS POST** directly to the Supabase incidents table:

* **Endpoint:** `https://<PROJECT_ID>.supabase.co/rest/v1/incidents`
* **Headers:**
  * `apikey: <SUPABASE_SERVICE_OR_ANON_KEY>`
  * `Authorization: Bearer <SUPABASE_SERVICE_OR_ANON_KEY>`
  * `Content-Type: application/json`

### Payload Example: SOS Button Press
```json
{
  "type": "security",
  "priority": 1,
  "source": "iot",
  "latitude": 8.5582,
  "longitude": 39.2895,
  "campus_block": "Engineering Block",
  "location_description": "Hardware Station STATION-ENG-01",
  "description": "EMERGENCY SOS triggered from Hardware Station STATION-ENG-01",
  "status": "created"
}
```

### Payload Example: Hazardous Gas Detection
```json
{
  "type": "environmental",
  "priority": 1,
  "source": "iot",
  "latitude": 8.5582,
  "longitude": 39.2895,
  "campus_block": "Engineering Block",
  "location_description": "Hardware Station STATION-ENG-01",
  "description": "HAZARDOUS GAS LEAK detected by Station STATION-ENG-01",
  "status": "created"
}
```

> **Single-Transmission Guarantee:** The firmware enforces a state transition lock (`NORMAL` $\rightarrow$ `HAZARD`). An incident is dispatched **exactly once** when a hazard begins, preventing notification spam.
