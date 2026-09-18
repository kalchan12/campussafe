/*
 * Dual LCD Test:
 *   - LCD 1: Parallel (Pins 7, 8, 9, 10, 11, 12) -> SOS Alert Display
 *   - LCD 2: I2C (Address 0x27 or 0x21 on SDA A4, SCL A5) -> Hazard & Telemetry Display
 */
#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal.h>
#include <LiquidCrystal_I2C.h>

// LCD 1: Parallel
LiquidCrystal lcd1(7, 8, 9, 10, 11, 12);

// LCD 2: I2C (Address 0x27 is standard, some use 0x21)
LiquidCrystal_I2C lcd2_27(0x27, 16, 2);
LiquidCrystal_I2C lcd2_21(0x21, 16, 2);

void setup() {
  Serial.begin(115200);
  Wire.begin();
  delay(400);

  // Initialize LCD 1 (Parallel)
  lcd1.begin(16, 2);
  lcd1.clear();
  lcd1.setCursor(0, 0);
  lcd1.print("LCD 1: SOS Ready");
  lcd1.setCursor(0, 1);
  lcd1.print("Press button... ");

  // Initialize LCD 2 on both possible I2C addresses
  lcd2_27.init();
  lcd2_27.backlight();
  lcd2_27.clear();
  lcd2_27.setCursor(0, 0);
  lcd2_27.print("T:25.0C G:5     ");
  lcd2_27.setCursor(0, 1);
  lcd2_27.print("Status: NORMAL  ");

  lcd2_21.init();
  lcd2_21.backlight();
  lcd2_21.clear();
  lcd2_21.setCursor(0, 0);
  lcd2_21.print("T:25.0C G:5     ");
  lcd2_21.setCursor(0, 1);
  lcd2_21.print("Status: NORMAL  ");
}

void loop() {
  delay(1000);
}
