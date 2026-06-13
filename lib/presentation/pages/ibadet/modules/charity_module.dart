import 'package:flutter/material.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/data/datasources/local/ibadet_service.dart';

/// Sadaka Hedefleri — iyilik ve verme kayıtları.
class CharityModule extends StatefulWidget {
  const CharityModule({super.key});

  @override
  State<CharityModule> createState() => _CharityModuleState();
}

class _CharityModuleState extends State<CharityModule> {
  final IbadetService _svc = sl<IbadetService>();
  late List<String> _entries = _svc.charityLog;

  // Hızlı sadaka önerileri
  static const _suggestions = [
    'Sadaka verdim',
    'Yemek ikram ettim',
    'Yardım ettim',
    'Güler yüz gösterdim',
    'Selam verdim',
  ];

  Future<void> _add(String desc) async {
    final entry = '${AppDateUtils.toStorage(DateTime.now())}|$desc';
    await _svc.addCharity(entry);
    setState(() => _entries = _svc.charityLog);
  }

  Future<void> _remove(int i) async {
    await _svc.removeCharity(i);
    setState(() => _entries = _svc.charityLog);
  }

  void _showAddSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İyilik Ekle', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ne yaptınız?',
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  _add(v.trim());
                  Navigator.pop(ctx);
                }
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _suggestions
                  .map((s) => ActionChip(
                        label: Text(s),
                        onPressed: () {
                          _add(s);
                          Navigator.pop(ctx);
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bu haftaki sayısı
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final thisWeek = _entries.where((e) {
      final datePart = e.split('|').first;
      final date = DateTime.tryParse(datePart);
      return date != null && date.isAfter(weekAgo);
    }).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('İyilik Ekle'),
        onPressed: _showAddSheet,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Haftalık özet
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🤲', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$thisWeek',
                        style: AppTextStyles.displayMedium
                            .copyWith(color: AppColors.secondaryDark)),
                    Text('Bu hafta yapılan iyilik',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Geçmiş', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Henüz kayıt yok.\nİlk iyiliğinizi ekleyin.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._entries.asMap().entries.map((e) {
              final parts = e.value.split('|');
              final date = parts.first;
              final desc = parts.length > 1 ? parts[1] : parts.first;
              return Dismissible(
                key: ValueKey('${e.key}_${e.value}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _remove(e.key),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volunteer_activism,
                          color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(desc,
                              style: AppTextStyles.bodyMedium)),
                      Text(date, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
