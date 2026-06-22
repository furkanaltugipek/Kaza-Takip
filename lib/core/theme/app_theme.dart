import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Neo-Ottoman Minimalist tema — krem kağıt zemin, imparatorluk yeşili,
/// mat altın aksanlar; serif başlık + sans gövde.
class AppTheme {
  AppTheme._();

  // Kart kenarı standart yarıçapı.
  static const double _cardRadius = 18;
  static const double _buttonRadius = 14;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.imperial,
          onPrimary: Colors.white,
          primaryContainer: AppColors.cream,
          onPrimaryContainer: AppColors.imperialDark,
          secondary: AppColors.matteGold,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.matteGoldDark,
          surface: AppColors.surface,
          onSurface: Color(0xFF1A1A1A),
          surfaceContainerHighest: AppColors.cream,
          outline: AppColors.matteGold,
          outlineVariant: AppColors.divider,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.paper,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.imperial,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.imperial,
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
              side: const BorderSide(color: AppColors.matteGold, width: 1),
            ),
            textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.imperial,
            side: const BorderSide(color: AppColors.matteGold, width: 1.2),
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.imperial,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        // Klasik çerçeveli input görünümü — emerald yazı + altın aktif çerçeve.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
            borderSide: const BorderSide(color: AppColors.matteGold, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          labelStyle: AppTextStyles.bodyMedium
              .copyWith(color: const Color(0xFF666560)),
          floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.imperial,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: const Color(0xFF999999)),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.imperial : null),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.cream,
          selectedColor: AppColors.imperial,
          labelStyle: AppTextStyles.bodySmall,
          secondaryLabelStyle:
              AppTextStyles.bodySmall.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.matteGold, width: 0.8),
          ),
          side: const BorderSide(color: AppColors.matteGold, width: 0.8),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.matteGold,
          linearTrackColor: AppColors.cream,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.imperial,
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.matteGold, width: 0.8),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.paper,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.matteGold, width: 0.8),
          ),
          titleTextStyle: AppTextStyles.headlineMedium,
          contentTextStyle: AppTextStyles.bodyMedium,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          onPrimary: Color(0xFF0A1A11),
          primaryContainer: AppColors.imperialDark,
          onPrimaryContainer: AppColors.cream,
          secondary: AppColors.matteGoldLight,
          onSecondary: Color(0xFF1A1A1A),
          secondaryContainer: AppColors.matteGoldDark,
          onSecondaryContainer: AppColors.secondaryContainer,
          surface: AppColors.darkSurface,
          onSurface: Color(0xFFEAE2C9),
          error: Color(0xFFCF6679),
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
            side: const BorderSide(color: AppColors.darkSurfaceVariant),
          ),
        ),
      );
}
