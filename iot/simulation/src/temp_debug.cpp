/*
 * DS18B20 Live Temperature Diagnostic Tool
 * Scans OneWire bus on D7 and prints raw addresses + live temperature.
 */

#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define TEMP_DQ_PIN   D7
#define BUZZER_PIN    D5
#define STATUS_LED    LED_BUILTIN

OneWire oneWire(TEMP_DQ_PIN);
DallasTemperature tempSensor(&oneWire);

DeviceAddress tempDeviceAddress;

void setup() {
  Serial.begin(115200);
  delay(500);

  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(STATUS_LED, OUTPUT);
  noTone(BUZZER_PIN);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(STATUS_LED, HIGH);

  Serial.println("\n==========================================");
  Serial.println("  DS18B20 Temperature Diagnostic Tool");
  Serial.println("==========================================");

  tempSensor.begin();

  int deviceCount = tempSensor.getDeviceCount();
  Serial.printf("[INFO] OneWire Devices Found on D7: %d\n\n", deviceCount);

  if (deviceCount > 0) {
    if (tempSensor.getAddress(tempDeviceAddress, 0)) {
      Serial.print("[OK] Sensor ROM Address: ");
      for (uint8_t i = 0; i < 8; i++) {
        Serial.printf("%02X ", tempDeviceAddress[i]);
      }
      Serial.println();
    }
  } else {
    Serial.println("[!] NO DEVICES DETECTED! Check:");
    Serial.println("    1. Red wire to 3V");
    Serial.println("    2. Black wire to GND");
    Serial.println("    3. Yellow wire to D7");
    Serial.println("    4. 2.2k pull-up resistor between 3V (Red) and D7 (Yellow)");
  }
}

void loop() {
  tempSensor.requestTemperatures();
  float tempC = tempSensor.getTempCByIndex(0);

  if (tempC == DEVICE_DISCONNECTED_C || tempC == -127.0) {
    Serial.println("[TEMP] Reading: -127.00 C -> Disconnected / Missing Pull-up Resistor!");
  } else {
    Serial.printf("[TEMP] SUCCESS! Live Temperature: %.2f C  (%.2f F)\n", tempC, (tempC * 9.0 / 5.0) + 32.0);
  }

  delay(1200);
}
