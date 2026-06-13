import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.errorText,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('tr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: errorText != null
                  ? Border.all(color: AppColors.error)
                  : null,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? AppDateUtils.toDisplay(value!)
                        : label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: value != null ? null : Colors.black38,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more, color: Colors.black38),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ],
    );
  }
}
