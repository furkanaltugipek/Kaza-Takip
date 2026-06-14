import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';

/// Bitiş tarihi simülatörü — günlük hedefe göre canlı tahmin.
class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  // Günde toplam kaç vakit kaza kılınacak (tüm vakitler dahil).
  double _dailyTarget = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bitiş Simülatörü')),
      body: BlocBuilder<KazaBloc, KazaState>(
        builder: (context, state) {
          if (state is! KazaLoaded || state.metrics.totalDebtCount == 0) {
            return const _EmptyView();
          }

          final remaining = state.metrics.totalRemaining;
          final target = _dailyTarget.round();

          // Canlı formül: Kalan Gün = Toplam Kalan Vakit / Günlük Hedef
          final remainingDays =
              target > 0 ? (remaining / target).ceil() : 0;
          final finishDate =
              DateTime.now().add(Duration(days: remainingDays));

          // Karşılaştırma: mevcut moda (vakit başına hedef × 6 vakit) göre.
          final defaultDaily = state.dailyTargetPerVakit * 6;
          final defaultDays = defaultDaily > 0
              ? (remaining / defaultDaily).ceil()
              : remainingDays;
          final daysSaved = defaultDays - remainingDays;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ResultCard(
                finishDate: finishDate,
                remainingDays: remainingDays,
                remaining: remaining,
              ),
              const SizedBox(height: 28),
              Text('Günlük Hedef', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Günde toplam $target vakit kaza kılarsanız:',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('1', style: AppTextStyles.bodySmall),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.15),
                        valueIndicatorColor: AppColors.primary,
                      ),
                      child: Slider(
                        value: _dailyTarget,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$target vakit',
                        onChanged: (v) =>
                            setState(() => _dailyTarget = v),
                      ),
                    ),
                  ),
                  Text('30', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              _PresetChips(
                selected: target,
                onSelect: (v) =>
                    setState(() => _dailyTarget = v.toDouble()),
              ),
              const SizedBox(height: 24),
              if (daysSaved > 0)
                _EncouragementBanner(daysSaved: daysSaved)
              else if (daysSaved < 0)
                _SlowerBanner(daysSlower: -daysSaved),
            ],
          );
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final DateTime finishDate;
  final int remainingDays;
  final int remaining;
  const _ResultCard({
    required this.finishDate,
    required this.remainingDays,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final years = remainingDays ~/ 365;
    final months = (remainingDays % 365) ~/ 30;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Text('Tahminî Bitiş Tarihi',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            AppDateUtils.toDisplay(finishDate),
            style: AppTextStyles.displayMedium
                .copyWith(color: Colors.white, fontSize: 30),
          ),
          const SizedBox(height: 4),
          Text(
            years > 0
                ? '~$years yıl $months ay'
                : (months > 0 ? '~$months ay' : '$remainingDays gün'),
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryLight),
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: '$remainingDays', label: 'Gün'),
              _Stat(value: '$remaining', label: 'Kalan Vakit'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.displayMedium
                .copyWith(color: Colors.white, fontSize: 24)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white60)),
      ],
    );
  }
}

class _PresetChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _PresetChips({required this.selected, required this.onSelect});

  static const _presets = [1, 2, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _presets.map((p) {
        final isSel = selected == p;
        return ChoiceChip(
          label: Text('$p vakit'),
          selected: isSel,
          onSelected: (_) => onSelect(p),
          selectedColor: AppColors.primary,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: isSel ? Colors.white : null,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}

class _EncouragementBanner extends StatelessWidget {
  final int daysSaved;
  const _EncouragementBanner({required this.daysSaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu tempoyla mevcut planınızdan $daysSaved gün daha erken '
              'bitireceksiniz! Maşallah, kararlılığınız harika.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlowerBanner extends StatelessWidget {
  final int daysSlower;
  const _SlowerBanner({required this.daysSlower});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu tempo mevcut planınızdan $daysSlower gün daha uzun sürer. '
              'Hedefi biraz artırmayı deneyin.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.show_chart, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Önce kaza borcu hesabı yapın.',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
