import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';

/// Kıble Pusulası sayfası — yakında eklenecek.
class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text('Kıble Pusulası', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 12),
          Text(
            'Bu özellik yakında eklenecek.\nKonumunuza göre kıble yönünü gösterecek.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: const Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
