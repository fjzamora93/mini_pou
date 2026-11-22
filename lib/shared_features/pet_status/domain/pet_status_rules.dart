import 'dart:math' as math;

import 'entities/pet_status_entity.dart';
import 'pet_status_balance.dart';

/// Pure status rules: `status in -> status out`. No Flutter, no I/O, no
/// clock. The same [advanceTo] powers both the live tick and the offline
/// catch-up.
abstract final class PetStatusRules {
  // ---------------------------------------------------------------------------
  // Time
  // ---------------------------------------------------------------------------

  /// Simulates everything that happened between `pet.lastUpdatedAt` and [now].
  static PetStatusEntity advanceTo(PetStatusEntity pet, DateTime now) {
    var elapsed = now.difference(pet.lastUpdatedAt);

    // Clock moved backwards (manual change, NTP correction...): don't
    // "un-decay" stats, just re-anchor the timestamp.
    if (elapsed <= Duration.zero) return pet.copyWith(lastUpdatedAt: now);

    if (elapsed > PetStatusBalance.maxOfflineCatchUp) {
      elapsed = PetStatusBalance.maxOfflineCatchUp;
    }

    var current = pet;
    var remainingMs = elapsed.inMilliseconds;
    final stepMs = PetStatusBalance.simulationStep.inMilliseconds;
    while (remainingMs > 0) {
      final chunkMs = math.min(stepMs, remainingMs);
      current = _step(current, chunkMs / Duration.millisecondsPerHour);
      remainingMs -= chunkMs;
    }
    return current.copyWith(lastUpdatedAt: now);
  }

  static PetStatusEntity _step(PetStatusEntity pet, double realHours) {
    final h = realHours * PetStatusBalance.timeScale;

    final neglected = [
      pet.satiety,
      pet.energy,
      pet.hygiene,
    ].where((v) => v < PetStatusBalance.neglectThreshold).length;
    final happinessRate =
        PetStatusBalance.happinessDecayPerHour *
        (1 + neglected * PetStatusBalance.neglectHappinessPenalty);

    if (pet.isSleeping) {
      const m = PetStatusBalance.sleepDecayMultiplier;
      final next = pet.copyWith(
        energy: _clamp(
          pet.energy + PetStatusBalance.sleepEnergyRegenPerHour * h,
        ),
        satiety: _clamp(
          pet.satiety - PetStatusBalance.satietyDecayPerHour * m * h,
        ),
        hygiene: _clamp(
          pet.hygiene - PetStatusBalance.hygieneDecayPerHour * m * h,
        ),
        happiness: _clamp(pet.happiness - happinessRate * m * h),
      );
      // Fully rested pets wake up on their own (also while offline).
      return next.energy >= PetStatusBalance.maxStat
          ? next.copyWith(isSleeping: false)
          : next;
    }

    return pet.copyWith(
      satiety: _clamp(pet.satiety - PetStatusBalance.satietyDecayPerHour * h),
      hygiene: _clamp(pet.hygiene - PetStatusBalance.hygieneDecayPerHour * h),
      happiness: _clamp(pet.happiness - happinessRate * h),
    );
  }

  // ---------------------------------------------------------------------------
  // Player actions. `canX` lets the UI disable buttons; `x` is a no-op when
  // the action is not allowed, so callers can't corrupt the state.
  // ---------------------------------------------------------------------------

  static bool canFeed(PetStatusEntity pet) =>
      !pet.isSleeping && pet.satiety < PetStatusBalance.maxStat;

  static PetStatusEntity feed(PetStatusEntity pet) => !canFeed(pet)
      ? pet
      : pet.copyWith(
          satiety: _clamp(pet.satiety + PetStatusBalance.feedSatiety),
          hygiene: _clamp(pet.hygiene - PetStatusBalance.feedHygieneCost),
        );

  static PetStatusEntity toggleSleep(PetStatusEntity pet) =>
      pet.copyWith(isSleeping: !pet.isSleeping);

  static bool canClean(PetStatusEntity pet) =>
      !pet.isSleeping && pet.hygiene < PetStatusBalance.maxStat;

  static PetStatusEntity clean(PetStatusEntity pet) => !canClean(pet)
      ? pet
      : pet.copyWith(
          hygiene: _clamp(pet.hygiene + PetStatusBalance.cleanHygiene),
        );

  /// Tapping the pet: the way to make it happier.
  static PetStatusEntity cuddle(PetStatusEntity pet) => pet.isSleeping
      ? pet
      : pet.copyWith(
          happiness: _clamp(pet.happiness + PetStatusBalance.cuddleHappiness),
        );

  // ---------------------------------------------------------------------------
  // Combat
  // ---------------------------------------------------------------------------

  /// Tiredness from fighting: the only way energy goes down.
  static PetStatusEntity spendEnergy(PetStatusEntity pet, double amount) =>
      amount <= 0 ? pet : pet.copyWith(energy: _clamp(pet.energy - amount));

  static double _clamp(double v) =>
      v.clamp(PetStatusBalance.minStat, PetStatusBalance.maxStat).toDouble();
}
