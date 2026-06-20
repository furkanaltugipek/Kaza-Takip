import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/domain/entities/kaza_metrics.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
import 'package:kaza_takip/presentation/pages/wizard/wizard_page.dart';
import 'package:kaza_takip/presentation/widgets/common/kaza_progress_bar.dart';
import 'package:kaza_takip/presentation/widgets/common/streak_card.dart';
import 'package:kaza_takip/presentation/widgets/daily_inspiration_card.dart';
import 'package:kaza_takip/presentation/widgets/daily_prayer_tile.dart';
import 'package:kaza_takip/presentation/widgets/prayer_times_top_bar.dart';

/// Bugünkü Plan — ana dashboard ekranı.
class DashboardV2Page extends StatelessWidget {
  const DashboardV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KazaBloc, KazaState>(
      builder: (context, state) {
        // Namaz vakitleri her durumda en üstte görünür — kaza borcu
        // hesaplanmamış olsa bile kullanıcı vakitleri ve geri sayımı görür.
        final Map<String, int> completedToday = state is KazaLoaded
            ? {
                for (final k in PrayerConstants.prayerKeys)
                  k: state.completedTodayFor(k),
              }
            : const {};

        Widget content;
        if (state is KazaLoading || state is KazaInitial) {
          content = const _BelowBarLoading();
        } else if (state is KazaLoaded && state.metrics.totalDebtCount == 0) {
          content = const _SetupBody();
        } else if (state is KazaLoaded) {
          return _LoadedDashboard(state: state);
        } else if (state is KazaError) {
          content = _ErrorBody(message: state.message);
        } else {
          content = const _SetupBody();
        }

        return Container(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrayerTimesTopBar(completedToday: completedToday),
                const SizedBox(height: 16),
                content,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Yükleniyor (üst bar altı) ────────────────────────────────────────────────

class _BelowBarLoading extends StatelessWidget {
  const _BelowBarLoading();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

// ── Hata (üst bar altı) ──────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Kurulum yapılmamış (üst bar altı) ────────────────────────────────────────

class _SetupBody extends StatelessWidget {
  const _SetupBody();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mosque_rounded,
                size: 46, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Hoş Geldiniz',
              style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Kaza namazı takibine başlamak için borç hesabı yapın.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: const Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Kaza Borcumu Hesapla'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<KazaBloc>(),
                    child: const WizardPage(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ana yüklü dashboard ───────────────────────────────────────────────────────

class _LoadedDashboard extends StatefulWidget {
  final KazaLoaded state;
  const _LoadedDashboard({required this.state});

  @override
  State<_LoadedDashboard> createState() => _LoadedDashboardState();
}

class _LoadedDashboardState extends State<_LoadedDashboard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState ls) {
    // Uygulama arka plana geçince buluta senkronize et.
    if (ls == AppLifecycleState.paused ||
        ls == AppLifecycleState.detached) {
      context.read<KazaBloc>().add(const SyncDataWithCloud());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final metrics = s.metrics;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Namaz vakitleri + Hicri tarih + canlı geri sayım + dini gün uyarısı
              PrayerTimesTopBar(
                completedToday: {
                  for (final k in PrayerConstants.prayerKeys)
                    k: s.completedTodayFor(k),
                },
              ),
              const SizedBox(height: 16),

              // Kaza ilerleme özeti
              _ProgressInline(
                completionRatio: metrics.completionPercentage,
                remainingCount: metrics.totalRemaining,
                remainingRakats: metrics.totalRakatsRemaining,
              ),
              const SizedBox(height: 16),

              // İstikrar Ateşi
              StreakCard(
                currentStreak: metrics.currentStreak,
                longestStreak: metrics.longestStreak,
                totalCompleted: metrics.totalCompletedCount,
              ),
              const SizedBox(height: 16),

              // Günün İlhamı — Ayet / Hadis / Mevlana / Risale-i Nur
              const DailyInspirationCard(),
              const SizedBox(height: 24),

              // Mod seçici
              _ModeSelector(currentMode: s.planMode),
              const SizedBox(height: 16),

              // Bugünün planı başlığı
              Row(
                children: [
                  Text(
                    'Bugünkü Planın',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const Spacer(),
                  Text(
                    AppDateUtils.toDisplay(DateTime.now()),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Vakit listesi
              ...PrayerConstants.prayerKeys.map((key) {
                final idx = PrayerConstants.prayerKeys.indexOf(key);
                final name = PrayerConstants.prayerNames[idx];
                final color =
                    AppColors.prayerColors[key] ?? AppColors.primary;
                final completed = s.completedTodayFor(key);
                final target = s.dailyTargetPerVakit;

                return DailyPrayerTile(
                  name: name,
                  vakitKey: key,
                  completed: completed,
                  target: target,
                  color: color,
                  onChanged: (delta) => context.read<KazaBloc>().add(
                    TogglePrayerComplete(key, amount: delta),
                  ),
                );
              }),

              // Kalan borç özeti
              const SizedBox(height: 8),
              _RemainingDebtsExpander(metrics: metrics),
            ],
          ),
        ),
    );
  }
}

// ── Kompakt ilerleme satırı ──────────────────────────────────────────────────

class _ProgressInline extends StatelessWidget {
  final double completionRatio;
  final int remainingCount;
  final int remainingRakats;
  const _ProgressInline({
    required this.completionRatio,
    required this.remainingCount,
    required this.remainingRakats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: KazaProgressBar(
        value: completionRatio,
        remainingCount: remainingCount,
        remainingRakats: remainingRakats,
      ),
    );
  }
}

// ── Mod seçici çip grubu ─────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  final String currentMode;
  const _ModeSelector({required this.currentMode});

  static const _modes = [
    ('EASY', 'Kolay', '1 kaza/vakit'),
    ('MEDIUM', 'Orta', '2 kaza/vakit'),
    ('HARD', 'Yoğun', '4 kaza/vakit'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _modes.map((m) {
        final selected = currentMode == m.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => context
                .read<KazaBloc>()
                .add(ChangePlanMode(m.$1)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    m.$2,
                    style: AppTextStyles.labelLarge.copyWith(
                      color:
                          selected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  Text(
                    m.$3,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          selected ? Colors.white70 : null,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Kalan borç genişletilebilir bölümü ──────────────────────────────────────

class _RemainingDebtsExpander extends StatefulWidget {
  final KazaMetrics metrics;
  const _RemainingDebtsExpander({required this.metrics});

  @override
  State<_RemainingDebtsExpander> createState() =>
      _RemainingDebtsExpanderState();
}

class _RemainingDebtsExpanderState
    extends State<_RemainingDebtsExpander> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Text('Tüm Kalan Borçlar',
                    style: AppTextStyles.titleMedium),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: PrayerConstants.prayerKeys.map((key) {
                final idx =
                    PrayerConstants.prayerKeys.indexOf(key);
                final name = PrayerConstants.prayerNames[idx];
                final color =
                    AppColors.prayerColors[key] ?? AppColors.primary;
                final remaining = widget.metrics.remainingFor(key);
                final rakats =
                    remaining * (PrayerConstants.fardRakats[key] ?? 0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(name,
                            style: AppTextStyles.bodyMedium),
                      ),
                      Text(
                        '$remaining vakit · $rakats rekat',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

