/*
 * CampusSafe — Gas Sensor + Push Button + Buzzer + Dual LCD + Supabase Test
 * Board: NodeMCU ESP8266
 * 
 * Configured specifically for testing:
 *   - Push Button: D1 / D3
 *   - MQ Gas Sensor Analog: A0 (Reliable threshold, D6 ignored to prevent false alarms!)
 *   - Piezo Buzzer: D5
 *   - Temperature (D7): Temporarily disabled until you wire it later
 *   - LCD Transmitter: Serial TX -> Arduino Pin 0
 *   - Supabase Cloud: Sends incident on SOS press or Gas detection
 */

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <ArduinoJson.h>

// ============================================================
// 1. PIN DEFINITIONS
// ============================================================
#define BUTTON_PIN_D1   D1
#define BUTTON_PIN_D3   0            // FLASH button & D3
#define BUZZER_PIN      D5
#define GAS_AOUT_PIN    A0           // Read true gas level
#define STATUS_LED      LED_BUILTIN

// ============================================================
// 2. GAS SENSOR THRESHOLD
// ============================================================
// Normal clean air reads ~15-60.
// Gas/Alcohol smoke pushes it over 250-400.
#define GAS_ALARM_THRESHOLD  250

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

unsigned long lastGasCheck = 0;
bool gasAlarmActive = false;

unsigned long lastCloudIncident = 0;
const unsigned long incidentCooldown = 20000; // 20s between cloud posts

void connectWiFi();
void sendCloudIncident(const char* type, const char* desc);

void setup() {
  Serial.begin(115200);
  delay(200);

  pinMode(BUTTON_PIN_D1, INPUT_PULLUP);
  pinMode(BUTTON_PIN_D3, INPUT_PULLUP);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(STATUS_LED, OUTPUT);

  noTone(BUZZER_PIN);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(STATUS_LED, HIGH); // OFF (active LOW)

  connectWiFi();

  // Initial sync with Arduino LCDs
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
        // SOS Button Pressed!
        digitalWrite(STATUS_LED, LOW);
        tone(BUZZER_PIN, 2000, 350);  // High SOS chirp
        Serial.println("SOS:1");      // LCD 1: Sending SOS signal...

        sendCloudIncident("security", "EMERGENCY SOS triggered from Hardware Station STATION-ENG-01");

        digitalWrite(STATUS_LED, HIGH);
        delay(2500);
        Serial.println("SOS:0");      // LCD 1: SOS Ready
      }
    }
  }
  lastButtonState = reading;

  // ------------------------------------------------------------
  // 2. READ GAS SENSOR (Analog A0)
  // ------------------------------------------------------------
  if (now - lastGasCheck > 1000) {
    lastGasCheck = now;
    int gasLevel = analogRead(GAS_AOUT_PIN);
    Serial.printf("[GAS] Raw A0: %d (Alarm Threshold: %d)\n", gasLevel, GAS_ALARM_THRESHOLD);

    if (gasLevel >= GAS_ALARM_THRESHOLD) {
      // GAS DETECTED!
      if (!gasAlarmActive) {
        gasAlarmActive = true;
        Serial.println("HAZARD:GAS"); // LCD 2: Gas Detected! Evacuate! Safe!

        if (now - lastCloudIncident > incidentCooldown) {
          lastCloudIncident = now;
          sendCloudIncident("environmental", "HAZARDOUS GAS LEAK detected by Station STATION-ENG-01");
        }
      }
      // Beep buzzer while gas is present
      tone(BUZZER_PIN, 1000, 100);
      digitalWrite(STATUS_LED, !digitalRead(STATUS_LED)); // Flash LED
    } else {
      // GAS IS NORMAL / CLEARED
      if (gasAlarmActive) {
        gasAlarmActive = false;
        noTone(BUZZER_PIN);
        digitalWrite(STATUS_LED, HIGH);
        Serial.println("HAZARD:NORMAL"); // LCD 2: LCD 2: HAZARD OK / Status: Normal
      }
    }
  }

  delay(50);
}

void connectWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 25) {
    delay(400);
    digitalWrite(STATUS_LED, !digitalRead(STATUS_LED));
    retries++;
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
  client->setBufferSizes(1024, 512);

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
    https.POST(body);
    https.end();
  }
}
