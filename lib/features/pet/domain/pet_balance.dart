/// Game-design tuning values. Pure data, no logic: tweak freely.
abstract final class PetBalance {
  static const double minStat = 0;
  static const double maxStat = 100;

  /// Multiplies the passage of time for every rule. Bump it (e.g. 60) to
  /// watch an hour of decay per minute while prototyping.
  static const double timeScale = 1;

  // Decay per real hour while awake.
  static const double satietyDecayPerHour = 18;
  static const double energyDecayPerHour = 10;
  static const double happinessDecayPerHour = 12;
  static const double hygieneDecayPerHour = 8;

  // While sleeping energy recovers and everything else slows down.
  static const double sleepEnergyRegenPerHour = 40;
  static const double sleepDecayMultiplier = 0.4;

  /// Any stat under this is "neglected" and accelerates happiness decay.
  static const double neglectThreshold = 20;
  static const double neglectHappinessPenalty = 0.5; // +50% per neglected stat

  // Actions.
  static const double feedSatiety = 25;
  static const double feedHygieneCost = 3;
  static const double cleanHygiene = 45;
  static const double cuddleHappiness = 2;
  static const double minEnergyToPlay = 10;

  // Minigame.
  static const double minigameDurationSeconds = 15;
  static const double happinessPerCatch = 3;
  static const double minigameEnergyCost = 8;
  static const double minigameSatietyCost = 4;

  /// Offline catch-up granularity and cap. Simulating in fixed steps keeps
  /// offline results identical to what live ticks would have produced, even
  /// with non-linear rules (neglect penalties, auto wake-up...).
  static const Duration simulationStep = Duration(minutes: 1);
  static const Duration maxOfflineCatchUp = Duration(days: 7);
}
