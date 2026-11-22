import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/pet_traits.dart';
import 'package:mini_pou/shared_features/pet_species/domain/pet_species.dart';
import 'package:mini_pou/shared_features/pet_status/data/local_pet_repository.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_roster_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/roster_rules.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);
  final ms = now.millisecondsSinceEpoch;

  Map<String, dynamic> flatStats() => {
    'satiety': 10.0,
    'energy': 20.0,
    'happiness': 30.0,
    'hygiene': 40.0,
    'isSleeping': false,
    'lastUpdatedAt': ms,
  };

  test('v1 single-pet saves migrate into a one-pet roster at level 0', () {
    final roster = LocalPetRepository.decode({
      'v': 1,
      'pet': {'name': 'Blob', 'species': 'crow', ...flatStats()},
    })!;
    final pet = roster.active!;
    expect(roster.pets, hasLength(1));
    expect(pet.name, 'Blob');
    expect(pet.species, PetSpecies.crow);
    expect(pet.skills.element, PetElement.earth);
    expect(pet.skills.type, PetType.darkness);
    expect((pet.skills.level, pet.skills.xp), (0, 0));
    expect(pet.status.satiety, 10);
    expect(pet.status.lastUpdatedAt, now);
  });

  test('v1 saves without species use the fallback bird', () {
    final roster = LocalPetRepository.decode({
      'v': 1,
      'pet': {'name': 'Blob', ...flatStats()},
    })!;
    expect(roster.active!.species, PetSpecies.fallback);
  });

  test('v2 flat pets are split into status and skills', () {
    final roster = LocalPetRepository.decode({
      'v': 2,
      'roster': {
        'activeId': 'cardinal-1',
        'pets': [
          {
            'id': 'cardinal-1',
            'name': 'FIre',
            'species': 'cardinal',
            'element': 'fire',
            'type': 'elemental',
            'level': 1,
            'xp': 16,
            ...flatStats(),
          },
        ],
      },
    })!;
    final pet = roster.active!;
    expect(pet.name, 'FIre');
    expect((pet.skills.level, pet.skills.xp), (1, 16));
    expect(pet.skills.element, PetElement.fire);
    expect(pet.status.energy, 20);
    expect(pet.status.hygiene, 40);
  });

  test('v3 round-trips', () {
    final roster = RosterRules.adopt(
      PetRosterEntity.empty,
      species: PetSpecies.whiteDove,
      name: 'Luz',
      now: now,
    );
    expect(
      LocalPetRepository.decode(LocalPetRepository.encode(roster)),
      roster,
    );
  });

  test('unknown versions are rejected', () {
    expect(LocalPetRepository.decode({'v': 99}), isNull);
  });
}
