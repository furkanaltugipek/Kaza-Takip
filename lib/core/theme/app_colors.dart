import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Ana palet (Adım 4 spec'i: #1E4D2B koyu yeşil + #D4AF37 altın) ──────────
  static const Color primary = Color(0xFF1E4D2B);
  static const Color primaryLight = Color(0xFF2E7D42);
  static const Color primaryDark = Color(0xFF0F2E18);
  static const Color primaryContainer = Color(0xFFD6ECD9);

  static const Color secondary = Color(0xFFD4AF37);       // Altın
  static const Color secondaryLight = Color(0xFFE8CA5A);
  static const Color secondaryDark = Color(0xFF9A7D1A);
  static const Color secondaryContainer = Color(0xFFFFF8E1);

  // ── Arka plan & yüzey ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);      // spec: #F8F9FA
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFF3F0);
  static const Color divider = Color(0xFFE0E6E2);

  // ── Durum renkleri ───────────────────────────────────────────────────────────
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1565C0);

  // ── Namaz vakti aksanları ────────────────────────────────────────────────────
  static const Color fajrColor = Color(0xFF3949AB);       // Şafak moru-mavisi
  static const Color dhuhrColor = Color(0xFF00838F);      // Öğle camgöbeği
  static const Color asrColor = Color(0xFF0277BD);        // İkindi okyanusmavis
  static const Color maghribColor = Color(0xFFBF360C);    // Akşam turuncu-kırmızı
  static const Color ishaColor = Color(0xFF1A237E);       // Yatsı lacivert
  static const Color witrColor = Color(0xFF4A148C);       // Vitir mor

  static const Map<String, Color> prayerColors = {
    'fajr': fajrColor,
    'dhuhr': dhuhrColor,
    'asr': asrColor,
    'maghrib': maghribColor,
    'isha': ishaColor,
    'witr': witrColor,
  };

  // ── Katkı takvimi (GitHub tarzı yeşil skalası) ───────────────────────────────
  static const Color calendarEmpty = Color(0xFFEBEDF0);
  static const Color calendarL1 = Color(0xFFA8D5A2);
  static const Color calendarL2 = Color(0xFF5DAB5D);
  static const Color calendarL3 = Color(0xFF2E7D42);
  static const Color calendarL4 = Color(0xFF1E4D2B);

  // ── Karanlık tema ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF101C13);
  static const Color darkSurface = Color(0xFF1A2E1D);
  static const Color darkSurfaceVariant = Color(0xFF243528);
  static const Color darkPrimary = Color(0xFF5DAB5D);
  static const Color darkSecondary = Color(0xFFE8CA5A);
}
