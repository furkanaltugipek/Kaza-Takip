import 'package:flutter/material.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/data/datasources/local/ibadet_service.dart';

/// Hatim Takibi — cüz / sayfa bazlı ilerleme.
class HatimModule extends StatefulWidget {
  const HatimModule({super.key});

  @override
  State<HatimModule> createState() => _HatimModuleState();
}

class _HatimModuleState extends State<HatimModule> {
  final IbadetService _svc = sl<IbadetService>();
  static const int totalPages = IbadetService.totalQuranPages; // 604
  static const int pagesPerJuz = 20; // ~20 sayfa/cüz

  late int _page = _svc.hatimCurrentPage;
  late int _hatimCount = _svc.hatimCompletedCount;

  Future<void> _setPage(int p) async {
    final value = p.clamp(0, totalPages);
    await _svc.setHatimPage(value);
    setState(() => _page = value);
  }

  Future<void> _completeHatim() async {
    await _svc.incrementHatimCount();
    await _svc.setHatimPage(0);
    setState(() {
      _hatimCount = _svc.hatimCompletedCount;
      _page = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatim tamamlandı! Allah kabul etsin. 🤲'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final juz = (_page / pagesPerJuz).floor();
    final ratio = _page / totalPages;
    final percent = (ratio * 100).toStringAsFixed(1);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // İlerleme kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('%$percent', style: AppTextStyles.displayMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$_hatimCount. Hatim',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0, end: ratio),
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 14,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Info(label: 'Cüz', value: '$juz / 30'),
                  _Info(label: 'Sayfa', value: '$_page / $totalPages'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Sayfa kontrolü
        Text('Okunan Sayfa', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _StepBtn(label: '-10', onTap: () => _setPage(_page - 10)),
            _StepBtn(label: '-1', onTap: () => _setPage(_page - 1)),
            Expanded(
              child: Center(
                child: Text('$_page',
                    style: AppTextStyles.displayMedium
                        .copyWith(color: AppColors.primary)),
              ),
            ),
            _StepBtn(label: '+1', onTap: () => _setPage(_page + 1)),
            _StepBtn(label: '+10', onTap: () => _setPage(_page + 10)),
          ],
        ),
        const SizedBox(height: 12),
        // Hızlı cüz atlama
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(6, (i) {
            final targetJuz = (i + 1) * 5;
            return ActionChip(
              label: Text('$targetJuz. Cüz'),
              onPressed: () => _setPage(targetJuz * pagesPerJuz),
            );
          }),
        ),
        const SizedBox(height: 24),
        if (_page >= totalPages)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.celebration_outlined),
              label: const Text('Hatmi Tamamla'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary),
              onPressed: _completeHatim,
            ),
          ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.titleLarge
                .copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StepBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 48,
        height: 44,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.primary,
          ),
          onPressed: onTap,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
      ),
    );
  }
}
