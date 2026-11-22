import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/entities/pet_skills_entity.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/pet_traits.dart';
import 'package:mini_pou/shared_features/pet_species/domain/pet_species.dart';

void main() {
  group('species traits', () {
    test('only the crow is darkness and only the white dove is light', () {
      for (final s in PetSpecies.values) {
        final expected = switch (s) {
          PetSpecies.crow => PetType.darkness,
          PetSpecies.whiteDove => PetType.light,
          _ => PetType.elemental,
        };
        expect(s.type, expected, reason: s.name);
      }
    });

    test('element follows the habitat', () {
      expect(PetSpecies.cardinal.element, PetElement.fire);
      expect(PetSpecies.houseFinch.element, PetElement.fire);
      expect(PetSpecies.woodThrush.element, PetElement.water);
      expect(PetSpecies.crow.element, PetElement.earth);
      expect(PetSpecies.redRobin.element, PetElement.earth);
      expect(PetSpecies.hummingbird.element, PetElement.air);
      for (final s in PetSpecies.values) {
        expect(s.element, s.habitat.element, reason: s.name);
      }
    });

    test('birds are mostly air', () {
      final air = PetSpecies.values.where((s) => s.element == PetElement.air);
      expect(air.length, greaterThan(PetSpecies.values.length / 2 - 1));
    });
  });

  group('PetSkillsEntity', () {
    test('forSpecies copies the traits and starts at level 0', () {
      final skills = PetSkillsEntity.forSpecies(PetSpecies.crow);
      expect(skills.element, PetElement.earth);
      expect(skills.type, PetType.darkness);
      expect((skills.level, skills.xp), (0, 0));
    });

    test('round-trips through JSON', () {
      final skills = PetSkillsEntity.forSpecies(
        PetSpecies.stellersJay,
      ).copyWith(level: 3, xp: 7);
      expect(PetSkillsEntity.fromJson(skills.toJson()), skills);
    });

    test('unknown enum values in a save fall back instead of failing', () {
      final skills = PetSkillsEntity.fromJson({
        'element': 'plasma',
        'type': 'chaos',
      });
      expect(skills.element, PetElement.air);
      expect(skills.type, PetType.elemental);
    });
  });
}
