import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:kaza_takip/core/data/spiritual_content.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/daily_seed.dart';
import 'package:kaza_takip/presentation/widgets/ottoman/geometric_watermark.dart';

/// Manevi Dersler — 4 kategori artık tab'larda gizli değil, açık bir
/// dikey akışta her biri kendi Manuscript Kartı'na sahip. Her kart
/// share_plus ile native paylaşım destekler (organik tanıtım).
class SpiritualLessonsPage extends StatelessWidget {
  const SpiritualLessonsPage({super.key});

  /// Kategori → kart başlık etiketi (emoji + Türkçe ad).
  static const Map<SpiritualCategory, ({String emoji, String title})>
      _taxonomy = {
    SpiritualCategory.ayet: (emoji: '✨', title: 'Günün Ayeti'),
    SpiritualCategory.hadis: (emoji: '📜', title: 'Hadis-i Şerif'),
    SpiritualCategory.mevlana: (emoji: '🌹', title: 'Hz. Mevlana\'dan'),
    SpiritualCategory.risale: (emoji: '💡', title: 'Risale-i Nur\'dan'),
  };

  @override
  Widget build(BuildContext context) {
    final today = DailySeed.dailySet();
    return Container(
      color: AppColors.paper,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          _SectionIntro(),
          const SizedBox(height: 18),
          for (final cat in SpiritualCategory.values) ...[
            ManuscriptCard(
              category: cat,
              piece: today[cat]!,
              header: _taxonomy[cat]!.title,
              emoji: _taxonomy[cat]!.emoji,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

// ── Başlık intro şeridi ──────────────────────────────────────────────────────

class _SectionIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bugünün Manevi Akışı',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Her gün dört kategori — bereketle dolu kısa okumalar.',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

// ── Manuscript (el yazması) kart ─────────────────────────────────────────────

class ManuscriptCard extends StatelessWidget {
  final SpiritualCategory category;
  final SpiritualPiece piece;
  final String header;
  final String emoji;

  const ManuscriptCard({
    super.key,
    required this.category,
    required this.piece,
    required this.header,
    required this.emoji,
  });

  /// Paylaşım metnini imzayla birlikte oluşturur.
  String _formatShareText() {
    return '"${piece.text}"\n'
        '— ${piece.source}\n\n'
        '📍 Bu anlamlı paylaşım, Bütünsel İbadet & Kaza Takip Uygulaması ile keşfedildi. Reklamsız ve ücretsiz indir: [App Store / Play Store Link Placeholder]';
  }

  Future<void> _share() async {
    await Share.share(
      _formatShareText(),
      subject: '$header — Kaza Takip',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.matteGold, width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14C5A059),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Çok soluk geometrik filigran arka plan
          Positioned.fill(
            child: IgnorePointer(
              child: GeometricWatermark(
                color: AppColors.matteGold,
                opacity: 0.04,
                cellSize: 50,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(header: header, emoji: emoji, subtitle: category.subtitle),
              const _HairlineDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 26,
                      color: AppColors.matteGold.withOpacity(0.55),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      piece.text,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.55,
                        color: const Color(0xFF222222),
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.matteGold,
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          '— ${piece.source}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.imperial,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _HairlineDivider(),
              // Alt aksiyon barı — paylaş butonu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bugün için seçildi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.matteGoldDark,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Paylaş',
                      icon: const Icon(
                        Icons.share_outlined,
                        color: AppColors.matteGoldDark,
                        size: 20,
                      ),
                      onPressed: _share,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String header;
  final String emoji;
  final String subtitle;

  const _CardHeader({
    required this.header,
    required this.emoji,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 18,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.matteGoldDark,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x00C5A059),
            AppColors.matteGold,
            Color(0x00C5A059),
          ],
        ),
      ),
    );
  }
}
