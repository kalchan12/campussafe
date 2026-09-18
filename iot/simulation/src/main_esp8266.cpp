/*
 * CampusSafe — Full IoT Controller Master Program
 * Board: NodeMCU ESP8266 (ESP-12E)
 *
 * Hardware Peripherals:
 *   - SOS Push Button:       D1 / D3 (Active LOW, INPUT_PULLUP)
 *   - MQ Gas Sensor Analog:  A0
 *   - MQ Gas Sensor Digital: D6
 *   - DS18B20 Temp Probe:    D7 (with 2.2k/4.7k pull-up to 3V)
 *   - Piezo Buzzer:          D5
 *   - Status LED:            LED_BUILTIN (Active LOW)
 *   - UART Link:             TX (GPIO 1) -> Arduino Uno Pin 0 (RX) at 115200 baud
 *   - Cloud Backend:         Direct HTTPS POST to Supabase Cloud
 */

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// ============================================================
// 1. PIN DEFINITIONS
// ============================================================
#define BUTTON_PIN_D1   D1
#define BUTTON_PIN_D3   0            // Built-in FLASH button & D3
#define BUZZER_PIN      D5
#define GAS_DOUT_PIN    D6
#define GAS_AOUT_PIN    A0
#define TEMP_DQ_PIN     D7
#define STATUS_LED      LED_BUILTIN

// ============================================================
// 2. SENSOR THRESHOLDS
// ============================================================
#define HEAT_THRESHOLD_C  40.0       // Degrees Celsius
#define GAS_ANALOG_THRESH 800        // Gas alarm triggers at >= 800 (prevents warm-up false alarms)

OneWire oneWire(TEMP_DQ_PIN);
DallasTemperature tempSensor(&oneWire);

// ============================================================
// 3. WI-FI & SUPABASE CONFIGURATION
// ============================================================
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

const char* SUPABASE_URL  = "https://hiqssgqpjyheehwfaxla.supabase.co";
const char* SUPABASE_KEY  = "YOUR_SUPABASE_KEY";

const char* DEVICE_ID     = "STATION-ENG-01";
const char* CAMPUS_BLOCK  = "Engineering Block";
const double LATITUDE     = 8.5582;
const double LONGITUDE    = 39.2895;

// State management
int buttonState = HIGH;
int lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;

unsigned long lastTempRead = 0;
float currentTempC = 25.0;

unsigned long lastCloudIncident = 0;
const unsigned long incidentCooldown = 25000; // 25s between automatic hazard posts
unsigned long lastLcdStream = 0; // Stream live values to LCD 2 every 1s

String currentHazard = "NORMAL";
String lastSentHazard = "NORMAL";

void connectWiFi();
void sendCloudIncident(const char* type, const char* desc);

