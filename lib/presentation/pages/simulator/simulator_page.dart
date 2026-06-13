import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:kaza_takip/presentation/bloc/simulator/simulator_bloc.dart';

class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (prev, curr) => prev.kazaDebt != curr.kazaDebt,
      listener: (context, dashState) {
        if (dashState.kazaDebt != null) {
          context
              .read<SimulatorBloc>()
              .add(SimulatorDebtUpdated(dashState.kazaDebt!));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Bitiş Tarihi Simülatörü')),
        body: BlocBuilder<SimulatorBloc, SimulatorState>(
          builder: (context, state) {
            if (state.kazaDebt == null) {
              return const Center(
                child: Text(
                    'Önce kaza borcu hesabı yapın.',
                    style: AppTextStyles.bodyMedium),
              );
            }

            final totalRemaining = state.kazaDebt!.totalRemaining;
            final daysToFinish = state.dailyTarget > 0
                ? (totalRemaining / (state.dailyTarget * 6)).ceil()
                : 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultCard(
                    daysToFinish: daysToFinish,
                    completionDate: state.estimatedCompletionDate,
                    totalRemaining: totalRemaining,
                  ),
                  const SizedBox(height: 32),
                  Text('Günlük Hedef (her vakit için)',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Her vakit namazı için günde ${state.dailyTarget} kaza',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('1', style: AppTextStyles.bodySmall),
                      Expanded(
                        child: Slider(
                          value: state.dailyTarget.toDouble(),
                          min: 1,
                          max: 20,
                          divisions: 19,
                          activeColor: AppColors.primary,
                          label: '${state.dailyTarget}',
                          onChanged: (v) => context
                              .read<SimulatorBloc>()
                              .add(SimulatorDailyTargetChanged(v.round())),
                        ),
                      ),
                      Text('20', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _ModeComparison(debt: state.kazaDebt!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int daysToFinish;
  final DateTime? completionDate;
  final int totalRemaining;
  const _ResultCard(
      {required this.daysToFinish,
      this.completionDate,
      required this.totalRemaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            completionDate != null
                ? AppDateUtils.toDisplay(completionDate!)
                : '—',
            style: AppTextStyles.displayLarge
                .copyWith(color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text('Tahmini Bitiş',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white70)),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'Kalan Namaz', value: '$totalRemaining'),
              _Stat(label: 'Kalan Gün', value: '$daysToFinish'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.displayMedium
                .copyWith(color: Colors.white, fontSize: 22)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _ModeComparison extends StatelessWidget {
  final dynamic debt;
  const _ModeComparison({required this.debt});

  @override
  Widget build(BuildContext context) {
    final modes = [
      ('Kolay', 1, AppColors.success),
      ('Orta', 2, AppColors.secondary),
      ('Yoğun', 4, AppColors.error),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mod Karşılaştırması', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        ...modes.map((m) {
          final date = PrayerCalculator.estimateCompletionDate(
            remaining: debt.remainingCounts,
            dailyTargetPerVakit: m.$2,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: m.$3, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text('${m.$1} (${m.$2}x): ',
                    style: AppTextStyles.bodyMedium),
                Text(
                  date != null
                      ? AppDateUtils.toDisplay(date)
                      : '—',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
