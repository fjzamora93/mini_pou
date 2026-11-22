/// Tunable numbers for the tower-defense mode. Distances are map pixels,
/// times are seconds.
abstract final class DefenseBalance {
  // Enemies
  static const baseEnemySpeed = 36.0;
  static const speedStepSeconds = 10.0;

  /// Each step adds this fraction of the base speed (linear growth).
  static const speedStepIncrease = 0.2;
  static const enemyHp = 3;
  static const spawnInterval = 2.2;
  static const lives = 10;

  // Pet (constant for the whole run)
  static const petFireInterval = 0.7;
  static const petRange = 300.0;
  static const projectileSpeed = 650.0;
  static const projectileDamage = 1;

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

  /// Speed multiplier shown to the player (1.0, 1.2, 1.4...).
  static double speedMultiplier(double elapsedSeconds) =>
      enemySpeed(elapsedSeconds) / DefenseBalance.baseEnemySpeed;
}
