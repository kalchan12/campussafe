/*
 * CampusSafe — Hardware SOS Alert Test
 * Board: ESP8266 NodeMCU Amica v2
 *
 * Architecture: DIRECT TO SUPABASE CLOUD (Zero Local Network Dependency)
 *
 * Hardware:
 *   - FLASH button (GPIO 0 / D3) -> SOS Trigger (Active LOW)
 *   - On-board LED (GPIO 2 / D4) -> Visual indicator (Active LOW)
 *
 * Behavior:
 *   When the FLASH button is pressed:
 *   1. On-board LED turns ON.
 *   2. HTTPS POST request is sent directly to Supabase Cloud:
 *      - Logs event to `device_events`
 *      - Creates P1 Emergency Incident in `incidents` with map coordinates!
 *   3. Supabase Realtime broadcasts to Web Dashboard and Mobile App worldwide.
 */

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <ArduinoJson.h>

// ============================================================
// 1. WI-FI CONFIGURATION
// ============================================================
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// ============================================================
// 2. SUPABASE CLOUD CONFIGURATION
// ============================================================
const char* SUPABASE_URL = "https://hiqssgqpjyheehwfaxla.supabase.co";
const char* SUPABASE_KEY = "YOUR_SUPABASE_KEY";

// Device identity & Location Coordinates
const char* DEVICE_ID       = "STATION-ENG-01";
const char* CAMPUS_BLOCK    = "Engineering Block";
const double LATITUDE       = 8.5582;
const double LONGITUDE      = 39.2895;

// ============================================================
// 3. HARDWARE PIN DEFINITIONS
// ============================================================
#define BUTTON_PIN_D1  D1           // External SOS Push Button (GPIO 5 / D1)
#define BUTTON_PIN_D3  0            // FLASH button & External D3 (GPIO 0 / D3)
#define STATUS_LED     LED_BUILTIN  // Built-in Blue LED (GPIO 2 / D4, active LOW)

// ============================================================
// 4. DEBOUNCE STATE VARIABLES
// ============================================================
int buttonState = HIGH;
int lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;
int sosCount = 0;

void connectWiFi();
void triggerSOS();

void setup() {
  Serial.begin(115200);
  delay(500);

  Serial.println("\n========================================");
  Serial.println("  CampusSafe - SOS Direct Cloud Test");
  Serial.println("  Target: Supabase Cloud (Global / No LAN)");
  Serial.println("========================================\n");

  pinMode(BUTTON_PIN_D1, INPUT_PULLUP);
  pinMode(BUTTON_PIN_D3, INPUT_PULLUP);
  pinMode(STATUS_LED, OUTPUT);
  digitalWrite(STATUS_LED, HIGH); // LED OFF (active LOW)

  connectWiFi();

  Serial.println("\n>> READY! Press button on D3, D1, or FLASH to trigger Emergency SOS.\n");
}

void loop() {
  int reading = (digitalRead(BUTTON_PIN_D1) == LOW || digitalRead(BUTTON_PIN_D3) == LOW) ? LOW : HIGH;

  // Check if button state changed
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  // Wait debounce delay to filter electrical noise
  if ((millis() - lastDebounceTime) > debounceDelay) {
    // If state has changed after debounce
    if (reading != buttonState) {
      buttonState = reading;

      // Only trigger on transition to LOW (pressed)
      if (buttonState == LOW) {
        sosCount++;
        Serial.println("SOS:1"); // Send signal to Arduino Uno LCD
        Serial.println("--------------------------------------------");
        Serial.printf("[!] SOS Button Pressed! [Event #%d]\n", sosCount);

        // Turn on LED for visual feedback
        digitalWrite(STATUS_LED, LOW);

        triggerSOS();

        // Turn off LED
        digitalWrite(STATUS_LED, HIGH);
        Serial.println("--------------------------------------------\n");

        delay(3000); // Keep SOS message on LCD for 3 seconds
        Serial.println("SOS:0"); // Reset LCD back to System Ready
      }
    }
  }

  lastButtonState = reading;
}

