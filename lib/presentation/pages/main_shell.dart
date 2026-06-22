import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/services/notification_service.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
import 'package:kaza_takip/presentation/pages/calendar/calendar_page.dart';
import 'package:kaza_takip/presentation/pages/dashboard/dashboard_v2_page.dart';
import 'package:kaza_takip/presentation/pages/ibadet/ibadet_center_page.dart';
import 'package:kaza_takip/presentation/pages/qibla/qibla_page.dart';
import 'package:kaza_takip/presentation/pages/settings/settings_page.dart';
import 'package:kaza_takip/presentation/pages/spiritual/spiritual_lessons_page.dart';
import 'package:kaza_takip/presentation/widgets/custom_app_drawer.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  AppSection _section = AppSection.dashboard;

  Widget get _body {
    return switch (_section) {
      AppSection.dashboard => const DashboardV2Page(),
      AppSection.calendar => const CalendarPage(),
      AppSection.ibadet => const IbadetCenterPage(),
      AppSection.qibla => const QiblaPage(),
      AppSection.spiritual => const SpiritualLessonsPage(),
      AppSection.settings => const SettingsPage(),
    };
  }

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
    if (ls == AppLifecycleState.paused || ls == AppLifecycleState.detached) {
      final bloc = context.read<KazaBloc>();
      if (bloc.state is KazaLoaded) bloc.add(const SyncDataWithCloud());
    }
    if (ls == AppLifecycleState.resumed) {
      final notif = sl<NotificationService>();
      if (notif.isEnabled) notif.rescheduleAll();
    }
  }

  void _onSectionSelected(AppSection s) {
    setState(() => _section = s);
    Navigator.of(context).pop(); // drawer'ı kapat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      drawer: CustomAppDrawer(
        current: _section,
        onSelect: _onSectionSelected,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            tooltip: 'Menü',
            splashRadius: 22,
            icon: const RefinedMenuIcon(
              color: AppColors.imperial,
              size: 24,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          _section.title,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.imperial,
            fontSize: 22,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_section),
          child: _body,
        ),
      ),
    );
  }
}