void setup() {
  Serial.begin(115200);
  delay(200);

  pinMode(BUTTON_PIN_D1, INPUT_PULLUP);
  pinMode(BUTTON_PIN_D3, INPUT_PULLUP);
  pinMode(GAS_DOUT_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(STATUS_LED, OUTPUT);

  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(STATUS_LED, HIGH); // OFF (active LOW)

  tempSensor.begin();

  connectWiFi();

  // Initial display sync
  Serial.println("SOS:0");
  Serial.println("HAZARD:NORMAL");
}

void loop() {
  unsigned long now = millis();

  // ------------------------------------------------------------
  // 1. READ PUSH BUTTON (SOS)
  // ------------------------------------------------------------
  int reading = (digitalRead(BUTTON_PIN_D1) == LOW || digitalRead(BUTTON_PIN_D3) == LOW) ? LOW : HIGH;
  if (reading != lastButtonState) {
    lastDebounceTime = now;
  }

  if ((now - lastDebounceTime) > debounceDelay) {
    if (reading != buttonState) {
      buttonState = reading;

      if (buttonState == LOW) {
        // BUTTON PRESSED!
        digitalWrite(STATUS_LED, LOW); // LED ON
        tone(BUZZER_PIN, 2000, 400);   // SOS Audio chirp
        Serial.println("SOS:1");       // Tell Arduino Uno LCD 1

        sendCloudIncident("security", "EMERGENCY SOS triggered from Hardware Station STATION-ENG-01");

        digitalWrite(STATUS_LED, HIGH);
        delay(2500);
        Serial.println("SOS:0");       // Reset LCD 1
      }
    }
  }
  lastButtonState = reading;

  // ------------------------------------------------------------
  // 2. READ TEMPERATURE SENSOR (Every 1.5 seconds)
  // ------------------------------------------------------------
  if (now - lastTempRead > 1500) {
    lastTempRead = now;
    tempSensor.requestTemperatures();
    float t = tempSensor.getTempCByIndex(0);
    if (t > -55.0 && t < 125.0) {
      currentTempC = t;
    }
  }

  // ------------------------------------------------------------
  // 3. READ GAS SENSOR
  // ------------------------------------------------------------
  int gasAnalog = analogRead(GAS_AOUT_PIN);
  // Alarm triggers only if gasAnalog reaches the demo threshold (>= 800)
  bool gasActive = (gasAnalog >= GAS_ANALOG_THRESH);
  bool heatActive = (currentTempC > 0.0 && currentTempC < 100.0 && currentTempC >= HEAT_THRESHOLD_C);

  // ------------------------------------------------------------
  // 4. DETERMINE HAZARD STATE
  // ------------------------------------------------------------
  if (gasActive && heatActive) {
    currentHazard = "BOTH";
  } else if (gasActive) {
    currentHazard = "GAS";
  } else if (heatActive) {
    currentHazard = "HEAT";
  } else {
    currentHazard = "NORMAL";
  }

  // Audio alarm on hazard
  if (currentHazard != "NORMAL") {
    tone(BUZZER_PIN, 1000, 100); // 1kHz hazard beep
    digitalWrite(STATUS_LED, !digitalRead(STATUS_LED)); // Flash LED
  } else {
    noTone(BUZZER_PIN);
    digitalWrite(STATUS_LED, HIGH);
  }

  // Update Arduino Uno LCD 2 when state changes
  if (currentHazard != lastSentHazard) {
    String prevHazard = lastSentHazard;
    lastSentHazard = currentHazard;
    Serial.println("HAZARD:" + currentHazard);

    // Send incident to Supabase EXACTLY ONCE when transitioning from NORMAL to HAZARD!
    if (prevHazard == "NORMAL" && currentHazard != "NORMAL") {
      Serial.println("[CLOUD] Triggering single hazard incident upload to Supabase...");
      if (currentHazard == "GAS") {
        sendCloudIncident("environmental", "HAZARDOUS GAS LEAK detected by Station STATION-ENG-01");
      } else if (currentHazard == "HEAT") {
        sendCloudIncident("fire", "EXTREME HEAT / FIRE HAZARD detected by Station STATION-ENG-01");
      } else if (currentHazard == "BOTH") {
        sendCloudIncident("fire", "CRITICAL FIRE & GAS LEAK detected by Station STATION-ENG-01");
      }
    }
  }

  // Stream live values to Arduino Uno LCD 2 every 1 second
  if (now - lastLcdStream > 1000) {
    lastLcdStream = now;
    char tempBuf[8];
    dtostrf(currentTempC, 4, 1, tempBuf); // e.g. "25.0"
    Serial.printf("DATA:%s,%d\n", tempBuf, gasAnalog);
  }

  delay(50);
}

void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;
  Serial.print("\n[WIFI] Connecting to SSID: ");
  Serial.println(WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 35) {
    delay(400);
    digitalWrite(STATUS_LED, !digitalRead(STATUS_LED));
    Serial.print(".");
    retries++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("\n[WIFI] CONNECTED! IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[WIFI] FAILED to connect! Check SSID/Password or Router.");
  }

  digitalWrite(STATUS_LED, HIGH);
}

void sendCloudIncident(const char* type, const char* desc) {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
    if (WiFi.status() != WL_CONNECTED) return;
  }

  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
  client->setInsecure();
  client->setBufferSizes(1024, 512); // Prevent RAM fragmentation

  HTTPClient https;
  String url = String(SUPABASE_URL) + "/rest/v1/incidents";

  StaticJsonDocument<384> doc;
  doc["type"]                 = type;
  doc["priority"]             = 1;
  doc["source"]               = "iot";
  doc["latitude"]             = LATITUDE;
  doc["longitude"]            = LONGITUDE;
  doc["campus_block"]         = CAMPUS_BLOCK;
  doc["location_description"] = "Hardware Station " + String(DEVICE_ID);
  doc["description"]          = desc;
  doc["status"]               = "created";

  String body;
  serializeJson(doc, body);

  if (https.begin(*client, url)) {
    https.addHeader("Content-Type", "application/json");
    https.addHeader("apikey", SUPABASE_KEY);
    https.addHeader("Authorization", String("Bearer ") + SUPABASE_KEY);
    int httpCode = https.POST(body);
    Serial.printf("[CLOUD] Supabase POST Result Code: %d\n", httpCode);
    https.end();
  } else {
    Serial.println("[CLOUD] Failed to connect to Supabase HTTPS endpoint!");
  }
}
