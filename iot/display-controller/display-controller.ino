/*
 * CampusSafe — Display Controller Firmware
 * Board: Arduino Uno R3
 *
 * Responsibilities:
 *   - Receive display commands from ESP8266 via Serial (UART RX)
 *   - Parse structured text commands
 *   - Update LCD 1 (I2C 0x27) with SOS push button status
 *   - Update LCD 2 (I2C 0x26) with sensor readings
 *   - Drive status LEDs for visual feedback
 *
 * Serial Protocol (ESP8266 TX → Arduino RX, 9600 baud):
 *   SOS:TRIGGERED:<timestamp>\n       → Update LCD 1 with SOS alert
 *   SENSOR:GAS:<reading>:ppm\n        → Update LCD 2 gas reading
 *   SENSOR:TEMP:<reading>:C\n          → Update LCD 2 temperature
 *   STATUS:READY\n                     → Reset LCD 1 to ready state
 *   STATUS:BOOTING\n                   → Show booting message
 *   ALERT:GAS\n                        → Flash LCD 2 gas alert
 *   ALERT:TEMP\n                       → Flash LCD 2 temp alert
 *
 * Wiring:
 *   ESP8266 TX (GPIO 1) → Arduino RX (pin 0)
 *   Common GND
 *   LCD 1 (SOS)    → I2C address 0x27 (SDA=A4, SCL=A5)
 *   LCD 2 (Sensor)  → I2C address 0x26 (SDA=A4, SCL=A5)
 *
 * NOTE: I2C addresses may vary by LCD module. Use an I2C scanner
 *       sketch to determine your actual addresses.
 *
 * Wokwi simulation validated.
 */

#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// ============================================================
// LCD CONFIGURATION
// ============================================================

// LCD 1: SOS Status Display
// NOTE: Adjust address if your module uses a different I2C address
#define LCD_1_ADDR  0x27
#define LCD_1_COLS  16
#define LCD_1_ROWS  2

// LCD 2: Sensor Data Display
// NOTE: Adjust address if your module uses a different I2C address
#define LCD_2_ADDR  0x26
#define LCD_2_COLS  16
#define LCD_2_ROWS  2

// ============================================================
// LED PIN DEFINITIONS
// ============================================================

#define SOS_LED_PIN     8     // Red LED — SOS status indicator
#define SENSOR_LED_PIN  9     // Yellow LED — Sensor alert indicator
#define READY_LED_PIN   10    // Green LED — System ready indicator

// ============================================================
// TIMING
// ============================================================

#define ALERT_FLASH_DURATION  3000    // 3 seconds flash on alert
#define SERIAL_BUFFER_SIZE    128     // Max command length

// ============================================================
// GLOBAL STATE
// ============================================================

LiquidCrystal_I2C lcd1(LCD_1_ADDR, LCD_1_COLS, LCD_1_ROWS);  // SOS display
LiquidCrystal_I2C lcd2(LCD_2_ADDR, LCD_2_COLS, LCD_2_ROWS);  // Sensor display

// Serial input buffer
char serialBuffer[SERIAL_BUFFER_SIZE];
int  bufferIndex = 0;

// SOS state
int  sosEventCount = 0;
bool sosActive     = false;

// Sensor state
int  lastGasReading   = 0;
int  lastTempReading  = 0;
bool gasAlertActive   = false;
bool tempAlertActive  = false;

// Alert flash timing
unsigned long alertFlashStart = 0;
bool alertFlashing = false;

// ============================================================
// SETUP
// ============================================================

void setup() {
  // Serial from ESP8266
  Serial.begin(9600);

  // LED pins
  pinMode(SOS_LED_PIN, OUTPUT);
  pinMode(SENSOR_LED_PIN, OUTPUT);
  pinMode(READY_LED_PIN, OUTPUT);

  // Initialize LCD 1 (SOS)
  lcd1.init();
  lcd1.backlight();
  lcd1.clear();
  lcd1.setCursor(0, 0);
  lcd1.print("  CampusSafe");
  lcd1.setCursor(0, 1);
  lcd1.print("SOS: Booting...");

  // Initialize LCD 2 (Sensor)
  lcd2.init();
  lcd2.backlight();
  lcd2.clear();
  lcd2.setCursor(0, 0);
  lcd2.print("  CampusSafe");
  lcd2.setCursor(0, 1);
  lcd2.print("Sensors: Init...");

  // Brief startup delay
  delay(1500);

  // Show ready state
  showReady();
  showSensorReady();

  // Ready LED on
  digitalWrite(READY_LED_PIN, HIGH);
}

// ============================================================
// MAIN LOOP
// ============================================================

void loop() {
  // Read serial data from ESP8266
  while (Serial.available() > 0) {
    char c = Serial.read();

    if (c == '\n' || c == '\r') {
      if (bufferIndex > 0) {
        serialBuffer[bufferIndex] = '\0';
        processCommand(String(serialBuffer));
        bufferIndex = 0;
      }
    } else if (bufferIndex < SERIAL_BUFFER_SIZE - 1) {
      serialBuffer[bufferIndex++] = c;
    }
  }

  // Handle alert flash timeout
  if (alertFlashing && (millis() - alertFlashStart >= ALERT_FLASH_DURATION)) {
    alertFlashing = false;
    digitalWrite(SENSOR_LED_PIN, LOW);
  }
}

// ============================================================
// COMMAND PROCESSOR
// ============================================================

