import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_status_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/pet_combat_effects.dart';

void main() {
  final t0 = DateTime.utc(2026, 1, 1, 12);
  PetStatusEntity status({
    double energy = 100,
    double satiety = 100,
    double happiness = 100,
  }) => PetStatusEntity(
    satiety: satiety,
    energy: energy,
    happiness: happiness,
    hygiene: 100,
    lastUpdatedAt: t0,
  );

  test('a perfect status means 100% speed, damage and accuracy', () {
    final s = status();
    expect(PetCombatEffects.attackSpeed(s), 1);
    expect(PetCombatEffects.damage(s), 1);
    expect(PetCombatEffects.hitChance(s), 1);
    expect(PetCombatEffects.fireInterval(s, 0.7), 0.7);
  });

  test('tiredness slows attacks proportionally', () {
    final half = status(energy: 50);
    expect(PetCombatEffects.attackSpeed(half), 0.5);
    expect(PetCombatEffects.fireInterval(half, 0.7), closeTo(1.4, 1e-9));
  });

  test('an exhausted pet cannot attack', () {
    expect(PetCombatEffects.fireInterval(status(energy: 0), 0.7), isNull);
  });

  test('hunger scales damage, fun scales accuracy', () {
    expect(PetCombatEffects.damage(status(satiety: 25)), 0.25);
    expect(PetCombatEffects.hitChance(status(happiness: 70)), 0.7);
  });

  test('each effect only depends on its own bar', () {
    final s = status(energy: 10);
    expect(PetCombatEffects.damage(s), 1);
    expect(PetCombatEffects.hitChance(s), 1);
  });
}
