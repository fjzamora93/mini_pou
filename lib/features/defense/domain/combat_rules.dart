import 'package:flutter/foundation.dart';

import '../../../shared_features/pet_skills/domain/entities/skill_effect_entity.dart';
import 'entities/enemy_entity.dart';

/// What a hit did: the enemy afterwards and how far it was pushed back.
@immutable
class HitOutcome {
  const HitOutcome(this.enemy, {this.knockback = 0});

  final EnemyEntity enemy;

  /// Map px the enemy must move back along its route (air).
  final double knockback;
}

/// How a skill's effect turns a hit into changes on the enemy.
abstract final class CombatRules {
  /// Applies a hit of [damage] carrying [effect], fired by pet [petId].
  /// [damage] already includes level and status (see DefenseRules.shotDamage).
  static HitOutcome applyHit(
    EnemyEntity enemy, {
    required double damage,
    required SkillEffectEntity effect,
    required String petId,
  }) => switch (effect) {
    DirectDamageEffect() => HitOutcome(enemy.hit(damage, byPetId: petId)),
    BurnEffect(:final damageMultiplier, :final seconds) => HitOutcome(
      enemy.burn(
        totalDamage: damage * damageMultiplier,
        seconds: seconds,
        byPetId: petId,
      ),
    ),
    SlowEffect(:final speedFactor, :final seconds) => HitOutcome(
      enemy
          .hit(damage, byPetId: petId)
          .slow(factor: speedFactor, seconds: seconds),
    ),
    KnockbackEffect(:final distance) => HitOutcome(
      enemy.hit(damage, byPetId: petId),
      knockback: distance,
    ),
  };
}
