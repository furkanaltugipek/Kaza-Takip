import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/presentation/bloc/kaza_calculator/kaza_calculator_bloc.dart';
import 'package:kaza_takip/presentation/pages/dashboard/dashboard_page.dart';

class KazaResultPage extends StatelessWidget {
  const KazaResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final debt = context.read<KazaCalculatorBloc>().state.result!;
    final totalCount = PrayerCalculator.totalCount(debt.remainingCounts);
    final totalRakats = PrayerCalculator.totalRakats(debt.remainingCounts);

    return Scaffold(
      appBar: AppBar(title: const Text('Hesap Sonucu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalSummaryCard(
              totalCount: totalCount,
              totalRakats: totalRakats,
            ),
            const SizedBox(height: 24),
            Text('Namaz Bazlı Dağılım',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            ...PrayerConstants.prayerKeys.map((key) {
              final count = debt.remainingCounts[key] ?? 0;
              final rakats =
                  count * (PrayerConstants.fardRakats[key] ?? 0);
              final idx =
                  PrayerConstants.prayerKeys.indexOf(key);
              final name = PrayerConstants.prayerNames[idx];
              final color = AppColors.prayerColors[key] ?? AppColors.primary;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PrayerDebtRow(
                  name: name,
                  count: count,
                  rakats: rakats,
                  color: color,
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const DashboardPage()),
                  (_) => false,
                ),
                child: const Text('Günlük Plana Başla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalSummaryCard extends StatelessWidget {
  final int totalCount;
  final int totalRakats;
  const _TotalSummaryCard(
      {required this.totalCount, required this.totalRakats});

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.mosque_rounded, color: Colors.white70, size: 40),
          const SizedBox(height: 12),
          Text(
            '$totalCount',
            style: AppTextStyles.prayerCount.copyWith(
              color: Colors.white,
              fontSize: 48,
            ),
          ),
          Text('Toplam Kaza Namazı',
              style: AppTextStyles.titleMedium
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Text(
            '$totalRakats rekat',
            style: AppTextStyles.headlineMedium
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PrayerDebtRow extends StatelessWidget {
  final String name;
  final int count;
  final int rakats;
  final Color color;
  const _PrayerDebtRow(
      {required this.name,
      required this.count,
      required this.rakats,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: AppTextStyles.titleMedium),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$count namaz',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: color, fontWeight: FontWeight.w600)),
              Text('$rakats rekat',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
