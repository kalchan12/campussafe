#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal.h>
#include <LiquidCrystal_I2C.h>

// ===== LCD 1: Parallel (SOS Alert Station) =====
// Pins: RS->7, EN->8, D4->9, D5->10, D6->11, D7->12
LiquidCrystal lcd1(7, 8, 9, 10, 11, 12);

// ===== LCD 2: I2C Backpack (Hazard & Telemetry) =====
// Uses hardware SDA (A4) and SCL (A5)
// Try standard address 0x27 (fallback 0x21 if hardware variant)
LiquidCrystal_I2C lcd2(0x27, 16, 2);
LiquidCrystal_I2C lcd2_alt(0x21, 16, 2);

String lastSOS = "";
String lastHazard = "NORMAL";

void updateLCD1(String status) {
  if (status == lastSOS) return;
  lastSOS = status;

  lcd1.clear();
  if (status == "1") {
    lcd1.setCursor(0, 0);
    lcd1.print("Sending SOS");
    lcd1.setCursor(0, 1);
    lcd1.print("signal...");
  } else {
    lcd1.setCursor(0, 0);
    lcd1.print("SOS System Ready");
    lcd1.setCursor(0, 1);
    lcd1.print("Press button...");
  }
}

void updateLCD2Hazard(String hazard) {
  lastHazard = hazard;
  char buf[17];
  if (hazard == "GAS") {
    snprintf(buf, sizeof(buf), "Gas! Evacuate!  ");
  } else if (hazard == "HEAT") {
    snprintf(buf, sizeof(buf), "Heat! Evacuate! ");
  } else if (hazard == "BOTH") {
    snprintf(buf, sizeof(buf), "Gas&Heat! Flee! ");
  } else {
    snprintf(buf, sizeof(buf), "Status: Normal  ");
  }

  lcd2.setCursor(0, 1);
  lcd2.print(buf);
  lcd2_alt.setCursor(0, 1);
  lcd2_alt.print(buf);
}

void updateLCD2Data(String data) {
  // data format: "temp,gas" (e.g. "25.0,850")
  int commaIdx = data.indexOf(',');
  if (commaIdx != -1) {
    String tStr = data.substring(0, commaIdx);
    String gStr = data.substring(commaIdx + 1);

    char buf[17];
    snprintf(buf, sizeof(buf), "T:%sC G:%-4s", tStr.c_str(), gStr.c_str());
    
    lcd2.setCursor(0, 0);
    lcd2.print(buf);
    lcd2_alt.setCursor(0, 0);
    lcd2_alt.print(buf);
  }
}

void setup() {
  Serial.begin(115200);
  Wire.begin();
  delay(400);

  // Initialize LCD 1 (Parallel)
  lcd1.begin(16, 2);
  delay(50);
  lcd1.clear();
  updateLCD1("0");

  // Initialize LCD 2 (I2C) on both addresses
  lcd2.init();
  lcd2.backlight();
  lcd2.clear();
  lcd2.setCursor(0, 0);
  lcd2.print("T:--.-C G:---   ");
  lcd2.setCursor(0, 1);
  lcd2.print("Status: Normal  ");

  lcd2_alt.init();
  lcd2_alt.backlight();
  lcd2_alt.clear();
  lcd2_alt.setCursor(0, 0);
  lcd2_alt.print("T:--.-C G:---   ");
  lcd2_alt.setCursor(0, 1);
  lcd2_alt.print("Status: Normal  ");
}

void loop() {
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    line.trim();

    if (line.startsWith("SOS:")) {
      String val = line.substring(4);
      updateLCD1(val);
    } else if (line.startsWith("HAZARD:")) {
      String val = line.substring(7);
      updateLCD2Hazard(val);
    } else if (line.startsWith("DATA:")) {
      String val = line.substring(5);
      updateLCD2Data(val);
    }
  }
}
