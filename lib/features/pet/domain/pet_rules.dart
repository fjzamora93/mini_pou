import 'dart:math' as math;

import 'pet.dart';
import 'pet_balance.dart';
import 'pet_species.dart';

/// Pure business rules: `Pet in -> Pet out`. No Flutter, no I/O, no clock.
/// The same [advanceTo] powers both the live tick and the offline catch-up.
abstract final class PetRules {
  // ---------------------------------------------------------------------------
  // Time
  // ---------------------------------------------------------------------------

  /// Simulates everything that happened between `pet.lastUpdatedAt` and [now].
  static Pet advanceTo(Pet pet, DateTime now) {
    var elapsed = now.difference(pet.lastUpdatedAt);

    // Clock moved backwards (manual change, NTP correction...): don't
    // "un-decay" stats, just re-anchor the timestamp.
    if (elapsed <= Duration.zero) return pet.copyWith(lastUpdatedAt: now);

    if (elapsed > PetBalance.maxOfflineCatchUp) {
      elapsed = PetBalance.maxOfflineCatchUp;
    }

    var current = pet;
    var remainingMs = elapsed.inMilliseconds;
    final stepMs = PetBalance.simulationStep.inMilliseconds;
    while (remainingMs > 0) {
      final chunkMs = math.min(stepMs, remainingMs);
      current = _step(current, chunkMs / Duration.millisecondsPerHour);
      remainingMs -= chunkMs;
    }
    return current.copyWith(lastUpdatedAt: now);
  }

  static Pet _step(Pet pet, double realHours) {
    final h = realHours * PetBalance.timeScale;

    final neglected = [
      pet.satiety,
      pet.energy,
      pet.hygiene,
    ].where((v) => v < PetBalance.neglectThreshold).length;
    final happinessRate =
        PetBalance.happinessDecayPerHour *
        (1 + neglected * PetBalance.neglectHappinessPenalty);

    if (pet.isSleeping) {
      const m = PetBalance.sleepDecayMultiplier;
      final next = pet.copyWith(
        energy: _clamp(pet.energy + PetBalance.sleepEnergyRegenPerHour * h),
        satiety: _clamp(pet.satiety - PetBalance.satietyDecayPerHour * m * h),
        hygiene: _clamp(pet.hygiene - PetBalance.hygieneDecayPerHour * m * h),
        happiness: _clamp(pet.happiness - happinessRate * m * h),
      );
      // Fully rested pets wake up on their own (also while offline).
      return next.energy >= PetBalance.maxStat
          ? next.copyWith(isSleeping: false)
          : next;
    }

    return pet.copyWith(
      satiety: _clamp(pet.satiety - PetBalance.satietyDecayPerHour * h),
      energy: _clamp(pet.energy - PetBalance.energyDecayPerHour * h),
      hygiene: _clamp(pet.hygiene - PetBalance.hygieneDecayPerHour * h),
      happiness: _clamp(pet.happiness - happinessRate * h),
    );
  }

  // ---------------------------------------------------------------------------
  // Player actions. `canX` lets the UI disable buttons; `x` is a no-op when
  // the action is not allowed, so callers can't corrupt the state.
  // ---------------------------------------------------------------------------

  static bool canFeed(Pet pet) =>
      !pet.isSleeping && pet.satiety < PetBalance.maxStat;

  static Pet feed(Pet pet) => !canFeed(pet)
      ? pet
      : pet.copyWith(
          satiety: _clamp(pet.satiety + PetBalance.feedSatiety),
          hygiene: _clamp(pet.hygiene - PetBalance.feedHygieneCost),
        );

  static Pet toggleSleep(Pet pet) => pet.copyWith(isSleeping: !pet.isSleeping);

  static bool canClean(Pet pet) =>
      !pet.isSleeping && pet.hygiene < PetBalance.maxStat;

  static Pet clean(Pet pet) => !canClean(pet)
      ? pet
      : pet.copyWith(hygiene: _clamp(pet.hygiene + PetBalance.cleanHygiene));

  /// Cosmetic: swapping the creature never touches its stats.
  static Pet changeSpecies(Pet pet, PetSpecies species) =>
      pet.copyWith(species: species);

  static Pet cuddle(Pet pet) => pet.isSleeping
      ? pet
      : pet.copyWith(
          happiness: _clamp(pet.happiness + PetBalance.cuddleHappiness),
        );

  static bool canPlay(Pet pet) =>
      !pet.isSleeping && pet.energy >= PetBalance.minEnergyToPlay;

  static Pet rewardCatch(Pet pet) => pet.copyWith(
    happiness: _clamp(pet.happiness + PetBalance.happinessPerCatch),
  );

  static Pet finishMinigame(Pet pet) => pet.copyWith(
    energy: _clamp(pet.energy - PetBalance.minigameEnergyCost),
    satiety: _clamp(pet.satiety - PetBalance.minigameSatietyCost),
  );

  static double _clamp(double v) =>
      v.clamp(PetBalance.minStat, PetBalance.maxStat).toDouble();
}
