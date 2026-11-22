import 'package:flutter/foundation.dart';

/// What a skill does to the enemy it hits, on top of (or instead of) the
/// plain damage. Pure data: combat rules (defense feature) interpret it.
@immutable
sealed class SkillEffectEntity {
  const SkillEffectEntity();
}

/// Plain hit: all the damage lands at once (earth).
final class DirectDamageEffect extends SkillEffectEntity {
  const DirectDamageEffect();

  @override
  bool operator ==(Object other) => other is DirectDamageEffect;

  @override
  int get hashCode => 0;
}

/// Burn (fire): no instant damage; the hit's damage × [damageMultiplier] is
/// dealt evenly over [seconds].
final class BurnEffect extends SkillEffectEntity {
  const BurnEffect({required this.damageMultiplier, required this.seconds});

  final double damageMultiplier;
  final double seconds;

  @override
  bool operator ==(Object other) =>
      other is BurnEffect &&
      other.damageMultiplier == damageMultiplier &&
      other.seconds == seconds;

  @override
  int get hashCode => Object.hash(damageMultiplier, seconds);
}

/// Slow (water): the target moves at [speedFactor] of its speed for
/// [seconds]. Damage lands normally.
final class SlowEffect extends SkillEffectEntity {
  const SlowEffect({required this.speedFactor, required this.seconds});

  final double speedFactor;
  final double seconds;

  @override
  bool operator ==(Object other) =>
      other is SlowEffect &&
      other.speedFactor == speedFactor &&
      other.seconds == seconds;

  @override
  int get hashCode => Object.hash(speedFactor, seconds);
}

/// Knockback (air): the target is pushed [distance] map px back along its
/// path. Damage lands normally.
final class KnockbackEffect extends SkillEffectEntity {
  const KnockbackEffect({required this.distance});

  final double distance;

  @override
  bool operator ==(Object other) =>
      other is KnockbackEffect && other.distance == distance;

  @override
  int get hashCode => distance.hashCode;
}
