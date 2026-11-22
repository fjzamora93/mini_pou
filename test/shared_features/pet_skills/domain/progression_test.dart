import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/entities/pet_skill_entity.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/entities/pet_skills_entity.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/entities/skill_effect_entity.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/pet_progression.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/pet_skills_catalog.dart';
import 'package:mini_pou/shared_features/pet_skills/domain/pet_traits.dart';
import 'package:mini_pou/shared_features/pet_species/domain/pet_species.dart';

void main() {
  PetSkillsEntity skillsOf(PetSpecies s) => PetSkillsEntity.forSpecies(s);

  group('PetProgression', () {
    test('level n -> n+1 costs 10*(n+1) XP, 0 at the cap', () {
      expect(PetProgression.xpToNextLevel(0), 10);
      expect(PetProgression.xpToNextLevel(1), 20);
      expect(PetProgression.xpToNextLevel(9), 100);
      expect(PetProgression.xpToNextLevel(10), 0);
    });

    test('XP accumulates, then levels up and resets to 0', () {
      var s = skillsOf(PetSpecies.cardinal);
      for (var i = 0; i < 9; i++) {
        s = PetProgression.gainXp(s, 1);
      }
      expect((s.level, s.xp), (0, 9));
      s = PetProgression.gainXp(s, 1);
      expect((s.level, s.xp), (1, 0));
      s = PetProgression.gainXp(s, 19);
      expect((s.level, s.xp), (1, 19));
      s = PetProgression.gainXp(s, 1);
      expect((s.level, s.xp), (2, 0));
    });

    test(
      'one enemy at a time reaches level 10 after 550 kills, then stops',
      () {
        var s = skillsOf(PetSpecies.cardinal);
        var kills = 0;
        while (!PetProgression.isMaxLevel(s)) {
          s = PetProgression.gainXp(s, PetProgression.xpPerEnemy);
          kills++;
        }
        expect(kills, 550); // 10 + 20 + ... + 100
        expect(s.level, 10);
        expect(PetProgression.gainXp(s, 5), s);
        expect(PetProgression.levelProgress(s), 1);
      },
    );
  });

  group('PetSkillsCatalog', () {
    const fireball = PetSkillEntity(
      id: 'fireball',
      name: 'Bola de fuego',
      description: '',
      unlockLevel: 2,
    );
    const shadow = PetSkillEntity(
      id: 'shadow',
      name: 'Sombra',
      description: '',
      unlockLevel: 0,
    );
    const crowOnly = PetSkillEntity(
      id: 'murder',
      name: 'Bandada',
      description: '',
      unlockLevel: 5,
    );
    const elementTable = {
      PetElement.fire: [fireball],
    };
    const typeTable = {
      PetType.darkness: [shadow],
    };
    const speciesTypeTable = {
      (PetSpecies.crow, PetType.darkness): [crowOnly],
    };

    List<String> unlocked(PetSpecies species, PetSkillsEntity skills) =>
        PetSkillsCatalog.unlockedFor(
          species,
          skills,
          elementTable: elementTable,
          typeTable: typeTable,
          speciesTypeTable: speciesTypeTable,
        ).map((a) => a.id).toList();

    test('combines element, type and species+type, gated by level', () {
      final crow = skillsOf(PetSpecies.crow);
      expect(unlocked(PetSpecies.crow, crow), ['shadow']);
      expect(unlocked(PetSpecies.crow, crow.copyWith(level: 5)), [
        'shadow',
        'murder',
      ]);

      final cardinal = skillsOf(PetSpecies.cardinal);
      expect(unlocked(PetSpecies.cardinal, cardinal), isEmpty);
      expect(unlocked(PetSpecies.cardinal, cardinal.copyWith(level: 2)), [
        'fireball',
      ]);
    });

    test('a type only develops species-specific skills in that species', () {
      final magpieGoneDark = skillsOf(
        PetSpecies.magpie,
      ).copyWith(type: PetType.darkness, level: 10);
      expect(unlocked(PetSpecies.magpie, magpieGoneDark), ['shadow']);
    });

    test('every pet attacks with the skill of its element', () {
      expect(
        PetSkillsCatalog.basicAttackFor(skillsOf(PetSpecies.cardinal)),
        PetSkillsCatalog.fireBurn,
      );
      expect(
        PetSkillsCatalog.basicAttackFor(skillsOf(PetSpecies.woodThrush)),
        PetSkillsCatalog.waterSlow,
      );
      expect(
        PetSkillsCatalog.basicAttackFor(skillsOf(PetSpecies.hummingbird)),
        PetSkillsCatalog.airGust,
      );
      expect(
        PetSkillsCatalog.basicAttackFor(skillsOf(PetSpecies.crow)),
        PetSkillsCatalog.earthRock,
      );
    });

    test('elemental skills are known from level 0', () {
      for (final s in PetSpecies.values) {
        final skills = skillsOf(s);
        expect(
          PetSkillsCatalog.unlockedFor(s, skills),
          contains(PetSkillsCatalog.basicAttackFor(skills)),
          reason: s.name,
        );
      }
    });

    test('elemental effects match the design', () {
      expect(
        PetSkillsCatalog.fireBurn.effect,
        const BurnEffect(damageMultiplier: 1.2, seconds: 3),
      );
      expect(PetSkillsCatalog.waterSlow.effect, isA<SlowEffect>());
      expect(PetSkillsCatalog.airGust.effect, isA<KnockbackEffect>());
      expect(PetSkillsCatalog.earthRock.effect, const DirectDamageEffect());
    });
  });
}
