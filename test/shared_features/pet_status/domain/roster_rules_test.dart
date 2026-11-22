import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/shared_features/pet_species/domain/pet_species.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_roster_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/roster_rules.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  PetRosterEntity adopt(PetRosterEntity r, PetSpecies species, String name) =>
      RosterRules.adopt(r, species: species, name: name, now: now);

  test('adopting needs a valid, unique name', () {
    final roster = adopt(PetRosterEntity.empty, PetSpecies.crow, '  Kai  ');
    expect(RosterRules.validateName(roster, ''), PetNameError.empty);
    expect(RosterRules.validateName(roster, '   '), PetNameError.empty);
    expect(RosterRules.validateName(roster, 'kai'), PetNameError.taken);
    expect(RosterRules.validateName(roster, 'x' * 17), PetNameError.tooLong);
    expect(RosterRules.validateName(roster, 'Luna'), isNull);
    expect(roster.active!.name, 'Kai');
  });

  test('a new pet starts at level 0, fully rested, and becomes active', () {
    var roster = adopt(PetRosterEntity.empty, PetSpecies.crow, 'Kai');
    roster = RosterRules.awardXp(roster, roster.active!.id, 10);
    expect(roster.active!.skills.level, 1);

    roster = adopt(roster, PetSpecies.whiteDove, 'Luz');
    expect(roster.pets, hasLength(2));
    expect(roster.active!.species, PetSpecies.whiteDove);
    expect(roster.active!.skills.level, 0);
    expect(roster.active!.status.energy, 100);
    expect(roster.bySpecies(PetSpecies.crow)!.skills.level, 1);
  });

  test('a species can only be raised once', () {
    final roster = adopt(PetRosterEntity.empty, PetSpecies.crow, 'Kai');
    expect(RosterRules.canAdopt(roster, PetSpecies.crow), isFalse);
    expect(() => adopt(roster, PetSpecies.crow, 'Otro'), throwsArgumentError);
  });

  test('switching back re-anchors the clock so resting pets do not decay', () {
    var roster = adopt(PetRosterEntity.empty, PetSpecies.crow, 'Kai');
    final crowId = roster.active!.id;
    roster = adopt(roster, PetSpecies.magpie, 'Uri');
    final later = now.add(const Duration(days: 2));
    roster = RosterRules.switchTo(roster, crowId, later);
    expect(roster.activeId, crowId);
    expect(roster.active!.status.lastUpdatedAt, later);
    expect(roster.active!.status.satiety, 80);
  });

  test('XP and tiredness can go to a resting pet', () {
    var roster = adopt(PetRosterEntity.empty, PetSpecies.crow, 'Kai');
    final crowId = roster.active!.id;
    roster = adopt(roster, PetSpecies.magpie, 'Uri');
    roster = RosterRules.awardXp(roster, crowId, 3);
    roster = RosterRules.spendEnergy(roster, crowId, 4);
    expect(roster.byId(crowId)!.skills.xp, 3);
    expect(roster.byId(crowId)!.status.energy, 96);
    expect(roster.active!.skills.xp, 0);
    expect(roster.active!.status.energy, 100);
  });

  test('roster round-trips through JSON', () {
    final roster = adopt(PetRosterEntity.empty, PetSpecies.crow, 'Kai');
    expect(PetRosterEntity.fromJson(roster.toJson()), roster);
  });

  test('newborn pets keep status and skills apart', () {
    final pet = PetEntity.newborn(
      name: 'A',
      species: PetSpecies.whiteDove,
      now: now,
    );
    expect(pet.status.lastUpdatedAt, now);
    expect(pet.skills.level, 0);
    expect(PetEntity.fromJson(pet.toJson()), pet);
  });
}
