import 'package:kaza_takip/core/data/spiritual_content.dart';

/// Günün takvim indeksinden deterministik içerik seçici.
///
/// Aynı gün için her zaman aynı parçayı döner; gece yarısı bir sonraki
/// güne geçildiğinde her kategoride yeni bir parça açılır. Tamamen yereldir.
class DailySeed {
  DailySeed._();

  /// 1 Ocak'tan itibaren gün sayısı (1-366).
  static int dayOfYear([DateTime? now]) {
    final d = now ?? DateTime.now();
    final start = DateTime(d.year, 1, 1);
    return d.difference(start).inDays + 1;
  }

  /// Her kategoride farklı offset kullanarak parçaların aynı anda dönmesini
  /// engelliyoruz — kullanıcı 4 farklı tema okumuş hissetsin.
  static SpiritualPiece pieceOf(SpiritualCategory c, [DateTime? now]) {
    final list = SpiritualContent.forCategory(c);
    if (list.isEmpty) {
      return const SpiritualPiece(text: '', source: '');
    }
    final day = dayOfYear(now);
    final offset = switch (c) {
      SpiritualCategory.ayet => 0,
      SpiritualCategory.hadis => 3,
      SpiritualCategory.mevlana => 7,
      SpiritualCategory.gazali => 5,
      SpiritualCategory.risale => 11,
    };
    return list[(day + offset) % list.length];
  }

  /// Tüm kategoriler için günün parçaları.
  static Map<SpiritualCategory, SpiritualPiece> dailySet([DateTime? now]) {
    return {
      for (final c in SpiritualCategory.values) c: pieceOf(c, now),
    };
  }

  /// O gün sabah ve akşam bildirimleri için iki farklı kategoriden parça döner.
  /// Yerel-deterministik "akıllı" seçici — aynı gün aynı içerik, gün değişince
  /// rotasyon ilerler. AI gerektirmez, free-tier güvenli.
  static (SpiritualCategory cat, SpiritualPiece piece) pickFor({
    required DateTime day,
    required bool morning,
  }) {
    final categories = SpiritualCategory.values;
    final dy = dayOfYear(day);
    final slot = morning ? 0 : 2; // sabah ve akşam farklı kategoriye düşsün
    final cat = categories[(dy + slot) % categories.length];
    return (cat, pieceOf(cat, day));
  }
}
