import 'package:flutter/material.dart';

/// Neo-Ottoman Minimalist palet — kremsi kağıt + İmparatorluk Yeşili + mat altın.
///
/// Eski isimler korunur ama yeni renklere işaret eder; bu sayede mevcut kod
/// kırılmadan tüm görsel kimlik tek noktadan güncellenir.
class AppColors {
  AppColors._();

  // ── Yeni Neo-Ottoman palet ────────────────────────────────────────────────
  /// Mat krem kağıt — premium geleneksel kağıt / açık mermer hissi.
  static const Color paper = Color(0xFFFDFBF7);

  /// İmparatorluk yeşili — Osmanlı sarayı yeşili (deep accent).
  static const Color imperial = Color(0xFF113C22);
  static const Color imperialLight = Color(0xFF1E5A36);
  static const Color imperialDark = Color(0xFF0A2613);

  /// Mat altın — kenarlık, aktif durum ve ödül vurguları.
  static const Color matteGold = Color(0xFFC5A059);
  static const Color matteGoldLight = Color(0xFFD8BC83);
  static const Color matteGoldDark = Color(0xFF8B7037);

  /// Krem konteyner (kart iç yüzeyi, hafif renkli arka plan).
  static const Color cream = Color(0xFFF7F2E8);
  static const Color creamDeep = Color(0xFFEDE4D0);

  // ── Eski isimler → yeni paletten ────────────────────────────────────────────
  static const Color primary = imperial;
  static const Color primaryLight = imperialLight;
  static const Color primaryDark = imperialDark;
  static const Color primaryContainer = cream;

  static const Color secondary = matteGold;
  static const Color secondaryLight = matteGoldLight;
  static const Color secondaryDark = matteGoldDark;
  static const Color secondaryContainer = Color(0xFFFAF0D6);

  static const Color background = paper;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = cream;
  static const Color divider = Color(0xFFE3DCC8);

  // ── Durum renkleri ──────────────────────────────────────────────────────────
  static const Color error = Color(0xFF8E2B1C);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB8862C);
  static const Color info = Color(0xFF1565C0);

  // ── Namaz vakti aksanları (yeni palete uyumlu derin tonlar) ────────────────
  static const Color fajrColor = Color(0xFF1A2E5C);
  static const Color dhuhrColor = Color(0xFF1E5A4F);
  static const Color asrColor = Color(0xFF255A6F);
  static const Color maghribColor = Color(0xFF7C3A1A);
  static const Color ishaColor = Color(0xFF0F2247);
  static const Color witrColor = Color(0xFF4A1F5C);

  static const Map<String, Color> prayerColors = {
    'fajr': fajrColor,
    'dhuhr': dhuhrColor,
    'asr': asrColor,
    'maghrib': maghribColor,
    'isha': ishaColor,
    'witr': witrColor,
  };

  // ── Katkı takvimi (GitHub tarzı) — altın skalasıyla yeniden yorumlandı ────
  static const Color calendarEmpty = Color(0xFFEFE9D7);
  static const Color calendarL1 = Color(0xFFD4C7A0);
  static const Color calendarL2 = Color(0xFF9CB58F);
  static const Color calendarL3 = Color(0xFF477054);
  static const Color calendarL4 = imperial;

  // ── Karanlık tema ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A1A11);
  static const Color darkSurface = Color(0xFF132516);
  static const Color darkSurfaceVariant = Color(0xFF1C2F1F);
  static const Color darkPrimary = Color(0xFF6FA37D);
  static const Color darkSecondary = matteGoldLight;
}
