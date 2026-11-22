import '../../pet_species/domain/pet_species.dart';
import 'entities/pet_skill_entity.dart';
import 'entities/pet_skills_entity.dart';
import 'entities/skill_effect_entity.dart';
import 'pet_traits.dart';

/// Which skills each pet can learn. Skills come from three sources:
/// - its element (every fire pet, every water pet...),
/// - its type (light / darkness / elemental),
/// - a specific species *with* a specific type (e.g. a darkness crow), so a
///   type can develop different skills depending on the species.
///
/// Every pet knows the skill of its element from level 0: it's its basic
/// attack ([basicAttackFor]). Type and species+type tables are still empty.
abstract final class PetSkillsCatalog {
  /// Fire: 1.2x the hit's damage, dealt as a burn over 3 seconds.
  static const fireBurn = PetSkillEntity(
    id: 'fire_burn',
    name: 'Llamarada',
    description: 'Quema al enemigo: 120% del daño repartido en 3 s.',
    unlockLevel: 0,
    effect: BurnEffect(damageMultiplier: 1.2, seconds: 3),
  );

  /// Water: slows the target down.
  static const waterSlow = PetSkillEntity(
    id: 'water_slow',
    name: 'Marea',
    description: 'Empapa al enemigo: va a la mitad de velocidad 2 s.',
    unlockLevel: 0,
    effect: SlowEffect(speedFactor: 0.5, seconds: 2),
  );

  /// Air: pushes the target a little back along its path.
  static const airGust = PetSkillEntity(
    id: 'air_gust',
    name: 'Ráfaga',
    description: 'Empuja al enemigo un poco hacia atrás.',
    unlockLevel: 0,
    effect: KnockbackEffect(distance: 30),
  );

  /// Earth: a plain, honest rock.
  static const earthRock = PetSkillEntity(
    id: 'earth_rock',
    name: 'Roca',
    description: 'Golpe normal, sin efectos.',
    unlockLevel: 0,
  );

  static const Map<PetElement, List<PetSkillEntity>> byElement = {
    PetElement.fire: [fireBurn],
    PetElement.water: [waterSlow],
    PetElement.air: [airGust],
    PetElement.earth: [earthRock],
  };

  static const Map<PetType, List<PetSkillEntity>> byType = {};

  /// Skills a type only develops in a given species.
  static const Map<(PetSpecies, PetType), List<PetSkillEntity>> bySpeciesType =
      {};

  /// Everything a pet could ever learn, unlocked or not.
  static List<PetSkillEntity> allFor(
    PetSpecies species,
    PetSkillsEntity skills, {
    Map<PetElement, List<PetSkillEntity>> elementTable = byElement,
    Map<PetType, List<PetSkillEntity>> typeTable = byType,
    Map<(PetSpecies, PetType), List<PetSkillEntity>> speciesTypeTable =
        bySpeciesType,
  }) => {
    ...?elementTable[skills.element],
    ...?typeTable[skills.type],
    ...?speciesTypeTable[(species, skills.type)],
  }.toList();

  /// Skills already available at the pet's current level.
  static List<PetSkillEntity> unlockedFor(
    PetSpecies species,
    PetSkillsEntity skills, {
    Map<PetElement, List<PetSkillEntity>> elementTable = byElement,
    Map<PetType, List<PetSkillEntity>> typeTable = byType,
    Map<(PetSpecies, PetType), List<PetSkillEntity>> speciesTypeTable =
        bySpeciesType,
  }) => [
    for (final s in allFor(
      species,
      skills,
      elementTable: elementTable,
      typeTable: typeTable,
      speciesTypeTable: speciesTypeTable,
    ))
      if (skills.level >= s.unlockLevel) s,
  ];

  /// The skill a pet attacks with: the one of its element.
  static PetSkillEntity basicAttackFor(PetSkillsEntity skills) =>
      byElement[skills.element]!.first;
}
