import '../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../shared_features/pet_status/domain/pet_combat_effects.dart';

/// Tunable numbers for the tower-defense mode. Distances are map pixels,
/// times are seconds.
abstract final class DefenseBalance {
  // Enemies
  static const baseEnemySpeed = 36.0;
  static const speedStepSeconds = 10.0;

  /// Each step adds this fraction of the base speed (linear growth).
  static const speedStepIncrease = 0.2;
  static const spawnInterval = 2.2;

  /// Enemies spawn at level 1 and spawn one level higher every this often.
  static const enemyLevelStepSeconds = 20.0;
  static const lives = 10;

  // Pet. Range is constant; fire rate, damage and accuracy are scaled by the
  // pet's status (see PetCombatEffects).
  /// Seconds between shots of a fully rested pet.
  static const petFireInterval = 0.7;
  static const petRange = 300.0;
  static const projectileSpeed = 650.0;

  /// Damage per shot for each pet level; equal to an enemy's HP per level,
  /// so a pet of level N defeats an enemy of level N in one hit.
  static const damagePerPetLevel = 1.2;

  /// Damage of a level-0 pet (it hasn't earned any level yet).
  static const levelZeroDamage = 1.0;

  /// Ground footprint that must lie entirely on grass.
  static const petFootprintRadius = 28.0;
}

/// Pure rules of a defense run, kept out of Flame so they're unit-testable.
abstract final class DefenseRules {
  /// 0 during the first [DefenseBalance.speedStepSeconds], then +1 per step.
  static int speedLevel(double elapsedSeconds) => elapsedSeconds <= 0
      ? 0
      : (elapsedSeconds / DefenseBalance.speedStepSeconds).floor();

  /// Current enemy speed (map px/s). Applies to every enemy on the map.
  static double enemySpeed(double elapsedSeconds) =>
      DefenseBalance.baseEnemySpeed *
      (1 + DefenseBalance.speedStepIncrease * speedLevel(elapsedSeconds));

  /// Level of the enemies spawning at [elapsedSeconds]: 1, then +1 every
  /// [DefenseBalance.enemyLevelStepSeconds].
  static int enemyLevel(double elapsedSeconds) =>
      1 +
      (elapsedSeconds <= 0
          ? 0
          : (elapsedSeconds / DefenseBalance.enemyLevelStepSeconds).floor());

  /// Base damage of a pet of [petLevel], before its status is applied.
  static double petDamage(int petLevel) => petLevel <= 0
      ? DefenseBalance.levelZeroDamage
      : DefenseBalance.damagePerPetLevel * petLevel;

  /// Speed multiplier shown to the player (1.0, 1.2, 1.4...).
  static double speedMultiplier(double elapsedSeconds) =>
      enemySpeed(elapsedSeconds) / DefenseBalance.baseEnemySpeed;

  /// Damage one hit of [pet] deals: level-based damage scaled by hunger.
  static double shotDamage(PetEntity pet) =>
      petDamage(pet.skills.level) * PetCombatEffects.damage(pet.status);

  /// Seconds until [pet] can shoot again; `null` when it's too tired.
  static double? fireInterval(PetEntity pet) =>
      PetCombatEffects.fireInterval(pet.status, DefenseBalance.petFireInterval);

  /// Whether a shot hits, given a uniform random [roll] in 0..1.
  static bool rollHit(PetEntity pet, double roll) =>
      roll < PetCombatEffects.hitChance(pet.status);
}
