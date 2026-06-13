import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand palette — deep teal & warm gold (Islamic aesthetic)
  static const Color primary = Color(0xFF1A6B5C);       // Deep teal
  static const Color primaryLight = Color(0xFF2E8B73);
  static const Color primaryDark = Color(0xFF0F4A3E);

  static const Color secondary = Color(0xFFC9972A);      // Warm gold
  static const Color secondaryLight = Color(0xFFE8BA55);
  static const Color secondaryDark = Color(0xFF9A7020);

  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF2F0);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);

  // Prayer-specific accent colors
  static const Color fajrColor = Color(0xFF5C6BC0);      // Deep blue — dawn
  static const Color dhuhrColor = Color(0xFF1565C0);     // Sky blue — noon
  static const Color asrColor = Color(0xFF0277BD);       // Ocean blue — afternoon
  static const Color maghribColor = Color(0xFFE65100);   // Sunset orange
  static const Color ishaColor = Color(0xFF283593);      // Night indigo
  static const Color witrColor = Color(0xFF6A1B9A);      // Purple — special

  static const Map<String, Color> prayerColors = {
    'fajr': fajrColor,
    'dhuhr': dhuhrColor,
    'asr': asrColor,
    'maghrib': maghribColor,
    'isha': ishaColor,
    'witr': witrColor,
  };

  // Contribution calendar (GitHub-style green scale)
  static const Color calendarEmpty = Color(0xFFEBEDF0);
  static const Color calendarL1 = Color(0xFF9BE9A8);
  static const Color calendarL2 = Color(0xFF40C463);
  static const Color calendarL3 = Color(0xFF30A14E);
  static const Color calendarL4 = Color(0xFF216E39);

  // Dark mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkPrimary = Color(0xFF4DB89E);
  static const Color darkSecondary = Color(0xFFE8BA55);
}
