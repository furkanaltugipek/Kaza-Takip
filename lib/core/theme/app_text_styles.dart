import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Neo-Ottoman tipografi:
///   • Başlıklar — Cormorant Garamond (klasik el yazması serif)
///   • Gövde & sayılar — Inter (modern sans-serif, yüksek okunabilirlik)
///
/// GoogleFonts fontları runtime'da indirip cache'ler; ek bundle gerekmez.
class AppTextStyles {
  AppTextStyles._();

  // ── Klasik serif (başlıklar) ──────────────────────────────────────────────

  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.imperial,
        letterSpacing: -0.5,
        height: 1.15,
      );

  static TextStyle get displayMedium => GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.imperial,
        height: 1.2,
      );

  static TextStyle get headlineLarge => GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.imperial,
        height: 1.25,
      );

  static TextStyle get headlineMedium => GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.imperial,
        height: 1.3,
      );

  // ── Sans-serif (gövde, sayılar, etiketler) ────────────────────────────────

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.imperial,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A2A1F),
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF2A2A2A),
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF2A2A2A),
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF666560),
        height: 1.45,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.imperial,
      );

  // ── Sayısal / tabular figürler (geri sayım, vakit saatleri) ───────────────

  static TextStyle get countdown => GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.imperial,
        letterSpacing: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get prayerCount => GoogleFonts.cormorantGaramond(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: AppColors.imperial,
      );

  static TextStyle get prayerLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.imperial,
      );

  /// Saat dizilimleri için tabular sayılar (HH:mm).
  static TextStyle get timeNumeric => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.imperial,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
