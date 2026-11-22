import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/features/defense/domain/defense_rules.dart';
import 'package:mini_pou/features/defense/domain/entities/enemy_entity.dart';
import 'package:mini_pou/shared_features/pet_species/domain/pet_species.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_entity.dart';

void main() {
  group('EnemyEntity', () {
    test('has 1.2 HP per level', () {
      expect(EnemyEntity.spawn(1).hp, closeTo(1.2, 1e-9));
      expect(EnemyEntity.spawn(2).hp, closeTo(2.4, 1e-9));
      expect(EnemyEntity.spawn(3).hp, closeTo(3.6, 1e-9));
      expect(EnemyEntity.spawn(3).maxHp, closeTo(3.6, 1e-9));
    });

    test('level 1 is the lowest', () {
      expect(EnemyEntity.spawn(0).level, 1);
      expect(EnemyEntity.spawn(-4).level, 1);
    });

    test('takes damage until defeated', () {
      var e = EnemyEntity.spawn(2);
      e = e.hit(1);
      expect(e.isDefeated, isFalse);
      expect(e.healthFraction, closeTo(1.4 / 2.4, 1e-9));
      e = e.hit(1.4);
      expect(e.isDefeated, isTrue);
      expect(e.healthFraction, 0);
    });

    test('exact damage defeats it despite floating point', () {
      // 3.6 - 1.2 - 1.2 - 1.2 is not exactly 0 in binary floating point.
      var e = EnemyEntity.spawn(3);
      for (var i = 0; i < 3; i++) {
        e = e.hit(1.2);
      }
      expect(e.isDefeated, isTrue);
    });

    test('is worth 1 XP', () => expect(EnemyEntity.xpReward, 1));
  });

  group('combat rules', () {
    test('enemies start at level 1 and gain a level every 20 s', () {
      expect(DefenseRules.enemyLevel(0), 1);
      expect(DefenseRules.enemyLevel(19.9), 1);
      expect(DefenseRules.enemyLevel(20), 2);
      expect(DefenseRules.enemyLevel(65), 4);
    });

    test('pet damage grows with the pet level', () {
      expect(DefenseRules.petDamage(0), 1.0);
      expect(DefenseRules.petDamage(1), closeTo(1.2, 1e-9));
      expect(DefenseRules.petDamage(10), closeTo(12, 1e-9));
    });

    test('a pet of level N one-shots an enemy of level N', () {
      for (var n = 1; n <= 10; n++) {
        expect(
          EnemyEntity.spawn(n).hit(DefenseRules.petDamage(n)).isDefeated,
          isTrue,
          reason: 'level $n',
        );
        expect(
          EnemyEntity.spawn(n + 1).hit(DefenseRules.petDamage(n)).isDefeated,
          isFalse,
          reason: 'level ${n + 1} survives',
        );
      }
    });

    test('a level-0 pet needs two shots for a level-1 enemy', () {
      final once = EnemyEntity.spawn(1).hit(DefenseRules.petDamage(0));
      expect(once.isDefeated, isFalse);
      expect(once.hit(DefenseRules.petDamage(0)).isDefeated, isTrue);
    });
  });

  group('status in combat', () {
    final now = DateTime.utc(2026, 1, 1, 12);
    PetEntity pet({
      int level = 1,
      double energy = 100,
      double satiety = 100,
      double happiness = 100,
    }) {
      final p = PetEntity.newborn(
        name: 'A',
        species: PetSpecies.crow,
        now: now,
      );
      return p.copyWith(
        skills: p.skills.copyWith(level: level),
        status: p.status.copyWith(
          energy: energy,
          satiety: satiety,
          happiness: happiness,
        ),
      );
    }

    test('hunger scales the damage of a hit', () {
      expect(DefenseRules.shotDamage(pet(level: 2)), closeTo(2.4, 1e-9));
      expect(
        DefenseRules.shotDamage(pet(level: 2, satiety: 50)),
        closeTo(1.2, 1e-9),
      );
    });

    test('tiredness lengthens the time between shots', () {
      expect(DefenseRules.fireInterval(pet()), DefenseBalance.petFireInterval);
      expect(
        DefenseRules.fireInterval(pet(energy: 25)),
        closeTo(DefenseBalance.petFireInterval * 4, 1e-9),
      );
      expect(DefenseRules.fireInterval(pet(energy: 0)), isNull);
    });

    test('fun is the chance of hitting', () {
      final p = pet(happiness: 30);
      expect(DefenseRules.rollHit(p, 0.29), isTrue);
      expect(DefenseRules.rollHit(p, 0.31), isFalse);
      expect(DefenseRules.rollHit(pet(), 0.999), isTrue);
    });
  });
}
