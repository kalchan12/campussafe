/*
 * Diagnostic & Calibration Tool for CampusSafe Hardware
 * Reads every pin and prints live status over Serial at 115200 baud.
 */

#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define BUTTON_PIN_D1   D1
#define BUTTON_PIN_D3   0            // FLASH button & D3
#define BUZZER_PIN      D5
#define GAS_DOUT_PIN    D6
#define GAS_AOUT_PIN    A0
#define TEMP_DQ_PIN     D7
#define STATUS_LED      LED_BUILTIN

OneWire oneWire(TEMP_DQ_PIN);
DallasTemperature tempSensor(&oneWire);

void setup() {
  Serial.begin(115200);
  delay(500);

  pinMode(BUTTON_PIN_D1, INPUT_PULLUP);
  pinMode(BUTTON_PIN_D3, INPUT_PULLUP);
  pinMode(GAS_DOUT_PIN, INPUT_PULLUP); // Use pullup so unplugged doesn't float LOW!
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(STATUS_LED, OUTPUT);

  // KEEP BUZZER SILENT BY DEFAULT
  noTone(BUZZER_PIN);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(STATUS_LED, HIGH);

  tempSensor.begin();

  Serial.println("\n==========================================");
  Serial.println("  CampusSafe Pin Diagnostic Tool Active");
  Serial.println("  (Buzzer is currently SILENCED)");
  Serial.println("==========================================\n");
}

void loop() {
  // Read pins
  int btnD1 = digitalRead(BUTTON_PIN_D1);
  int btnD3 = digitalRead(BUTTON_PIN_D3);
  int gasDig = digitalRead(GAS_DOUT_PIN);
  int gasAna = analogRead(GAS_AOUT_PIN);

  tempSensor.requestTemperatures();
  float tempC = tempSensor.getTempCByIndex(0);

  Serial.printf("[PINS] BtnD1:%d | BtnD3:%d | GasDig(D6):%d | GasAna(A0):%4d | Temp(D7):%6.2f C\n",
                btnD1, btnD3, gasDig, gasAna, tempC);

  // Check what would trigger an alarm:
  if (btnD1 == LOW || btnD3 == LOW) {
    Serial.println("  --> [ALERT] Button is PRESSED (or grounded)!");
  }
  if (gasDig == LOW) {
    Serial.println("  --> [ALERT] Gas Digital (D6) is LOW (triggering alarm)!");
  }
  if (gasAna > 380) {
    Serial.println("  --> [ALERT] Gas Analog (A0) is above 380 (triggering alarm)!");
  }
  if (tempC >= 40.0) {
    Serial.println("  --> [ALERT] Temp is above 40C (triggering heat alarm)!");
  }

  delay(1000);
}
