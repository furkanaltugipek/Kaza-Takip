import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/presentation/widgets/ottoman/geometric_watermark.dart';

/// AppBar leading için zarif, custom-paint menü ikonu.
/// Üç ince yatay çizgi — orta çizgi kasıtlı olarak biraz kısa, premium his.
class RefinedMenuIcon extends StatelessWidget {
  final Color color;
  final double size;

  const RefinedMenuIcon({
    super.key,
    this.color = AppColors.imperial,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RefinedMenuPainter(color: color)),
    );
  }
}

class _RefinedMenuPainter extends CustomPainter {
  final Color color;
  const _RefinedMenuPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final w1 = w * 0.78; // üst
    final w2 = w * 0.58; // orta (kısa)
    final w3 = w * 0.78; // alt

    canvas.drawLine(
        Offset(cx - w1 / 2, h * 0.32), Offset(cx + w1 / 2, h * 0.32), paint);
    canvas.drawLine(
        Offset(cx - w2 / 2, h * 0.50), Offset(cx + w2 / 2, h * 0.50), paint);
    canvas.drawLine(
        Offset(cx - w3 / 2, h * 0.68), Offset(cx + w3 / 2, h * 0.68), paint);
  }

  @override
  bool shouldRepaint(covariant _RefinedMenuPainter old) => old.color != color;
}

/// Uygulama bölümleri — drawer ve shell tarafından paylaşılır.
enum AppSection {
  dashboard('Ana Sayfa', Icons.home_outlined),
  calendar('Takvim & Analiz', Icons.calendar_today_outlined),
  ibadet('İbadet Merkezi', Icons.mosque_outlined),
  qibla('Kıble Pusulası', Icons.explore_outlined),
  spiritual('Manevi Dersler', Icons.auto_stories_outlined),
  settings('Ayarlar', Icons.settings_outlined);

  final String title;
  final IconData icon;
  const AppSection(this.title, this.icon);
}

/// Premium yan menü — krem zemin, üst-sağ kemerli köşe, altın aksanlı seçim,
/// her satırda bol nefes alanı. Geleneksel hamburger pop-up yerine kullanılır.
class CustomAppDrawer extends StatelessWidget {
  final AppSection current;
  final ValueChanged<AppSection> onSelect;

  const CustomAppDrawer({
    super.key,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 296,
      shape: const RoundedRectangleBorder(
        // Geleneksel kemer hissi — üst-sağ kavisli, alt-sağ ince.
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(16),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.paper,
            // Sağ kenarda ince altın dikey çizgi — bir kitap omurgası gibi.
            border: Border(
              right: BorderSide(color: AppColors.matteGold, width: 0.8),
            ),
          ),
          child: Stack(
            children: [
              // Filigran — alt-orta bölgede çok soluk yıldız deseni.
              Positioned.fill(
                child: IgnorePointer(
                  child: GeometricWatermark(
                    color: AppColors.matteGold,
                    opacity: 0.035,
                    cellSize: 58,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    const _DividerLine(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (final section in AppSection.values)
                            _DrawerTile(
                              section: section,
                              selected: section == current,
                              onTap: () => onSelect(section),
                            ),
                        ],
                      ),
                    ),
                    const _Footer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Üst başlık: marka + ince ornament ────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.imperial.withOpacity(0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.matteGold,
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  size: 18,
                  color: AppColors.imperial,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kaza Takip',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 19,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'İbadet Planlayıcısı',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.matteGoldDark,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
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

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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

// ── Liste öğesi ──────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final AppSection section;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? AppColors.cream : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.matteGold.withOpacity(0.12),
          highlightColor: AppColors.matteGold.withOpacity(0.06),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.matteGold : Colors.transparent,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                // İnce altın dikey vurgu — sadece seçili öğede.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: selected ? 3 : 0,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.matteGold,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: selected ? 12 : 0,
                ),
                Icon(
                  section.icon,
                  size: 21,
                  color: selected
                      ? AppColors.imperial
                      : AppColors.imperial.withOpacity(0.7),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    section.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.imperial,
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.matteGold,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Alt bilgi: imza & ince ornament ──────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DividerLine(),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.brightness_2_outlined,
                size: 14,
                color: AppColors.matteGoldDark,
              ),
              const SizedBox(width: 8),
              Text(
                'v1.0 · Yerel & Bereketli',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.matteGoldDark,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
