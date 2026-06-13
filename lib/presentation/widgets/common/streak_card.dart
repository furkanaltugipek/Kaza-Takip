import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';

/// "İstikrar Ateşi" streak kartı.
class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalCompleted;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          // Ateş ikonu + seri sayısı
          Column(
            children: [
              Text(
                currentStreak > 0 ? '🔥' : '✨',
                style: const TextStyle(fontSize: 28),
              ),
              Text(
                '$currentStreak',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.secondaryDark,
                  height: 1,
                ),
              ),
              Text('gün', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(width: 16),
          const VerticalDivider(
            width: 1,
            color: AppColors.divider,
            indent: 4,
            endIndent: 4,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İstikrar Ateşi',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.secondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'En yüksek: $longestStreak gün',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalCompleted',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text('toplam gün', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
