/*
 * CampusSafe — Main Controller Firmware
 * Board: ESP8266 NodeMCU Amica v2
 *
 * Responsibilities:
 *   - Detect physical SOS push button press (with debounce)
 *   - Read MQ-2 gas sensor (analog)
 *   - Read DHT11 temperature sensor (digital)
 *   - Evaluate sensor thresholds for automatic incident detection
 *   - Send event payloads to Supabase via HTTPS POST over Wi-Fi
 *   - Send display commands to Arduino Uno R3 via Serial (UART)
 *   - Provide local LED/buzzer feedback
 *   - Send periodic heartbeat telemetry
 *
 * Serial Protocol (ESP8266 TX → Arduino RX, 9600 baud):
 *   SOS:TRIGGERED:<timestamp>\n
 *   SENSOR:GAS:<reading>:ppm\n
 *   SENSOR:TEMP:<reading>:C\n
 *   STATUS:READY\n
 *   ALERT:GAS\n
 *   ALERT:TEMP\n
 *
 * Wokwi simulation validated.
 */

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ============================================================
// CONFIGURATION — TODO: Replace with actual credentials
// ============================================================

// Wi-Fi
const char* WIFI_SSID     = "CAMPUS_WIFI";       // TODO: Replace
const char* WIFI_PASSWORD  = "campus_password";    // TODO: Replace

// Supabase
const char* SUPABASE_URL   = "https://your-project.supabase.co";  // TODO: Replace
const char* SUPABASE_KEY   = "your-anon-key";                      // TODO: Replace
const char* DEVICE_EVENTS_ENDPOINT = "/rest/v1/device_events";

// Device Identity
const char* DEVICE_ID      = "STATION-ENG-01";
const char* LOCATION_ID    = "engineering-block";
const char* FIRMWARE_VER   = "1.0.0";

// ============================================================
// PIN DEFINITIONS (ESP8266 NodeMCU Amica v2)
// ============================================================

#define BUTTON_PIN      D5    // GPIO 14 — SOS push button (INPUT_PULLUP)
#define GAS_SENSOR_PIN  A0    // ADC 0   — MQ-2 gas sensor (analog)
#define DHT_PIN         D2    // GPIO 4  — DHT11 temperature sensor
#define LED_PIN         D6    // GPIO 12 — Status LED (green/red)
#define BUZZER_PIN      D8    // GPIO 15 — Active buzzer

// ============================================================
// SENSOR CONFIGURATION
// ============================================================

#define DHT_TYPE        DHT11
#define GAS_THRESHOLD   400     // Analog reading threshold for gas alert
#define TEMP_THRESHOLD  45.0    // Temperature threshold (°C) for heat alert

// ============================================================
// TIMING CONFIGURATION
// ============================================================

#define HEARTBEAT_INTERVAL    60000   // 60 seconds
#define SENSOR_READ_INTERVAL  3000    // 3 seconds
#define DEBOUNCE_DELAY        50      // 50 ms debounce
#define ALARM_DURATION        3000    // 3 seconds buzzer/LED on SOS
#define WIFI_RETRY_DELAY      500     // 500 ms between WiFi retries
#define WIFI_MAX_RETRIES      40      // 20 seconds max WiFi wait

// ============================================================
// GLOBAL STATE
// ============================================================

DHT dht(DHT_PIN, DHT_TYPE);

unsigned long lastHeartbeat    = 0;
unsigned long lastSensorRead   = 0;
unsigned long alarmStartTime   = 0;
bool          alarmActive      = false;

// Debounce state
int           lastButtonState  = HIGH;
int           buttonState      = HIGH;
unsigned long lastDebounceTime = 0;

// Consecutive breach counter (noise filtering)
int gasBreachCount  = 0;
int tempBreachCount = 0;
#define BREACH_CONFIRM_COUNT 3  // Require 3 consecutive readings

// ============================================================
// SETUP
// ============================================================

void setup() {
  // Serial for Arduino display communication
  Serial.begin(9600);
  Serial.println("STATUS:BOOTING");

  // Pin modes
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  // Ensure buzzer/LED off at boot
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  // Initialize DHT sensor
  dht.begin();

  // Connect to Wi-Fi
  connectWiFi();

  // Signal ready
  sendToArduino("STATUS:READY");
  Serial.println("[Main] Setup complete. Ready.");
}

// ============================================================
// MAIN LOOP
// ============================================================

void loop() {
  unsigned long now = millis();

  // --- 1. Push Button (SOS) ---
  handleButton(now);

  // --- 2. Alarm auto-off ---
  if (alarmActive && (now - alarmStartTime >= ALARM_DURATION)) {
    deactivateAlarm();
  }

  // --- 3. Sensor readings ---
  if (now - lastSensorRead >= SENSOR_READ_INTERVAL) {
    lastSensorRead = now;
    handleSensors(now);
  }

  // --- 4. Heartbeat ---
  if (now - lastHeartbeat >= HEARTBEAT_INTERVAL) {
    lastHeartbeat = now;
    sendHeartbeat();
  }
}

// ============================================================
// PUSH BUTTON HANDLER
// ============================================================

void handleButton(unsigned long now) {
  int reading = digitalRead(BUTTON_PIN);

  // Reset debounce timer on state change
  if (reading != lastButtonState) {
    lastDebounceTime = now;
  }

  // Debounce confirmed
  if ((now - lastDebounceTime) > DEBOUNCE_DELAY) {
    if (reading != buttonState) {
      buttonState = reading;

      // Button pressed (active LOW with pull-up)
      if (buttonState == LOW) {
        Serial.println("[Main] SOS button pressed!");

        // Local feedback
        activateAlarm();

        // Send SOS to Supabase
        StaticJsonDocument<256> payload;
        payload["source"] = "physical_push_button";
        payload["uptime_seconds"] = now / 1000;
        sendToSupabase(DEVICE_ID, "SOS_TRIGGERED", LOCATION_ID, payload);

        // Send display command to Arduino
        sendToArduino("SOS:TRIGGERED:" + String(now / 1000));
      }
    }
  }

  lastButtonState = reading;
}

