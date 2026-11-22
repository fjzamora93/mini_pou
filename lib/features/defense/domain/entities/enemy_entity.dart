import 'package:flutter/foundation.dart';

import '../../../../shared_features/pet_skills/domain/pet_progression.dart';

/// A damage-over-time effect burning an enemy.
@immutable
class EnemyBurn {
  const EnemyBurn({
    required this.damagePerSecond,
    required this.secondsLeft,
    required this.byPetId,
  });

  final double damagePerSecond;
  final double secondsLeft;

  /// Pet that set it on fire: credited if the burn finishes the enemy.
  final String byPetId;

  @override
  bool operator ==(Object other) =>
      other is EnemyBurn &&
      other.damagePerSecond == damagePerSecond &&
      other.secondsLeft == secondsLeft &&
      other.byPetId == byPetId;

  @override
  int get hashCode => Object.hash(damagePerSecond, secondsLeft, byPetId);
}

/// One enemy of a defense run: its level, remaining hit points and the
/// effects currently on it (burns, slow). Immutable: every change returns a
/// new enemy.
@immutable
class EnemyEntity {
  const EnemyEntity._({
    required this.level,
    required this.hp,
    this.burns = const [],
    this.slowFactor = 1,
    this.slowSecondsLeft = 0,
    this.lastHitBy,
  });

  /// A fresh enemy of [level] (1 is the weakest) at full health.
  factory EnemyEntity.spawn(int level) {
    final l = level < EnemyEntity.minLevel ? EnemyEntity.minLevel : level;
    return EnemyEntity._(level: l, hp: maxHpFor(l));
  }

  static const minLevel = 1;

  /// Hit points per enemy level: level 1 = 1.2, level 2 = 2.4, level 3 = 3.6...
  static const hpPerLevel = 1.2;

  /// Every defeated enemy is worth this much XP to the pet that finished it.
  static const xpReward = PetProgression.xpPerEnemy;

  static double maxHpFor(int level) => hpPerLevel * level;

  final int level;
  final double hp;
  final List<EnemyBurn> burns;

  /// Speed multiplier while slowed (1 = normal speed).
  final double slowFactor;
  final double slowSecondsLeft;

  /// Pet whose damage landed last: the one credited for the kill.
  final String? lastHitBy;

  double get maxHp => maxHpFor(level);
  bool get isDefeated => hp <= _epsilon;
  bool get isBurning => burns.isNotEmpty;
  bool get isSlowed => slowSecondsLeft > 0;

  /// Multiplier to apply to the walking speed right now.
  double get speedFactor => isSlowed ? slowFactor : 1;

  /// Remaining health, 0..1.
  double get healthFraction => (hp / maxHp).clamp(0.0, 1.0);

  EnemyEntity _copy({
    double? hp,
    List<EnemyBurn>? burns,
    double? slowFactor,
    double? slowSecondsLeft,
    String? lastHitBy,
  }) => EnemyEntity._(
    level: level,
    hp: hp ?? this.hp,
    burns: burns ?? this.burns,
    slowFactor: slowFactor ?? this.slowFactor,
    slowSecondsLeft: slowSecondsLeft ?? this.slowSecondsLeft,
    lastHitBy: lastHitBy ?? this.lastHitBy,
  );

  /// Instant damage.
  EnemyEntity hit(double damage, {String? byPetId}) =>
      damage <= 0 ? this : _copy(hp: hp - damage, lastHitBy: byPetId);

  /// Sets it on fire: [totalDamage] dealt evenly over [seconds]. Burns stack.
  EnemyEntity burn({
    required double totalDamage,
    required double seconds,
    required String byPetId,
  }) {
    if (totalDamage <= 0 || seconds <= 0) return this;
    return _copy(
      burns: [
        ...burns,
        EnemyBurn(
          damagePerSecond: totalDamage / seconds,
          secondsLeft: seconds,
          byPetId: byPetId,
        ),
      ],
    );
  }

  /// Slows it to [factor] of its speed for [seconds]. Slows don't stack:
  /// the strongest factor and the longest time win.
  EnemyEntity slow({required double factor, required double seconds}) {
    if (seconds <= 0 || factor >= 1) return this;
    return _copy(
      slowFactor: isSlowed && slowFactor < factor ? slowFactor : factor,
      slowSecondsLeft: slowSecondsLeft > seconds ? slowSecondsLeft : seconds,
    );
  }

  /// Lets [dt] seconds pass: burns deal their damage, effects wear off.
  EnemyEntity tick(double dt) {
    if (dt <= 0 || (!isBurning && !isSlowed)) return this;
    var damage = 0.0;
    String? burner;
    final remaining = <EnemyBurn>[];
    for (final b in burns) {
      final t = dt < b.secondsLeft ? dt : b.secondsLeft;
      damage += b.damagePerSecond * t;
      burner = b.byPetId;
      if (b.secondsLeft - t > _epsilon) {
        remaining.add(
          EnemyBurn(
            damagePerSecond: b.damagePerSecond,
            secondsLeft: b.secondsLeft - t,
            byPetId: b.byPetId,
          ),
        );
      }
    }
    final slowLeft = slowSecondsLeft - dt;
    return _copy(
      hp: hp - damage,
      burns: remaining,
      slowSecondsLeft: slowLeft > 0 ? slowLeft : 0,
      slowFactor: slowLeft > 0 ? slowFactor : 1,
      lastHitBy: burner,
    );
  }

  // 1.2 * n is not exact in floating point: 3.6 - 1.2 * 3 can be 4e-16.
  static const _epsilon = 1e-9;

  @override
  bool operator ==(Object other) =>
      other is EnemyEntity &&
      other.level == level &&
      other.hp == hp &&
      listEquals(other.burns, burns) &&
      other.slowFactor == slowFactor &&
      other.slowSecondsLeft == slowSecondsLeft &&
      other.lastHitBy == lastHitBy;

  @override
  int get hashCode => Object.hash(
    level,
    hp,
    Object.hashAll(burns),
    slowFactor,
    slowSecondsLeft,
    lastHitBy,
  );

  @override
  String toString() =>
      'EnemyEntity(level: $level, hp: $hp, burns: ${burns.length}, '
      'slow: $slowFactor x ${slowSecondsLeft}s)';
}
