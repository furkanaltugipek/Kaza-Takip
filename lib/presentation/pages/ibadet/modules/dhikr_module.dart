import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/data/datasources/local/ibadet_service.dart';

/// Bir zikir presetini temsil eder.
class _DhikrPreset {
  final String key;
  final String name;
  final String arabic;
  final int target;
  const _DhikrPreset(this.key, this.name, this.arabic, this.target);
}

const _presets = [
  _DhikrPreset('subhanallah', 'Sübhanallah', 'سُبْحَانَ اللّٰه', 33),
  _DhikrPreset('elhamdulillah', 'Elhamdülillah', 'اَلْحَمْدُ لِلّٰه', 33),
  _DhikrPreset('allahuekber', 'Allahu Ekber', 'اَللّٰهُ أَكْبَر', 34),
  _DhikrPreset('estagfirullah', 'Estağfirullah', 'أَسْتَغْفِرُ اللّٰه', 100),
  _DhikrPreset('lailaheillallah', 'Lâ ilâhe illallah', 'لَا إِلٰهَ إِلَّا اللّٰه', 100),
];

/// Zikirmatik — dokunarak sayan dijital tesbih.
class DhikrModule extends StatefulWidget {
  const DhikrModule({super.key});

  @override
  State<DhikrModule> createState() => _DhikrModuleState();
}

class _DhikrModuleState extends State<DhikrModule> {
  final IbadetService _svc = sl<IbadetService>();
  _DhikrPreset _selected = _presets.first;
  late int _count = _svc.dhikrCount(_selected.key);

  void _select(_DhikrPreset p) {
    setState(() {
      _selected = p;
      _count = _svc.dhikrCount(p.key);
    });
  }

  Future<void> _tap() async {
    final next = _count + 1;
    // Hedefe ulaşınca güçlü titreşim, her turda hafif.
    if (next % _selected.target == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    await _svc.setDhikrCount(_selected.key, next);
    setState(() => _count = next);
  }

  Future<void> _reset() async {
    await _svc.setDhikrCount(_selected.key, 0);
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final inSet = _selected.target == 0 ? 0 : _count % _selected.target;
    final completedSets =
        _selected.target == 0 ? 0 : _count ~/ _selected.target;
    final ratio = _selected.target == 0 ? 0.0 : inSet / _selected.target;

    return Column(
      children: [
        // Preset seçici
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _presets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = _presets[i];
              final sel = p.key == _selected.key;
              return ChoiceChip(
                label: Text(p.name),
                selected: sel,
                onSelected: (_) => _select(p),
                selectedColor: AppColors.primary,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: sel ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(_selected.arabic,
            style: const TextStyle(fontSize: 28, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text('Hedef: ${_selected.target} · Tamamlanan tur: $completedSets',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),

        // Büyük dokunmatik sayaç
        Expanded(
          child: GestureDetector(
            onTap: _tap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.secondary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Text(
                          '$inSet',
                          key: ValueKey(_count),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text('Toplam: $_count',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Saymak için dokun',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white54)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Sıfırla'),
              onPressed: _reset,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
