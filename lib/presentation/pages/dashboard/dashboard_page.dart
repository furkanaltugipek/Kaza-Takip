import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/entities/streak.dart';
import 'package:kaza_takip/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:kaza_takip/presentation/pages/simulator/simulator_page.dart';
import 'package:kaza_takip/presentation/pages/wizard/kaza_wizard_page.dart';
import 'package:kaza_takip/presentation/widgets/common/streak_banner.dart';
import 'package:kaza_takip/presentation/widgets/prayer_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Sync to Firestore when app goes background
    context.read<DashboardBloc>().add(const DashboardSyncRequested());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<DashboardBloc>().add(const DashboardSyncRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Bugün'),
          NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Simülatör'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ayarlar'),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _TodayTab(),
          SimulatorPage(),
          _SettingsTab(),
        ],
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.kazaDebt == null) {
          return _NoDebtSetupView();
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  AppDateUtils.toDisplay(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onSelected: (mode) => context
                      .read<DashboardBloc>()
                      .add(DashboardModeChanged(mode)),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'easy', child: Text('Kolay (1 kaza)')),
                    PopupMenuItem(
                        value: 'medium', child: Text('Orta (2 kaza)')),
                    PopupMenuItem(
                        value: 'hard', child: Text('Yoğun (4 kaza)')),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.streak != null)
                      StreakBanner(streak: state.streak!),
                    const SizedBox(height: 16),
                    _ProgressSummary(plan: state.todayPlan),
                    const SizedBox(height: 16),
                    Text('Bugünkü Kazalar',
                        style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (state.todayPlan != null)
              _PrayerSlotList(plan: state.todayPlan!)
            else
              const SliverToBoxAdapter(
                child: Center(
                  child: Text('Bugün için plan oluşturuluyor...'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final PrayerPlan? plan;
  const _ProgressSummary({this.plan});

  @override
  Widget build(BuildContext context) {
    if (plan == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${plan!.completedCount} / ${plan!.totalCount}',
                    style: AppTextStyles.displayMedium),
                Text('tamamlandı', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: plan!.completionRatio,
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceVariant,
              color: plan!.isFullyCompleted
                  ? AppColors.success
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerSlotList extends StatelessWidget {
  final PrayerPlan plan;
  const _PrayerSlotList({required this.plan});

  @override
  Widget build(BuildContext context) {
    // Group slots by prayer key for display
    final grouped = <String, List<PrayerSlot>>{};
    for (final key in PrayerConstants.prayerKeys) {
      final slots = plan.slots.where((s) => s.prayerKey == key).toList();
      if (slots.isNotEmpty) grouped[key] = slots;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final key = grouped.keys.elementAt(index);
            final slots = grouped[key]!;
            final prayerIndex = PrayerConstants.prayerKeys.indexOf(key);
            final name = PrayerConstants.prayerNames[prayerIndex];
            final color = AppColors.prayerColors[key] ?? AppColors.primary;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PrayerCard(
                prayerName: name,
                prayerKey: key,
                slots: slots,
                color: color,
                onSlotTap: (slotId) => context
                    .read<DashboardBloc>()
                    .add(DashboardPrayerCompleted(slotId)),
              ),
            );
          },
          childCount: grouped.length,
        ),
      ),
    );
  }
}

class _NoDebtSetupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mosque_rounded,
                size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Kaza Borcu Hesaplanmadı',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Kaza namazı takibine başlamak için önce borç hesabını yapın.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Hesaplamaya Başla'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KazaWizardPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Kaza Borcunu Yeniden Hesapla'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const KazaWizardPage()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