// ============================================================
// SENSOR HANDLER
// ============================================================

void handleSensors(unsigned long now) {
  int gasReading = readGasSensor();
  float tempReading = readTemperature();

  // Always send current readings to Arduino for display
  sendToArduino("SENSOR:GAS:" + String(gasReading) + ":ppm");

  if (!isnan(tempReading)) {
    sendToArduino("SENSOR:TEMP:" + String((int)tempReading) + ":C");
  }

  // --- Gas threshold check ---
  if (gasReading > GAS_THRESHOLD) {
    gasBreachCount++;
    if (gasBreachCount >= BREACH_CONFIRM_COUNT) {
      Serial.println("[Main] GAS ALERT! Reading: " + String(gasReading));
      activateAlarm();
      sendToArduino("ALERT:GAS");

      StaticJsonDocument<256> payload;
      payload["sensor"] = "MQ-2";
      payload["reading"] = gasReading;
      payload["threshold"] = GAS_THRESHOLD;
      payload["unit"] = "ppm";
      sendToSupabase(DEVICE_ID, "SMOKE_DETECTED", LOCATION_ID, payload);

      gasBreachCount = 0;  // Reset after alert
    }
  } else {
    gasBreachCount = 0;
  }

  // --- Temperature threshold check ---
  if (!isnan(tempReading) && tempReading > TEMP_THRESHOLD) {
    tempBreachCount++;
    if (tempBreachCount >= BREACH_CONFIRM_COUNT) {
      Serial.println("[Main] TEMP ALERT! Reading: " + String(tempReading));
      activateAlarm();
      sendToArduino("ALERT:TEMP");

      StaticJsonDocument<256> payload;
      payload["sensor"] = "DHT11";
      payload["reading"] = tempReading;
      payload["threshold"] = TEMP_THRESHOLD;
      payload["unit"] = "C";
      sendToSupabase(DEVICE_ID, "HIGH_TEMP", LOCATION_ID, payload);

      tempBreachCount = 0;  // Reset after alert
    }
  } else {
    tempBreachCount = 0;
  }
}

// ============================================================
// SENSOR READING FUNCTIONS
// ============================================================

int readGasSensor() {
  return analogRead(GAS_SENSOR_PIN);
}

float readTemperature() {
  float temp = dht.readTemperature();
  if (isnan(temp)) {
    Serial.println("[Main] DHT11 read failed.");
  }
  return temp;
}

// ============================================================
// ALARM CONTROL
// ============================================================

void activateAlarm() {
  digitalWrite(LED_PIN, HIGH);
  digitalWrite(BUZZER_PIN, HIGH);
  alarmActive = true;
  alarmStartTime = millis();
}

void deactivateAlarm() {
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
  alarmActive = false;
}

// ============================================================
// WIFI CONNECTION
// ============================================================

void connectWiFi() {
  Serial.print("[Main] Connecting to WiFi: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < WIFI_MAX_RETRIES) {
    delay(WIFI_RETRY_DELAY);
    Serial.print(".");
    // Blink LED during connection
    digitalWrite(LED_PIN, retries % 2 == 0 ? HIGH : LOW);
    retries++;
  }

  digitalWrite(LED_PIN, LOW);

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[Main] WiFi connected! IP: " + WiFi.localIP().toString());
  } else {
    Serial.println("\n[Main] WiFi connection FAILED. Will retry in loop.");
  }
}

// ============================================================
// SUPABASE HTTP POST
// ============================================================

void sendToSupabase(const char* deviceId, const char* eventType,
                    const char* locationId, JsonDocument& payloadDoc) {
  // Check WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[Main] WiFi not connected. Attempting reconnect...");
    connectWiFi();
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("[Main] Cannot send — no WiFi.");
      return;
    }
  }

  // Build full URL
  String url = String(SUPABASE_URL) + DEVICE_EVENTS_ENDPOINT;

  // Build JSON body
  StaticJsonDocument<512> doc;
  doc["device_id"] = deviceId;
  doc["event_type"] = eventType;
  doc["location_id"] = locationId;

  // Serialize nested payload
  JsonObject payloadObj = doc.createNestedObject("payload");
  for (JsonPair kv : payloadDoc.as<JsonObject>()) {
    payloadObj[kv.key()] = kv.value();
  }

  String body;
  serializeJson(doc, body);

  // HTTPS request
  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
  client->setInsecure();  // Skip certificate verification for prototype

  HTTPClient http;
  http.begin(*client, url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_KEY);
  http.addHeader("Prefer", "return=representation");

  int httpCode = http.POST(body);

  if (httpCode > 0) {
    Serial.println("[Main] Supabase POST " + String(eventType) + " → " + String(httpCode));
  } else {
    Serial.println("[Main] Supabase POST failed: " + http.errorToString(httpCode));
  }

  http.end();
}

// ============================================================
// HEARTBEAT
// ============================================================

void sendHeartbeat() {
  StaticJsonDocument<256> payload;
  payload["rssi"] = WiFi.RSSI();
  payload["firmware"] = FIRMWARE_VER;
  payload["uptime_seconds"] = millis() / 1000;
  sendToSupabase(DEVICE_ID, "HEARTBEAT", LOCATION_ID, payload);
}

// ============================================================
// SERIAL COMMUNICATION TO ARDUINO
// ============================================================

void sendToArduino(String command) {
  Serial.println(command);
}
