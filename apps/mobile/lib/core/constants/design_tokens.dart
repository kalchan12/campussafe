import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Font Families
  static const String geist = 'Geist';
  static const String inter = 'Inter';
  static const String jetbrainsMono = 'JetBrainsMono';

  // Display Large (Mobile) - Geist 32px/38px, weight 700, letter-spacing -0.02em
  static const TextStyle displayLgMobile = TextStyle(
    fontFamily: geist,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 32,
    letterSpacing: -0.02,
  );

  // Display Large (Desktop) - Geist 40px/48px, weight 700, letter-spacing -0.02em
  static const TextStyle displayLg = TextStyle(
    fontFamily: geist,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.02,
  );

  // Headline Medium - Geist 24px/32px, weight 600
  static const TextStyle headlineMd = TextStyle(
    fontFamily: geist,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  // Body Large - Inter 18px/28px, weight 400
  static const TextStyle bodyLg = TextStyle(
    fontFamily: inter,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  // Body Medium - Inter 16px/24px, weight 400
  static const TextStyle bodyMd = TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  // Label Medium - Inter 14px/20px, weight 500, letter-spacing 0.01em
  static const TextStyle labelMd = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  // Technical Small - JetBrains Mono 13px/16px, weight 400
  static const TextStyle technicalSm = TextStyle(
    fontFamily: jetbrainsMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 16 / 13,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double unit = 8.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double containerMargin = 20.0;
  static const double gutter = 16.0;
  static const double safeAreaBottom = 20.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double defaultRadius = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

class AppShadows {
  AppShadows._();

  static const BoxShadow sosShadow = BoxShadow(
    color: Color(0x4CCD1A1A),
    blurRadius: 32,
    spreadRadius: 0,
    offset: Offset(0, 8),
  );

  static const BoxShadow navBarShadow = BoxShadow(
    color: Color(0x141A237E),
    blurRadius: 20,
    spreadRadius: 0,
    offset: Offset(0, -4),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x141A237E),
    blurRadius: 20,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );

  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x141A237E),
    blurRadius: 8,
    spreadRadius: 0,
    offset: Offset(0, 2),
  );
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration sosHold = Duration(seconds: 3);
  static const Duration sosProgressUpdate = Duration(milliseconds: 50);
}