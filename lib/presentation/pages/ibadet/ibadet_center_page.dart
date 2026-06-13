import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/fasting_module.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/hatim_module.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/dhikr_module.dart';
import 'package:kaza_takip/presentation/pages/ibadet/modules/charity_module.dart';

/// İbadet Merkezi — 4 ek modülü barındıran sekmeli sayfa.
class IbadetCenterPage extends StatelessWidget {
  const IbadetCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('İbadet Merkezi'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.secondary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.nightlight_outlined), text: 'Oruç'),
              Tab(icon: Icon(Icons.menu_book_outlined), text: 'Hatim'),
              Tab(icon: Icon(Icons.touch_app_outlined), text: 'Zikir'),
              Tab(icon: Icon(Icons.volunteer_activism_outlined), text: 'Sadaka'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FastingModule(),
            HatimModule(),
            DhikrModule(),
            CharityModule(),
          ],
        ),
      ),
    );
  }
}
