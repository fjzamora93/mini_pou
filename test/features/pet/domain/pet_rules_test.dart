import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/features/pet/domain/pet.dart';
import 'package:mini_pou/features/pet/domain/pet_balance.dart';
import 'package:mini_pou/features/pet/domain/pet_rules.dart';

void main() {
  final t0 = DateTime.utc(2026, 1, 1, 12);
  Pet pet({bool sleeping = false, double stats = 80}) => Pet(
    name: 'Test',
    satiety: stats,
    energy: stats,
    happiness: stats,
    hygiene: stats,
    isSleeping: sleeping,
    lastUpdatedAt: t0,
  );

  group('advanceTo', () {
    test('decays proportionally to elapsed real time (5 min)', () {
      final result = PetRules.advanceTo(
        pet(),
        t0.add(const Duration(minutes: 5)),
      );
      const hours = 5 / 60 * PetBalance.timeScale;
      expect(
        result.satiety,
        closeTo(80 - PetBalance.satietyDecayPerHour * hours, 1e-9),
      );
      expect(
        result.hygiene,
        closeTo(80 - PetBalance.hygieneDecayPerHour * hours, 1e-9),
      );
      expect(result.lastUpdatedAt, t0.add(const Duration(minutes: 5)));
    });

    test('clock going backwards does not alter stats', () {
      final earlier = t0.subtract(const Duration(hours: 1));
      final result = PetRules.advanceTo(pet(), earlier);
      expect(result.satiety, 80);
      expect(result.lastUpdatedAt, earlier);
    });

    test('stats are clamped to 0 after a long absence', () {
      final result = PetRules.advanceTo(
        pet(),
        t0.add(const Duration(days: 30)),
      );
      for (final v in [
        result.satiety,
        result.energy,
        result.happiness,
        result.hygiene,
      ]) {
        expect(v, PetBalance.minStat);
      }
    });

    test('sleeping pet recovers energy and wakes up by itself offline', () {
      final tired = pet(sleeping: true).copyWith(energy: 10);
      final result = PetRules.advanceTo(
        tired,
        t0.add(const Duration(hours: 5)),
      );
      // Wakes up once energy hits 100, then spends the rest awake.
      const hoursToWake = 90 / PetBalance.sleepEnergyRegenPerHour;
      expect(result.isSleeping, isFalse);
      expect(
        result.energy,
        closeTo(100 - PetBalance.energyDecayPerHour * (5 - hoursToWake), 1e-6),
      );
    });

    test('one big offline jump ~= many live 1s ticks', () {
      final end = t0.add(const Duration(hours: 2));
      final offline = PetRules.advanceTo(pet(stats: 30), end);

      var live = pet(stats: 30);
      for (var s = 1; s <= 2 * 3600; s++) {
        live = PetRules.advanceTo(live, t0.add(Duration(seconds: s)));
      }
      expect(offline.satiety, closeTo(live.satiety, 1e-6));
      expect(offline.happiness, closeTo(live.happiness, 0.5));
    });
  });

  group('actions', () {
    test('feed increases satiety, capped at 100', () {
      final fed = PetRules.feed(pet(stats: 90));
      expect(fed.satiety, PetBalance.maxStat);
    });

    test('cannot feed, clean or play while sleeping', () {
      final asleep = pet(sleeping: true);
      expect(PetRules.feed(asleep), asleep);
      expect(PetRules.clean(asleep), asleep);
      expect(PetRules.canPlay(asleep), isFalse);
    });

    test('cannot play without energy', () {
      expect(PetRules.canPlay(pet().copyWith(energy: 5)), isFalse);
    });
  });

  test('JSON round-trip keeps UTC timestamp', () {
    final original = pet();
    final restored = Pet.fromJson(original.toJson());
    expect(restored, original);
    expect(restored.lastUpdatedAt.isUtc, isTrue);
  });
}
