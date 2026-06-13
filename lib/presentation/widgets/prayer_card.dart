import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';

class PrayerCard extends StatelessWidget {
  final String prayerName;
  final String prayerKey;
  final List<PrayerSlot> slots;
  final Color color;
  final ValueChanged<String> onSlotTap;

  const PrayerCard({
    super.key,
    required this.prayerName,
    required this.prayerKey,
    required this.slots,
    required this.color,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = slots.every((s) => s.isCompleted);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: allDone ? color.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Prayer label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prayerName,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: color)),
                  Text('${slots.length} kaza',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            // Slot checkboxes
            Row(
              children: slots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: slot.isCompleted
                        ? null
                        : () => onSlotTap(slot.slotId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: slot.isCompleted
                            ? color
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: slot.isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : Text(
                                '${slot.kazaIndex}',
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: color),
                              ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
