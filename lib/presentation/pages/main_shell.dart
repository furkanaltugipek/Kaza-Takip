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

/// Uygulama bölümleri — sıra menü sırasıyla birebir eşleşmeli.
enum _Section {
  dashboard,
  calendar,
  ibadet,
  qibla,
  spiritual,
  settings,
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  _Section _section = _Section.dashboard;

  static const _titles = {
    _Section.dashboard: 'Ana Sayfa',
    _Section.calendar: 'Takvim & Analiz',
    _Section.ibadet: 'İbadet Merkezi',
    _Section.qibla: 'Kıble Pusulası',
    _Section.spiritual: 'Manevi Dersler',
    _Section.settings: 'Ayarlar',
  };

  static const _icons = {
    _Section.dashboard: Icons.home_outlined,
    _Section.calendar: Icons.grid_view_outlined,
    _Section.ibadet: Icons.mosque_outlined,
    _Section.qibla: Icons.explore_outlined,
    _Section.spiritual: Icons.auto_stories_outlined,
    _Section.settings: Icons.settings_outlined,
  };

  Widget get _body {
    return switch (_section) {
      _Section.dashboard => const DashboardV2Page(),
      _Section.calendar => const CalendarPage(),
      _Section.ibadet => const IbadetCenterPage(),
      _Section.qibla => const QiblaPage(),
      _Section.spiritual => const SpiritualLessonsPage(),
      _Section.settings => const SettingsPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: PopupMenuButton<_Section>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          tooltip: 'Menü',
          offset: const Offset(0, 48),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (s) => setState(() => _section = s),
          itemBuilder: (_) => _Section.values.map((s) {
            final selected = s == _section;
            return PopupMenuItem<_Section>(
              value: s,
              child: Row(
                children: [
                  Icon(
                    _icons[s],
                    size: 20,
                    color:
                        selected ? AppColors.primary : const Color(0xFF555555),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _titles[s]!,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: selected ? AppColors.primary : null,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (selected) ...[
                    const Spacer(),
                    const Icon(Icons.check,
                        size: 16, color: AppColors.primary),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        title: Text(
          _titles[_section]!,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(_section),
          child: _body,
        ),
      ),
    );
  }
}
