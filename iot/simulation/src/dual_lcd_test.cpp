#include <Arduino.h>
#include <LiquidCrystal.h>

// LCD 1 (SOS Display)
// RS->7, EN->8, D4->9, D5->10, D6->11, D7->12
const int lcd1_rs = 7, lcd1_en = 8, lcd1_d4 = 9, lcd1_d5 = 10, lcd1_d6 = 11, lcd1_d7 = 12;
LiquidCrystal lcd1(lcd1_rs, lcd1_en, lcd1_d4, lcd1_d5, lcd1_d6, lcd1_d7);

// LCD 2 (Sensor Hazard Display)
// RS->2, EN->3, D4->4, D5->5, D6->6, D7->13
const int lcd2_rs = 2, lcd2_en = 3, lcd2_d4 = 4, lcd2_d5 = 5, lcd2_d6 = 6, lcd2_d7 = A0;
LiquidCrystal lcd2(lcd2_rs, lcd2_en, lcd2_d4, lcd2_d5, lcd2_d6, lcd2_d7);

void setup() {
  Serial.begin(115200);

  // Power stabilization delay for both screens
  delay(400);

  // Initialize LCD 1 (SOS Screen)
  lcd1.begin(16, 2);
  delay(50);
  lcd1.clear();
  lcd1.setCursor(0, 0);
  lcd1.print("LCD 1: SOS Ready");
  lcd1.setCursor(0, 1);
  lcd1.print("Press button... ");

  // Initialize LCD 2 (Hazard Screen)
  lcd2.begin(16, 2);
  delay(50);
  lcd2.clear();
  lcd2.setCursor(0, 0);
  lcd2.print("Hazard Detected!");
  lcd2.setCursor(0, 1);
  lcd2.print("Save your self! ");
}

void loop() {
  // Continuously refresh both screens every 1 second so text never misses!
  static unsigned long lastRefresh = 0;
  if (millis() - lastRefresh > 1000) {
    lastRefresh = millis();

    // Refresh LCD 2 with "Save your self!"
    lcd2.setCursor(0, 0);
    lcd2.print("Hazard Detected!");
    lcd2.setCursor(0, 1);
    lcd2.print("Save your self! ");
  }

  // Listen for serial commands from ESP8266
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    line.trim();

    if (line.indexOf("SOS:1") >= 0) {
      lcd1.clear();
      lcd1.setCursor(0, 0);
      lcd1.print("Sending SOS");
      lcd1.setCursor(0, 1);
      lcd1.print("signal...       ");
    } else if (line.indexOf("SOS:0") >= 0) {
      lcd1.clear();
      lcd1.setCursor(0, 0);
      lcd1.print("LCD 1: SOS Ready");
      lcd1.setCursor(0, 1);
      lcd1.print("Press button... ");
    }
  }
}
