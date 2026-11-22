import 'entities/pet_status_entity.dart';
import 'pet_status_balance.dart';

/// How a pet's status affects its performance in combat. Every effect is
/// proportional to its bar: 100% bar = 100% effect, 50% bar = 50%...
///
/// | status            | combat effect                     |
/// |-------------------|-----------------------------------|
/// | energy (tired)    | attack speed (shots per second)   |
/// | satiety (hunger)  | damage per hit                    |
/// | happiness (fun)   | chance of hitting the target      |
abstract final class PetCombatEffects {
  static double _fraction(double stat) =>
      (stat / PetStatusBalance.maxStat).clamp(0.0, 1.0);

  /// Multiplier of the attack speed. 0 = too tired to attack at all.
  static double attackSpeed(PetStatusEntity status) => _fraction(status.energy);

  /// Multiplier of the damage dealt by each hit.
  static double damage(PetStatusEntity status) => _fraction(status.satiety);

  /// Probability (0..1) that a shot hits its target.
  static double hitChance(PetStatusEntity status) =>
      _fraction(status.happiness);

  /// Time between two shots for a pet whose base interval is [baseInterval]
  /// seconds; `null` when it's too tired to shoot.
  static double? fireInterval(PetStatusEntity status, double baseInterval) {
    final speed = attackSpeed(status);
    return speed <= 0 ? null : baseInterval / speed;
  }
}
