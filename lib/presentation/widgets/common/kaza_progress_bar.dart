import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';

/// Animasyonlu ilerleme çubuğu — Dashboard özet kartında kullanılır.
class KazaProgressBar extends StatelessWidget {
  final double value;          // 0.0–1.0
  final int remainingCount;
  final int remainingRakats;

  const KazaProgressBar({
    super.key,
    required this.value,
    required this.remainingCount,
    required this.remainingRakats,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '%$percent Tamamlandı',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Kalan: ${_format(remainingCount)} vakit',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: value),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 12,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_format(remainingRakats)} rekat kaldı',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  static String _format(int n) {
    // Binlik ayracı: 24000 → 24.000
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
