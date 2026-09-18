#include <Arduino.h>
#include <LiquidCrystal.h>

// Pin configuration matching your wiring:
// RS -> Pin 7
// EN -> Pin 8
// D4 -> Pin 9
// D5 -> Pin 10
// D6 -> Pin 11
// D7 -> Pin 12
const int rs = 7, en = 8, d4 = 9, d5 = 10, d6 = 11, d7 = 12;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

bool inSOS = false;

void showHelloWorld() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Hello, World!");
  lcd.setCursor(0, 1);
  lcd.print("System Ready :) ");
  inSOS = false;
}

void showSOS() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sending SOS");
  lcd.setCursor(0, 1);
  lcd.print("signal...       ");
  inSOS = true;
}

void setup() {
  // Serial communication with ESP8266 at 115200 baud
  Serial.begin(115200);

  // Power stabilization delay for LCD
  delay(250);

  // Initialize 16x2 LCD
  lcd.begin(16, 2);
  delay(50);

  showHelloWorld();
}

void loop() {
  // Listen for commands from ESP8266
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    line.trim();

    if (line.indexOf("SOS:1") >= 0) {
      showSOS();
    } else if (line.indexOf("SOS:0") >= 0) {
      showHelloWorld();
    }
  }
}
