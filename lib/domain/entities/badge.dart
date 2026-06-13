import 'package:equatable/equatable.dart';

enum BadgeType {
  firstPrayer,
  streak7,
  streak30,
  streak100,
  halfwayThere,
  allClear,
  perfectWeek,
  earlyBird, // completed fajr kaza 7 days in a row
}

class AppBadge extends Equatable {
  final BadgeType type;
  final String titleTr;
  final String descriptionTr;
  final String iconAsset;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  const AppBadge({
    required this.type,
    required this.titleTr,
    required this.descriptionTr,
    required this.iconAsset,
    this.unlockedAt,
  });

  AppBadge unlock(DateTime at) => AppBadge(
        type: type,
        titleTr: titleTr,
        descriptionTr: descriptionTr,
        iconAsset: iconAsset,
        unlockedAt: at,
      );

  @override
  List<Object?> get props => [type, unlockedAt];
}

/// All badge definitions — seeded at startup, unlockedAt filled in per user.
class BadgeCatalog {
  static const List<AppBadge> all = [
    AppBadge(
      type: BadgeType.firstPrayer,
      titleTr: 'İlk Adım',
      descriptionTr: 'İlk kaza namazını tamamladın!',
      iconAsset: 'assets/icons/badge_first.svg',
    ),
    AppBadge(
      type: BadgeType.streak7,
      titleTr: '7 Günlük Seri',
      descriptionTr: '7 gün üst üste hedefini tamamladın.',
      iconAsset: 'assets/icons/badge_streak7.svg',
    ),
    AppBadge(
      type: BadgeType.streak30,
      titleTr: 'Aylık Kararlılık',
      descriptionTr: '30 gün üst üste hedefini tamamladın.',
      iconAsset: 'assets/icons/badge_streak30.svg',
    ),
    AppBadge(
      type: BadgeType.streak100,
      titleTr: '100 Gün',
      descriptionTr: '100 günlük seri — olağanüstü azim!',
      iconAsset: 'assets/icons/badge_streak100.svg',
    ),
    AppBadge(
      type: BadgeType.halfwayThere,
      titleTr: 'Yarı Yolda',
      descriptionTr: 'Kaza borcunun yarısını tamamladın.',
      iconAsset: 'assets/icons/badge_halfway.svg',
    ),
    AppBadge(
      type: BadgeType.allClear,
      titleTr: 'Kaza Borçsuz!',
      descriptionTr: 'Tüm kaza namazlarını tamamladın. Tebrikler!',
      iconAsset: 'assets/icons/badge_allclear.svg',
    ),
    AppBadge(
      type: BadgeType.perfectWeek,
      titleTr: 'Mükemmel Hafta',
      descriptionTr: 'Bir haftanın tüm günlerini eksiksiz tamamladın.',
      iconAsset: 'assets/icons/badge_week.svg',
    ),
    AppBadge(
      type: BadgeType.earlyBird,
      titleTr: 'Sabah Kuşu',
      descriptionTr: '7 gün üst üste sabah kazasını tamamladın.',
      iconAsset: 'assets/icons/badge_earlybird.svg',
    ),
  ];
}
