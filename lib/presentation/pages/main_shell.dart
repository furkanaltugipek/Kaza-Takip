import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/services/notification_service.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
import 'package:kaza_takip/presentation/pages/calendar/calendar_page.dart';
import 'package:kaza_takip/presentation/pages/dashboard/dashboard_v2_page.dart';
import 'package:kaza_takip/presentation/pages/ibadet/ibadet_center_page.dart';
import 'package:kaza_takip/presentation/pages/profile/profile_page.dart';
import 'package:kaza_takip/presentation/pages/simulator/simulator_page.dart';

/// Uygulamanın ana çerçevesi — alt gezinti çubuğu + sekmeler.
///
/// Uygulama yaşam döngüsü değiştiğinde (paused/detached) biriken yerel
/// değişiklikleri Firestore'a batch olarak senkronize eder.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _tab = 0;

  static const _pages = [
    DashboardV2Page(),
    CalendarPage(),
    IbadetCenterPage(),
    SimulatorPage(),
    ProfilePage(),
  ];

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
    // Uygulama arka plana geçince tek batch ile buluta senkronize et.
    if (ls == AppLifecycleState.paused || ls == AppLifecycleState.detached) {
      final bloc = context.read<KazaBloc>();
      if (bloc.state is KazaLoaded) {
        bloc.add(const SyncDataWithCloud());
      }
    }
    // Öne gelince namaz vakti hatırlatıcılarını tazele (vakitler her gün değişir).
    if (ls == AppLifecycleState.resumed) {
      final notif = sl<NotificationService>();
      if (notif.isEnabled) notif.rescheduleAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_tab),
          child: _pages[_tab],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF9E9E9E),
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Bugün',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Takvim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mosque_outlined),
              activeIcon: Icon(Icons.mosque),
              label: 'İbadet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Simülatör',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
