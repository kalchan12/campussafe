#include <Arduino.h>
#include <ESP8266WiFi.h>

// ===== WiFi Credentials =====
// NOTE: ESP8266 supports ONLY 2.4 GHz networks (it does not support 5 GHz).
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH); // OFF while waiting

  Serial.println();
  Serial.println("=========================================");
  Serial.println("      ESP8266 WiFi Connection Test      ");
  Serial.println("=========================================");

  Serial.print("Connecting to: ");
  Serial.println(ssid);

  // Set WiFi mode to station (client)
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  // Wait for connection while blinking onboard LED
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN)); // Toggle blink
    Serial.print(".");
    attempts++;
  }

  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    digitalWrite(LED_BUILTIN, LOW); // Solid ON when connected
    Serial.println("\n WiFi Connected Successfully!");
    Serial.print("IP Address:   ");
    Serial.println(WiFi.localIP());
    Serial.print("Gateway IP:   ");
    Serial.println(WiFi.gatewayIP());
    Serial.print("Signal (RSSI):");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
    Serial.println("=========================================\n");
  } else {
    digitalWrite(LED_BUILTIN, HIGH); // OFF on failure
    Serial.println("\n Failed to connect to WiFi.");
    Serial.println("Checks:");
    Serial.println(" 1. Make sure SSID and password are correct.");
    Serial.println(" 2. Ensure network is 2.4 GHz (ESP8266 cannot connect to 5 GHz).");
    Serial.println("=========================================\n");
  }
}

void loop() {
  // Periodically report status every 10 seconds
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("[WiFi Status: OK] IP: ");
    Serial.print(WiFi.localIP());
    Serial.print(" | Signal: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("[WiFi Status: DISCONNECTED] Reconnecting...");
    WiFi.reconnect();
  }
  delay(10000);
}
