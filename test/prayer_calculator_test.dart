import 'package:flutter_test/flutter_test.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';

void main() {
  group('PrayerCalculator.calculate', () {
    final birthDate = DateTime(1990, 1, 1);

    test('zero debt when prayer start is before puberty', () {
      final result = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: 13,
        prayerStartDate: DateTime(2000, 1, 1), // age 10, before puberty
      );
      expect(result.totalDays, 0);
      expect(result.totalRakats, 0);
      for (final key in PrayerConstants.prayerKeys) {
        expect(result.breakdown[key], 0);
      }
    });

    test('defaults pubertyAge to 13 when null', () {
      final result = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: null,
        prayerStartDate: DateTime(2013, 1, 1), // age 23 → 10 yrs debt
      );
      // puberty at 2003-01-01, prayer start 2013-01-01 → ~3653 days
      expect(result.totalDays, greaterThan(3600));
      expect(result.pubertyDate, DateTime(2003, 1, 1));
    });

    test('subtracts estimatedOffDays from the debt', () {
      final base = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: 13,
        prayerStartDate: DateTime(2013, 1, 1),
      );
      final withOff = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: 13,
        prayerStartDate: DateTime(2013, 1, 1),
        estimatedOffDays: 100,
      );
      expect(withOff.totalDays, base.totalDays - 100);
    });

    test('never returns negative debt even with huge off days', () {
      final result = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: 13,
        prayerStartDate: DateTime(2014, 1, 1),
        estimatedOffDays: 1000000,
      );
      expect(result.totalDays, 0);
    });

    test('breakdown applies equally to all 6 vakit', () {
      final result = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: 13,
        prayerStartDate: DateTime(2014, 1, 1),
      );
      final values = result.breakdown.values.toSet();
      expect(values.length, 1); // all equal
      expect(result.breakdown.length, 6);
    });

    test('totalRakats equals totalDays * 20', () {
      final result = PrayerCalculator.calculate(
        birthDate: birthDate,
        pubertyAge: 13,
        prayerStartDate: DateTime(2014, 1, 1),
      );
      expect(result.totalRakats, result.totalDays * 20);
    });
  });

  group('PrayerCalculator helpers', () {
    test('toRakats returns correct rakat counts', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 1};
      final rakats = PrayerCalculator.toRakats(counts);
      expect(rakats['fajr'], 2);
      expect(rakats['dhuhr'], 4);
      expect(rakats['asr'], 4);
      expect(rakats['maghrib'], 3);
      expect(rakats['isha'], 4);
      expect(rakats['witr'], 3);
    });

    test('totalRakats sums to 20 per day', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 1};
      expect(PrayerCalculator.totalRakats(counts), 20);
    });

    test('estimateCompletionDate returns null when target is zero', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 10};
      expect(
        PrayerCalculator.estimateCompletionDate(
            remaining: counts, dailyTargetPerVakit: 0),
        isNull,
      );
    });

    test('estimateCompletionDate gives a future date', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 365};
      final result = PrayerCalculator.estimateCompletionDate(
          remaining: counts, dailyTargetPerVakit: 1);
      expect(result!.isAfter(DateTime.now()), isTrue);
    });
  });
}
