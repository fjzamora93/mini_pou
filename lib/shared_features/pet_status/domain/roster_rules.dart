import '../../pet_skills/domain/pet_progression.dart';
import '../../pet_species/domain/pet_species.dart';
import 'entities/pet_entity.dart';
import 'entities/pet_roster_entity.dart';
import 'entities/pet_status_entity.dart';
import 'pet_status_rules.dart';

/// Why a name can't be used. The UI maps each case to a message.
enum PetNameError { empty, tooLong, taken }

/// Pure rules over the whole collection of raised pets.
///
/// - One pet per species. Picking a species you've never raised adopts a new
///   pet at level 0 and it must be given a name.
/// - Only the active pet lives in real time. The others rest: their stats
///   are frozen while inactive and resume when they're picked again.
abstract final class RosterRules {
  static const maxNameLength = 16;

  static String normalizeName(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// `null` when [raw] is a valid name for a new pet in [roster].
  static PetNameError? validateName(PetRosterEntity roster, String raw) {
    final name = normalizeName(raw);
    if (name.isEmpty) return PetNameError.empty;
    if (name.length > maxNameLength) return PetNameError.tooLong;
    final lower = name.toLowerCase();
    if (roster.pets.any((p) => p.name.toLowerCase() == lower)) {
      return PetNameError.taken;
    }
    return null;
  }

  static bool canAdopt(PetRosterEntity roster, PetSpecies species) =>
      !roster.hasRaised(species);

  /// Adds a new level-0 pet of [species] called [name] and makes it active.
  /// Throws [ArgumentError] if the species is already raised or the name is
  /// invalid: callers must check [canAdopt] / [validateName] first.
  static PetRosterEntity adopt(
    PetRosterEntity roster, {
    required PetSpecies species,
    required String name,
    required DateTime now,
  }) {
    if (!canAdopt(roster, species)) {
      throw ArgumentError.value(species, 'species', 'already raised');
    }
    final error = validateName(roster, name);
    if (error != null) throw ArgumentError.value(name, 'name', error.name);
    final pet = PetEntity.newborn(
      name: normalizeName(name),
      species: species,
      now: now,
    );
    return roster.copyWith(pets: [...roster.pets, pet], activeId: pet.id);
  }

  /// Makes the pet [petId] the active one. Its clock is re-anchored to [now]
  /// so the time it spent resting doesn't decay its stats.
  static PetRosterEntity switchTo(
    PetRosterEntity roster,
    String petId,
    DateTime now,
  ) {
    final pet = roster.byId(petId);
    if (pet == null || petId == roster.activeId) return roster;
    return roster
        .replace(pet.copyWith(status: pet.status.copyWith(lastUpdatedAt: now)))
        .copyWith(activeId: petId);
  }

  /// Applies [change] to the active pet (no-op without one).
  static PetRosterEntity updateActive(
    PetRosterEntity roster,
    PetEntity Function(PetEntity) change,
  ) {
    final active = roster.active;
    return active == null ? roster : roster.replace(change(active));
  }

  /// Applies [change] to the status of the active pet.
  static PetRosterEntity updateActiveStatus(
    PetRosterEntity roster,
    PetStatusEntity Function(PetStatusEntity) change,
  ) => updateActive(roster, (p) => p.copyWith(status: change(p.status)));

  /// Gives [amount] XP to pet [petId] (any pet, active or resting).
  static PetRosterEntity awardXp(
    PetRosterEntity roster,
    String petId,
    int amount,
  ) {
    final pet = roster.byId(petId);
    return pet == null
        ? roster
        : roster.replace(
            pet.copyWith(skills: PetProgression.gainXp(pet.skills, amount)),
          );
  }

  /// PetEntity [petId] gets tired by fighting (any pet, active or resting).
  static PetRosterEntity spendEnergy(
    PetRosterEntity roster,
    String petId,
    double amount,
  ) {
    final pet = roster.byId(petId);
    return pet == null
        ? roster
        : roster.replace(
            pet.copyWith(
              status: PetStatusRules.spendEnergy(pet.status, amount),
            ),
          );
  }
}
