import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/fasting_module.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/hatim_module.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/dhikr_module.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/charity_module.dart';

/// İbadet Merkezi — 4 ek modül için sekmeli sayfa.
///
/// MainShell zaten transparent paper AppBar'da "İbadet Merkezi" başlığını
/// gösterir; bu sayfa kendi Scaffold + AppBar'ını kullanmaz (eski sürümde
/// başlık çift basılıyordu). Sadece TabBar + içerik döner.
class IbadetCenterPage extends StatelessWidget {
  const IbadetCenterPage({super.key});

  static const _tabs = [
    (icon: Icons.nightlight_outlined, label: 'Oruç'),
    (icon: Icons.menu_book_outlined, label: 'Hatim'),
    (icon: Icons.touch_app_outlined, label: 'Zikir'),
    (icon: Icons.volunteer_activism_outlined, label: 'Sadaka'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Container(
        color: AppColors.paper,
        child: Column(
          children: [
            // Kontrast düzeltmesi: paper zeminde emerald label + gold indicator.
            Container(
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.6),
                ),
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.imperial,
                unselectedLabelColor: const Color(0xFF555555),
                indicatorColor: AppColors.matteGold,
                indicatorWeight: 2.4,
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.imperial,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
                unselectedLabelStyle: AppTextStyles.titleMedium.copyWith(
                  color: const Color(0xFF555555),
                  fontWeight: FontWeight.w500,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(
                  AppColors.matteGold.withOpacity(0.08),
                ),
                tabs: [
                  for (final t in _tabs)
                    Tab(
                      iconMargin: const EdgeInsets.only(bottom: 4),
                      // icon, labelColor/unselectedLabelColor'dan rengi miras alır
                      icon: Icon(t.icon, size: 20),
                      text: t.label,
                    ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  FastingModule(),
                  HatimModule(),
                  DhikrModule(),
                  CharityModule(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
