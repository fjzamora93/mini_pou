import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_status_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/pet_mood.dart';
import 'package:mini_pou/shared_features/pet_status/domain/pet_status_balance.dart';
import 'package:mini_pou/shared_features/pet_status/domain/pet_status_rules.dart';

void main() {
  final t0 = DateTime.utc(2026, 1, 1, 12);
  PetStatusEntity status({bool sleeping = false, double stats = 80}) =>
      PetStatusEntity(
        satiety: stats,
        energy: stats,
        happiness: stats,
        hygiene: stats,
        isSleeping: sleeping,
        lastUpdatedAt: t0,
      );

  group('advanceTo', () {
    test('decays proportionally to elapsed real time (5 min)', () {
      final result = PetStatusRules.advanceTo(
        status(),
        t0.add(const Duration(minutes: 5)),
      );
      const hours = 5 / 60 * PetStatusBalance.timeScale;
      expect(
        result.satiety,
        closeTo(80 - PetStatusBalance.satietyDecayPerHour * hours, 1e-9),
      );
      expect(
        result.hygiene,
        closeTo(80 - PetStatusBalance.hygieneDecayPerHour * hours, 1e-9),
      );
      expect(result.lastUpdatedAt, t0.add(const Duration(minutes: 5)));
    });

    test('energy (tiredness) never drops with time, only by fighting', () {
      final result = PetStatusRules.advanceTo(
        status(stats: 60),
        t0.add(const Duration(days: 3)),
      );
      expect(result.energy, 60);
      expect(result.satiety, PetStatusBalance.minStat);
    });

    test('clock going backwards does not alter stats', () {
      final earlier = t0.subtract(const Duration(hours: 1));
      final result = PetStatusRules.advanceTo(status(), earlier);
      expect(result.satiety, 80);
      expect(result.lastUpdatedAt, earlier);
    });

    test('decaying stats are clamped to 0 after a long absence', () {
      final result = PetStatusRules.advanceTo(
        status(),
        t0.add(const Duration(days: 30)),
      );
      for (final v in [result.satiety, result.happiness, result.hygiene]) {
        expect(v, PetStatusBalance.minStat);
      }
    });

    test('a sleeping pet is fully rested in ~10 seconds and wakes up', () {
      var s = status(sleeping: true).copyWith(energy: 0);
      for (var sec = 1; sec <= 9; sec++) {
        s = PetStatusRules.advanceTo(s, t0.add(Duration(seconds: sec)));
      }
      expect(s.isSleeping, isTrue);
      expect(s.energy, closeTo(90, 1e-6));
      s = PetStatusRules.advanceTo(s, t0.add(const Duration(seconds: 10)));
      expect(s.energy, PetStatusBalance.maxStat);
      expect(s.isSleeping, isFalse);
    });

    test('one big offline jump ~= many live 1s ticks', () {
      final end = t0.add(const Duration(hours: 2));
      final offline = PetStatusRules.advanceTo(status(stats: 30), end);

      var live = status(stats: 30);
      for (var s = 1; s <= 2 * 3600; s++) {
        live = PetStatusRules.advanceTo(live, t0.add(Duration(seconds: s)));
      }
      expect(offline.satiety, closeTo(live.satiety, 1e-6));
      expect(offline.happiness, closeTo(live.happiness, 0.5));
    });
  });

  group('actions', () {
    test('feed increases satiety, capped at 100', () {
      final fed = PetStatusRules.feed(status(stats: 90));
      expect(fed.satiety, PetStatusBalance.maxStat);
    });

    test('cannot feed, clean or be cuddled while sleeping', () {
      final asleep = status(sleeping: true);
      expect(PetStatusRules.feed(asleep), asleep);
      expect(PetStatusRules.clean(asleep), asleep);
      expect(PetStatusRules.cuddle(asleep), asleep);
    });

    test('tapping (cuddle) raises happiness, capped at 100', () {
      expect(
        PetStatusRules.cuddle(status(stats: 50)).happiness,
        50 + PetStatusBalance.cuddleHappiness,
      );
      expect(
        PetStatusRules.cuddle(status(stats: 100)).happiness,
        PetStatusBalance.maxStat,
      );
    });

    test('fighting spends energy, never below 0', () {
      expect(PetStatusRules.spendEnergy(status(), 1).energy, 79);
      expect(PetStatusRules.spendEnergy(status(stats: 0.5), 1).energy, 0);
      expect(PetStatusRules.spendEnergy(status(), -5), status());
    });
  });

  test('mood reflects the status', () {
    expect(status(sleeping: true).mood, PetMood.sleeping);
    expect(status().copyWith(satiety: 10).mood, PetMood.hungry);
    expect(status().copyWith(energy: 10).mood, PetMood.tired);
    expect(status(stats: 90).mood, PetMood.happy);
  });

  test('JSON round-trip keeps UTC timestamp', () {
    final original = status();
    final restored = PetStatusEntity.fromJson(original.toJson());
    expect(restored, original);
    expect(restored.lastUpdatedAt.isUtc, isTrue);
  });
}
