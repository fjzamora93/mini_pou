import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/features/defense/domain/combat_rules.dart';
import 'package:mini_pou/features/defense/domain/entities/enemy_entity.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/entities/skill_effect_entity.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/pet_skills_catalog.dart';

void main() {
  HitOutcome hit(EnemyEntity e, double damage, SkillEffectEntity effect) =>
      CombatRules.applyHit(e, damage: damage, effect: effect, petId: 'p');

  group('earth: plain hit', () {
    test('all damage lands at once, nothing else', () {
      final o = hit(
        EnemyEntity.spawn(3),
        1.2,
        PetSkillsCatalog.earthRock.effect,
      );
      expect(o.enemy.hp, closeTo(2.4, 1e-9));
      expect(o.knockback, 0);
      expect(o.enemy.isBurning, isFalse);
      expect(o.enemy.isSlowed, isFalse);
    });
  });

  group('fire: burn', () {
    final fire = PetSkillsCatalog.fireBurn.effect;

    test('no instant damage; 1.2x the hit is dealt over 3 seconds', () {
      var e = hit(EnemyEntity.spawn(10), 2, fire).enemy;
      expect(e.hp, closeTo(12, 1e-9), reason: 'nothing lands on impact');
      expect(e.isBurning, isTrue);

      e = e.tick(1.5);
      expect(e.hp, closeTo(12 - 1.2, 1e-9), reason: 'half of 2.4');
      e = e.tick(1.5);
      expect(e.hp, closeTo(12 - 2.4, 1e-9));
      expect(e.isBurning, isFalse);
      e = e.tick(5);
      expect(e.hp, closeTo(12 - 2.4, 1e-9), reason: 'burn is over');
    });

    test('burns stack', () {
      var e = EnemyEntity.spawn(10);
      e = hit(e, 1, fire).enemy;
      e = hit(e, 1, fire).enemy;
      expect(e.burns, hasLength(2));
      e = e.tick(3);
      expect(e.hp, closeTo(12 - 2.4, 1e-9));
    });

    test('a burn that finishes the enemy credits the pet that lit it', () {
      var e = CombatRules.applyHit(
        EnemyEntity.spawn(1),
        damage: 1,
        effect: fire,
        petId: 'kai',
      ).enemy;
      e = e.tick(3);
      expect(e.isDefeated, isTrue);
      expect(e.lastHitBy, 'kai');
    });
  });

  group('water: slow', () {
    final water = PetSkillsCatalog.waterSlow.effect as SlowEffect;

    test('damage lands and the enemy is slowed for a while', () {
      var e = hit(EnemyEntity.spawn(3), 1.2, water).enemy;
      expect(e.hp, closeTo(2.4, 1e-9));
      expect(e.speedFactor, water.speedFactor);
      e = e.tick(water.seconds - 0.1);
      expect(e.speedFactor, water.speedFactor);
      e = e.tick(0.2);
      expect(e.speedFactor, 1);
    });

    test('slows refresh instead of stacking', () {
      var e = hit(EnemyEntity.spawn(9), 0.1, water).enemy.tick(1.5);
      e = hit(e, 0.1, water).enemy;
      expect(e.speedFactor, water.speedFactor);
      expect(e.slowSecondsLeft, water.seconds);
    });
  });

  group('air: knockback', () {
    test('damage lands and the enemy is pushed back', () {
      final air = PetSkillsCatalog.airGust.effect as KnockbackEffect;
      final o = hit(EnemyEntity.spawn(3), 1.2, air);
      expect(o.enemy.hp, closeTo(2.4, 1e-9));
      expect(o.knockback, air.distance);
      expect(o.knockback, greaterThan(0));
    });
  });

  test('instant kills credit the pet that fired', () {
    final o = CombatRules.applyHit(
      EnemyEntity.spawn(1),
      damage: 5,
      effect: const DirectDamageEffect(),
      petId: 'rojo',
    );
    expect(o.enemy.isDefeated, isTrue);
    expect(o.enemy.lastHitBy, 'rojo');
  });
}
