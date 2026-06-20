import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/presentation/widgets/daily_inspiration_card.dart';

/// Manevi Dersler — Günün ayeti, hadisi, Mevlana ve Risale-i Nur okumaları.
class SpiritualLessonsPage extends StatelessWidget {
  const SpiritualLessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: DailyInspirationCard(),
      ),
    );
  }
}
