#include <Arduino.h>

// Arduino Uno has a built-in LED labeled 'L' connected to Digital Pin 13

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("\n==================================");
  Serial.println("   Arduino Uno R3 Blink Test      ");
  Serial.println("==================================");
}

void loop() {
  Serial.println("Arduino Uno: LED ON");
  digitalWrite(LED_BUILTIN, HIGH);
  delay(500);

  Serial.println("Arduino Uno: LED OFF");
  digitalWrite(LED_BUILTIN, LOW);
  delay(500);
}