void processCommand(String cmd) {
  cmd.trim();

  if (cmd.startsWith("SOS:")) {
    handleSOSCommand(cmd);
  } else if (cmd.startsWith("SENSOR:")) {
    handleSensorCommand(cmd);
  } else if (cmd.startsWith("STATUS:")) {
    handleStatusCommand(cmd);
  } else if (cmd.startsWith("ALERT:")) {
    handleAlertCommand(cmd);
  }
  // Ignore unknown commands (e.g. debug logs from ESP8266)
}

// ============================================================
// SOS COMMAND HANDLER
// ============================================================

void handleSOSCommand(String cmd) {
  // Format: SOS:TRIGGERED:<timestamp>
  int firstColon = cmd.indexOf(':');
  int secondColon = cmd.indexOf(':', firstColon + 1);

  String action = cmd.substring(firstColon + 1, secondColon);
  String timestamp = cmd.substring(secondColon + 1);

  if (action == "TRIGGERED") {
    sosEventCount++;
    sosActive = true;

    // Update LCD 1
    lcd1.clear();
    lcd1.setCursor(0, 0);
    lcd1.print("!! SOS ACTIVE !!");
    lcd1.setCursor(0, 1);
    lcd1.print("Events: ");
    lcd1.print(sosEventCount);

    // SOS LED on
    digitalWrite(SOS_LED_PIN, HIGH);
    digitalWrite(READY_LED_PIN, LOW);

    // Flash backlight for attention
    for (int i = 0; i < 3; i++) {
      lcd1.noBacklight();
      delay(150);
      lcd1.backlight();
      delay(150);
    }
  }
}

// ============================================================
// SENSOR COMMAND HANDLER
// ============================================================

void handleSensorCommand(String cmd) {
  // Format: SENSOR:GAS:<reading>:ppm
  // Format: SENSOR:TEMP:<reading>:C

  // Parse fields
  int firstColon  = cmd.indexOf(':');
  int secondColon = cmd.indexOf(':', firstColon + 1);
  int thirdColon  = cmd.indexOf(':', secondColon + 1);

  String sensorType = cmd.substring(firstColon + 1, secondColon);
  String reading    = cmd.substring(secondColon + 1, thirdColon);
  String unit       = cmd.substring(thirdColon + 1);

  if (sensorType == "GAS") {
    lastGasReading = reading.toInt();
    updateSensorDisplay();
  } else if (sensorType == "TEMP") {
    lastTempReading = reading.toInt();
    updateSensorDisplay();
  }
}

// ============================================================
// STATUS COMMAND HANDLER
// ============================================================

void handleStatusCommand(String cmd) {
  // Format: STATUS:READY or STATUS:BOOTING
  String status = cmd.substring(cmd.indexOf(':') + 1);

  if (status == "READY") {
    showReady();
    sosActive = false;
    digitalWrite(SOS_LED_PIN, LOW);
    digitalWrite(READY_LED_PIN, HIGH);
  } else if (status == "BOOTING") {
    lcd1.clear();
    lcd1.setCursor(0, 0);
    lcd1.print("  CampusSafe");
    lcd1.setCursor(0, 1);
    lcd1.print("Booting...");
  }
}

// ============================================================
// ALERT COMMAND HANDLER
// ============================================================

void handleAlertCommand(String cmd) {
  // Format: ALERT:GAS or ALERT:TEMP
  String alertType = cmd.substring(cmd.indexOf(':') + 1);

  // Flash sensor LED
  digitalWrite(SENSOR_LED_PIN, HIGH);
  alertFlashing = true;
  alertFlashStart = millis();

  // Update LCD 2 with alert
  lcd2.clear();
  lcd2.setCursor(0, 0);

  if (alertType == "GAS") {
    gasAlertActive = true;
    lcd2.print("!! GAS ALERT !!");
    lcd2.setCursor(0, 1);
    lcd2.print("Gas: ");
    lcd2.print(lastGasReading);
    lcd2.print(" ppm");
  } else if (alertType == "TEMP") {
    tempAlertActive = true;
    lcd2.print("!! HEAT ALERT !!");
    lcd2.setCursor(0, 1);
    lcd2.print("Temp: ");
    lcd2.print(lastTempReading);
    lcd2.print(" C");
  }

  // Flash LCD 2 backlight for attention
  for (int i = 0; i < 3; i++) {
    lcd2.noBacklight();
    delay(150);
    lcd2.backlight();
    delay(150);
  }
}

// ============================================================
// DISPLAY UPDATE FUNCTIONS
// ============================================================

void showReady() {
  lcd1.clear();
  lcd1.setCursor(0, 0);
  lcd1.print("SOS: READY");
  lcd1.setCursor(0, 1);
  lcd1.print("Events: ");
  lcd1.print(sosEventCount);
}

void showSensorReady() {
  lcd2.clear();
  lcd2.setCursor(0, 0);
  lcd2.print("Sensors: NORMAL");
  lcd2.setCursor(0, 1);
  lcd2.print("Waiting data...");
}

void updateSensorDisplay() {
  // Only update if no active alert is being shown
  if (!alertFlashing) {
    lcd2.clear();
    lcd2.setCursor(0, 0);
    lcd2.print("Gas:");
    lcd2.print(lastGasReading);
    lcd2.print("ppm ");

    // Show status indicator
    if (gasAlertActive) {
      lcd2.print("!!");
      gasAlertActive = false;
    }

    lcd2.setCursor(0, 1);
    lcd2.print("Temp:");
    lcd2.print(lastTempReading);
    lcd2.print("C ");

    if (tempAlertActive) {
      lcd2.print("!!");
      tempAlertActive = false;
    } else {
      lcd2.print("OK");
    }
  }
}