void connectWiFi() {
  Serial.printf("Connecting to Wi-Fi \"%s\"", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(STATUS_LED, !digitalRead(STATUS_LED)); // Blink while searching
  }

  digitalWrite(STATUS_LED, HIGH); // Turn off LED once connected
  Serial.printf("\n[+] Wi-Fi Connected! Local IP: %s\n", WiFi.localIP().toString().c_str());
  Serial.printf("[+] RSSI Signal: %d dBm\n", WiFi.RSSI());
}

void triggerSOS() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[!] Wi-Fi disconnected. Reconnecting...");
    connectWiFi();
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("[X] Cannot send - Wi-Fi unavailable.");
      return;
    }
  }

  // 1. Create Incident in Supabase (For Live Map & Mobile Alerts)
  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
  client->setInsecure(); // Skip certificate verification for prototype speed

  HTTPClient https;
  String incidentUrl = String(SUPABASE_URL) + "/rest/v1/incidents";

  StaticJsonDocument<384> doc;
  doc["type"]                 = "security";
  doc["priority"]             = 1;
  doc["source"]               = "iot";
  doc["latitude"]             = LATITUDE;
  doc["longitude"]            = LONGITUDE;
  doc["campus_block"]         = CAMPUS_BLOCK;
  doc["location_description"] = "Hardware SOS Station " + String(DEVICE_ID);
  doc["description"]          = "EMERGENCY SOS triggered from Hardware Station " + String(DEVICE_ID);
  doc["status"]               = "created";

  String requestBody;
  serializeJson(doc, requestBody);

  Serial.println("[>] Sending Incident directly to Supabase Cloud...");
  Serial.println("[>] Endpoint: " + incidentUrl);
  Serial.println("[>] Body: " + requestBody);

  if (https.begin(*client, incidentUrl)) {
    https.addHeader("Content-Type", "application/json");
    https.addHeader("apikey", SUPABASE_KEY);
    https.addHeader("Authorization", String("Bearer ") + SUPABASE_KEY);
    https.addHeader("Prefer", "return=representation");

    int httpCode = https.POST(requestBody);

    if (httpCode > 0) {
      Serial.printf("[+] HTTP Response Code: %d\n", httpCode);
      if (httpCode == 201) {
        Serial.println("[***] SUCCESS! Incident created in Supabase Cloud!");
        Serial.println("[***] Check your Web Map & Mobile App now!");
      }
      String response = https.getString();
      Serial.println("[+] Supabase Response: " + response);
    } else {
      Serial.printf("[X] HTTPS Request Failed: %s\n", https.errorToString(httpCode).c_str());
    }
    https.end();
  } else {
    Serial.println("[X] Unable to open HTTPS connection.");
  }

  // 2. Also log event to device_events table
  String eventUrl = String(SUPABASE_URL) + "/rest/v1/device_events";
  StaticJsonDocument<256> eventDoc;
  eventDoc["device_id"]  = DEVICE_ID;
  eventDoc["event_type"] = "SOS_TRIGGERED";
  eventDoc["latitude"]   = LATITUDE;
  eventDoc["longitude"]  = LONGITUDE;
  
  JsonObject payload = eventDoc.createNestedObject("payload");
  payload["source"]     = "board_flash_button";
  payload["sos_count"]  = sosCount;
  payload["uptime_sec"] = millis() / 1000;

  String eventBody;
  serializeJson(eventDoc, eventBody);

  if (https.begin(*client, eventUrl)) {
    https.addHeader("Content-Type", "application/json");
    https.addHeader("apikey", SUPABASE_KEY);
    https.addHeader("Authorization", String("Bearer ") + SUPABASE_KEY);
    https.POST(eventBody);
    https.end();
  }
}
