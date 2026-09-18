#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// ===== ESP32 Pins =====
#define BUTTON_PIN     1   // Push Button input
#define LED_PIN        2   // Local Alert LED (through 220-ohm resistor)
#define BUZZER_PIN     4   // Audio Alert Buzzer
#define GAS_AOUT_PIN   3   // Gas Sensor Analog
#define GAS_DOUT_PIN   5   // Gas Sensor Digital
#define TEMP_DQ_PIN    6   // DS18B20 1-Wire pin (with 4.7k-ohm pull-up)

#define HEAT_THRESHOLD 40.0 // Heat warning threshold in Celsius

OneWire oneWire(TEMP_DQ_PIN);
DallasTemperature tempSensor(&oneWire);

void setup() {
  // Serial: terminal monitoring & sending commands to Uno
  Serial.begin(115200);

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  pinMode(GAS_DOUT_PIN, INPUT);
  tempSensor.begin();

  delay(1000);
  Serial.println("INIT:ESP32 Ready");
}

void loop() {
  // 1. Read Push Button
  bool buttonPressed = (digitalRead(BUTTON_PIN) == LOW);

  // 2. Read Sensors (Gas & Temp)
  bool gasDigital = (digitalRead(GAS_DOUT_PIN) == LOW);
  int gasAnalog = analogRead(GAS_AOUT_PIN);
  bool gasDetected = gasDigital || (gasAnalog > 1500);

  tempSensor.requestTemperatures();
  float tempC = tempSensor.getTempCByIndex(0);
  bool heatDetected = (tempC > -100.0 && tempC >= HEAT_THRESHOLD);

  // Audio/Visual Feedback:
  // - LED turns ON when SOS button is pressed or hazard detected
  // - Buzzer sounds an alarm when SOS button is pressed or hazard detected
  if (buttonPressed) {
    digitalWrite(LED_PIN, HIGH);
    // Pulsing or steady alert beep for user feedback
    tone(BUZZER_PIN, 2000, 200); // 2kHz tone
  } else if (gasDetected || heatDetected) {
    digitalWrite(LED_PIN, HIGH);
    tone(BUZZER_PIN, 1000, 150); // 1kHz hazard alarm tone
  } else {
    digitalWrite(LED_PIN, LOW);
    noTone(BUZZER_PIN);
  }

  // Send SOS command to Arduino Uno for LCD 1
  if (buttonPressed) {
    Serial.println("SOS:1");
  } else {
    Serial.println("SOS:0");
  }

  // Auto-demo simulation cycle so you can see each hazard state in Wokwi
  unsigned long sec = (millis() / 1000) % 16;
  int demoState = sec / 4; 

  // Send Hazard command to Arduino Uno for LCD 2
  if (gasDetected && heatDetected) {
    Serial.println("HAZARD:BOTH");
  } else if (gasDetected || demoState == 0) {
    Serial.println("HAZARD:GAS");
  } else if (heatDetected || demoState == 1) {
    Serial.println("HAZARD:HEAT");
  } else if (demoState == 2) {
    Serial.println("HAZARD:BOTH");
  } else {
    Serial.println("HAZARD:NORMAL");
  }

  delay(300);
}
