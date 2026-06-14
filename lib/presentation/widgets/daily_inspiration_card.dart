import 'package:flutter/material.dart';
import 'package:kaza_takip/core/data/spiritual_content.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/daily_seed.dart';

/// Günlük manevi okuma kartı.
///
/// 4 kategori (Ayet / Hadis / Mevlana / Risale-i Nur) arasında
/// kaydırarak veya sekmeye dokunarak geçilebilir. Tüm içerik %100 yereldir;
/// gün değiştikçe `DailySeed` ile her kategoriden yeni bir parça açılır.
class DailyInspirationCard extends StatefulWidget {
  const DailyInspirationCard({super.key});

  @override
  State<DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends State<DailyInspirationCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: SpiritualCategory.values.length, vsync: this);

  late final Map<SpiritualCategory, SpiritualPiece> _today =
      DailySeed.dailySet();

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF888888),
            labelStyle: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyles.titleMedium,
            dividerColor: AppColors.divider,
            tabs: [
              for (final c in SpiritualCategory.values)
                Tab(text: c.title, height: 40),
            ],
          ),
          SizedBox(
            height: 240,
            child: TabBarView(
              controller: _tab,
              children: [
                for (final c in SpiritualCategory.values)
                  _PieceView(category: c, piece: _today[c]!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Günün İlhamı', style: AppTextStyles.titleLarge),
                Text(
                  'Her gün yeni bir parça açılır',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceView extends StatelessWidget {
  final SpiritualCategory category;
  final SpiritualPiece piece;

  const _PieceView({required this.category, required this.piece});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 28,
                color: AppColors.secondary.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            piece.text,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '— ${piece.source}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
