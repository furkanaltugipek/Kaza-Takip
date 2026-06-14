import 'package:flutter/material.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/data/datasources/local/ibadet_service.dart';

/// Oruç Kazası takibi — kaçırılan Ramazan oruçları için sayaç.
class FastingModule extends StatefulWidget {
  const FastingModule({super.key});

  @override
  State<FastingModule> createState() => _FastingModuleState();
}

class _FastingModuleState extends State<FastingModule> {
  final IbadetService _svc = sl<IbadetService>();

  late int _debt = _svc.fastingDebt;
  late int _completed = _svc.fastingCompleted;

  Future<void> _setDebt(int v) async {
    final value = v.clamp(0, 9999);
    await _svc.setFastingDebt(value);
    if (_completed > value) await _svc.setFastingCompleted(value);
    setState(() {
      _debt = value;
      _completed = _svc.fastingCompleted;
    });
  }

  Future<void> _change(int delta) async {
    final value = (_completed + delta).clamp(0, _debt);
    await _svc.setFastingCompleted(value);
    setState(() => _completed = value);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_debt - _completed).clamp(0, 9999);
    final ratio = _debt == 0 ? 0.0 : _completed / _debt;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Borç ayarı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Toplam Kaza Orucu',
                        style: AppTextStyles.titleMedium),
                    Text('Kaçırılan toplam Ramazan orucu',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
                onPressed: () => _setDebt(_debt - 1),
              ),
              Text('$_debt', style: AppTextStyles.headlineMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                onPressed: () => _setDebt(_debt + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // İlerleme dairesi
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 10,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.secondary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$remaining',
                            style: AppTextStyles.displayLarge
                                .copyWith(color: Colors.white)),
                        Text('kalan',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('$_completed / $_debt tamamlandı',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Artır/azalt
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Geri Al'),
                onPressed: _completed > 0 ? () => _change(-1) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Oruç Tuttum'),
                onPressed: remaining > 0 ? () => _change(1) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
