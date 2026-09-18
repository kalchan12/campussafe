/*
 * I2C Scanner for Arduino Uno with Wire Timeout to prevent freeze
 */
#include <Arduino.h>
#include <Wire.h>

void setup() {
  Wire.begin();
  Wire.setWireTimeout(3000, true); // 3ms timeout, reset on timeout
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n--- I2C Scanner Active ---");
}

void loop() {
  byte error, address;
  int nDevices = 0;

  for (address = 1; address < 127; address++) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0) {
      Serial.print("[FOUND] I2C device at: 0x");
      if (address < 16) Serial.print("0");
      Serial.print(address, HEX);
      Serial.println();
      nDevices++;
    }
  }

  if (nDevices == 0) {
    Serial.println("[!] No I2C device found! Bus may be held LOW or disconnected.");
  } else {
    Serial.println("[OK] Scan complete.\n");
  }

  delay(2000);
}
