import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';

/// Günlük checklist öğesi — bir vakit için artır/azalt butonları içerir.
class DailyPrayerTile extends StatelessWidget {
  final String name;          // Türkçe vakit adı (Sabah, Öğle…)
  final String vakitKey;      // fajr | dhuhr | asr | maghrib | isha | witr
  final int completed;        // Bugün tamamlanan
  final int target;           // Günlük hedef
  final Color color;
  final ValueChanged<int> onChanged; // +1 veya -1

  const DailyPrayerTile({
    super.key,
    required this.name,
    required this.vakitKey,
    required this.completed,
    required this.target,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = completed >= target;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDone ? color.withOpacity(0.07) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? color.withOpacity(0.4) : AppColors.divider,
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Sol: Renk çizgisi + vakit adı
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDone ? color : null,
                          fontWeight:
                              isDone ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (isDone) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle,
                            size: 16, color: color),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completed / $target kaza',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            // Sağ: −/+ kontrolleri
            _CountControl(
              value: completed,
              max: target,
              color: color,
              onDecrement: completed > 0 ? () => onChanged(-1) : null,
              onIncrement: completed < target ? () => onChanged(1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountControl extends StatelessWidget {
  final int value;
  final int max;
  final Color color;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _CountControl({
    required this.value,
    required this.max,
    required this.color,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CtrlBtn(
          icon: Icons.remove,
          onTap: onDecrement,
          color: color,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: SizedBox(
            width: 32,
            key: ValueKey(value),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontSize: 20,
              ),
            ),
          ),
        ),
        _CtrlBtn(
          icon: Icons.add,
          onTap: onIncrement,
          color: color,
        ),
      ],
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _CtrlBtn({required this.icon, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.12) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? color : AppColors.divider,
        ),
      ),
    );
  }
}
