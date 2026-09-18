#include <Arduino.h>

// ESP8266 onboard LEDs:
// - LED_BUILTIN is GPIO 2 (D4) on the ESP-12 module (active LOW)
// - NodeMCU also has an LED on GPIO 16 (D0) (active LOW)

void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println("\n==================================");
  Serial.println("   ESP8266 Steady Light ON       ");
  Serial.println("==================================");

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(16, OUTPUT); // D0

  // Active LOW: LOW turns LEDs ON solidly
  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(16, LOW);
}

void loop() {
  // Keep LEDs steadily ON
  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(16, LOW);
  delay(1000);
}
