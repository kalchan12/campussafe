import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Material 3 Color Scheme - Light (from DESIGN.md)
  static const Color surface = Color(0xFFFBF9F9);
  static const Color surfaceDim = Color(0xFFDBDAD9);
  static const Color surfaceBright = Color(0xFFFBF9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E7);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E2);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color inverseSurface = Color(0xFF303031);
  static const Color inverseOnSurface = Color(0xFFF2F0F0);
  static const Color outline = Color(0xFF767683);
  static const Color outlineVariant = Color(0xFFC6C5D4);
  static const Color surfaceTint = Color(0xFF4C56AF);

  // Primary (Indigo) - DESIGN.md: #000666
  static const Color primary = Color(0xFF000666);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1A237E);
  static const Color onPrimaryContainer = Color(0xFF8690EE);
  static const Color inversePrimary = Color(0xFFBDC2FF);
  static const Color primaryFixed = Color(0xFFE0E0FF);
  static const Color primaryFixedDim = Color(0xFFBDC2FF);
  static const Color onPrimaryFixed = Color(0xFF000767);
  static const Color onPrimaryFixedVariant = Color(0xFF343D96);

  // Secondary (Blue) - DESIGN.md: #005FAF
  static const Color secondary = Color(0xFF005FAF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF54A0FE);
  static const Color onSecondaryContainer = Color(0xFF003567);
  static const Color secondaryFixed = Color(0xFFD4E3FF);
  static const Color secondaryFixedDim = Color(0xFFA5C8FF);
  static const Color onSecondaryFixed = Color(0xFF001C3A);
  static const Color onSecondaryFixedVariant = Color(0xFF004786);

  // Tertiary (Red/Brown) - DESIGN.md: #380B00
  static const Color tertiary = Color(0xFF380B00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF5C1800);
  static const Color onTertiaryContainer = Color(0xFFE17C5A);
  static const Color tertiaryFixed = Color(0xFFFFDBD0);
  static const Color tertiaryFixedDim = Color(0xFFFFB59D);
  static const Color onTertiaryFixed = Color(0xFF390C00);
  static const Color onTertiaryFixedVariant = Color(0xFF7B2E12);

  // Error (Red) - DESIGN.md: #BA1A1A
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Background
  static const Color background = Color(0xFFFBF9F9);
  static const Color onBackground = Color(0xFF1B1C1C);
  static const Color surfaceVariant = Color(0xFFE3E2E2);

  // Semantic - Critical (Red)
  static const Color critical = Color(0xFFBA1A1A);
  static const Color criticalContainer = Color(0xFFFFDAD6);
  static const Color onCriticalContainer = Color(0xFF93000A);

  // Semantic - Warning (Amber)
  static const Color warning = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFFE65100);

  // Semantic - Success (Green)
  static const Color success = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Semantic - Information (Blue)
  static const Color information = Color(0xFF1976D2);
  static const Color informationContainer = Color(0xFFE3F2FD);
  static const Color onInformationContainer = Color(0xFF0D47A1);

  // Semantic - Inactive (Gray)
  static const Color inactive = Color(0xFF9E9E9E);
  static const Color inactiveLight = Color(0xFFBDBDBD);
  static const Color inactiveContainer = Color(0xFFF5F5F5);
  static const Color onInactiveContainer = Color(0xFF616161);

  // SOS Emergency
  static const Color sosRed = Color(0xFFBA1A1A);
  static const Color sosRedDark = Color(0xFF93000A);

  // Status Colors (matching semantic colors)
  static const Color statusCreated = Color(0xFF9E9E9E);
  static const Color statusReceived = Color(0xFF1976D2);
  static const Color statusAssigned = Color(0xFFAB47BC);
  static const Color statusResponding = Color(0xFFF57C00);
  static const Color statusArrived = Color(0xFF26A69A);
  static const Color statusResolved = Color(0xFF388E3C);
  static const Color statusCancelled = Color(0xFF9E9E9E);
  static const Color statusFailed = Color(0xFFBA1A1A);
  static const Color statusEscalated = Color(0xFFF57C00);
  static const Color statusUnassigned = Color(0xFF9E9E9E);
}
