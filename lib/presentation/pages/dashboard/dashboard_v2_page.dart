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
import 'package:kaza_takip/presentation/widgets/daily_prayer_tile.dart';

/// Bugünkü Plan — ana dashboard ekranı.
class DashboardV2Page extends StatelessWidget {
  const DashboardV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KazaBloc, KazaState>(
      builder: (context, state) {
        if (state is KazaLoading || state is KazaInitial) {
          return const _LoadingView();
        }
        if (state is KazaLoaded && state.metrics.totalDebtCount == 0) {
          return const _SetupView();
        }
        if (state is KazaLoaded) {
          return _LoadedDashboard(state: state);
        }
        if (state is KazaError) {
          return _ErrorView(message: state.message);
        }
        return const _SetupView();
      },
    );
  }
}

// ── Yükleniyor ────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

// ── Hata ──────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              Text(message,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Kurulum yapılmamış ────────────────────────────────────────────────────────

class _SetupView extends StatelessWidget {
  const _SetupView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mosque_rounded,
                      size: 52, color: AppColors.primary),
                ),
                const SizedBox(height: 28),
                Text(
                  'Hoş Geldiniz',
                  style: AppTextStyles.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kaza namazı takibine başlamak için borç hesabı yapın.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: const Color(0xFF666666)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
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
          ),
        ),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScroll) => [
          _DashboardAppBar(state: s),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İlerleme özet kartı
              _SummaryCard(
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
      ),
    );
  }
}

// ── SliverAppBar ──────────────────────────────────────────────────────────────

class _DashboardAppBar extends StatelessWidget {
  final KazaLoaded state;
  const _DashboardAppBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final pending = state.pendingChanges;
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text('Bugünkü Planın'),
      actions: [
        if (pending > 0)
          Tooltip(
            message: '$pending değişiklik senkronize edilmedi',
            child: IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              onPressed: () =>
                  context.read<KazaBloc>().add(const SyncDataWithCloud()),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.tune_outlined),
          onPressed: () => _showModeSheet(context, state.planMode),
        ),
      ],
    );
  }

  void _showModeSheet(BuildContext ctx, String current) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<KazaBloc>(),
        child: _ModeSheet(current: current),
      ),
    );
  }
}

// ── Özet kartı ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double completionRatio;
  final int remainingCount;
  final int remainingRakats;
  const _SummaryCard({
    required this.completionRatio,
    required this.remainingCount,
    required this.remainingRakats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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

// ── Mod seçim alt sayfası ─────────────────────────────────────────────────────

class _ModeSheet extends StatelessWidget {
  final String current;
  const _ModeSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    const modes = [
      ('EASY', 'Kolay', 'Her vakit sonrası 1 kaza namazı', Icons.spa_outlined),
      ('MEDIUM', 'Orta', 'Her vakit sonrası 2 kaza namazı',
          Icons.fitness_center_outlined),
      ('HARD', 'Yoğun', 'Her vakit sonrası 4 kaza namazı',
          Icons.local_fire_department_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Günlük Tempo', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text('Her vakit için günlük kaza hedefi.',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),
          ...modes.map((m) {
            final selected = current == m.$1;
            return GestureDetector(
              onTap: () {
                context.read<KazaBloc>().add(ChangePlanMode(m.$1));
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.divider,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m.$4,
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFF666666)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$2,
                              style: AppTextStyles.titleMedium
                                  .copyWith(
                                      color: selected
                                          ? AppColors.primary
                                          : null)),
                          Text(m.$3,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle,
                          color: AppColors.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
