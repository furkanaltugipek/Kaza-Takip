import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/domain/entities/streak.dart';

class StreakBanner extends StatelessWidget {
  final Streak streak;
  const StreakBanner({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak.currentStreak == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${streak.currentStreak} günlük seri!',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.secondaryDark),
              ),
              Text(
                'En yüksek: ${streak.longestStreak} gün',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${streak.totalCompletedDays}',
            style: AppTextStyles.headlineLarge
                .copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
