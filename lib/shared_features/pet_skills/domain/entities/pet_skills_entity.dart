import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../pet_species/domain/pet_species.dart';
import '../pet_traits.dart';

part 'pet_skills_entity.freezed.dart';
part 'pet_skills_entity.g.dart';

/// What a pet can do in combat and how far it has grown: its element and
/// type (which decide the skills it can learn), its level and its XP.
///
/// Kept apart from [PetStatusEntity]-like day-to-day needs (hunger,
/// tiredness...): skills only change by fighting.
@freezed
abstract class PetSkillsEntity with _$PetSkillsEntity {
  const factory PetSkillsEntity({
    @JsonKey(unknownEnumValue: PetElement.air) required PetElement element,
    @JsonKey(unknownEnumValue: PetType.elemental) required PetType type,
    @Default(0) int level,

    /// Experience accumulated towards the next level (resets on level-up).
    @Default(0) int xp,
  }) = _PetSkillsEntity;

  /// Level 0 with the natural traits of [species].
  factory PetSkillsEntity.forSpecies(PetSpecies species) =>
      PetSkillsEntity(element: species.element, type: species.type);

  factory PetSkillsEntity.fromJson(Map<String, dynamic> json) =>
      _$PetSkillsEntityFromJson(json);
}
