import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/features/pet/domain/pet.dart';
import 'package:mini_pou/features/pet/domain/pet_rules.dart';
import 'package:mini_pou/features/pet/domain/pet_species.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  test('newborn uses the fallback species', () {
    expect(Pet.newborn(name: 'A', now: now).species, PetSpecies.fallback);
  });

  test('changeSpecies only changes the species', () {
    final pet = Pet.newborn(name: 'A', now: now);
    final next = PetRules.changeSpecies(pet, PetSpecies.crow);
    expect(next.species, PetSpecies.crow);
    expect(next.copyWith(species: pet.species), pet);
  });

  test('round-trips through JSON', () {
    final pet = Pet.newborn(
      name: 'A',
      now: now,
    ).copyWith(species: PetSpecies.stellersJay);
    expect(Pet.fromJson(pet.toJson()), pet);
  });

  test('saves without species (or an unknown one) load with fallback', () {
    final json = Pet.newborn(name: 'A', now: now).toJson();
    expect(
      Pet.fromJson({...json}..remove('species')).species,
      PetSpecies.fallback,
    );
    expect(
      Pet.fromJson({...json, 'species': 'dragon'}).species,
      PetSpecies.fallback,
    );
  });
}
