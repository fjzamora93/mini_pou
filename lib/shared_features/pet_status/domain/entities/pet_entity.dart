// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../pet_skills/domain/entities/pet_skills_entity.dart';
import '../../../pet_species/domain/pet_species.dart';
import 'pet_status_entity.dart';

part 'pet_entity.freezed.dart';
part 'pet_entity.g.dart';

/// One raised pet: who it is ([id], [name], [species]), how it is doing
/// ([status]) and what it can do in combat ([skills]). Status and skills
/// are separate entities with their own rules.
@freezed
abstract class PetEntity with _$PetEntity {
  @JsonSerializable(explicitToJson: true)
  const factory PetEntity({
    required String id,
    required String name,
    @JsonKey(unknownEnumValue: PetSpecies.fallback) required PetSpecies species,
    required PetStatusEntity status,
    required PetSkillsEntity skills,
  }) = _PetEntity;

  /// A freshly adopted pet: level 0, traits taken from its species.
  factory PetEntity.newborn({
    required String name,
    required PetSpecies species,
    required DateTime now,
    String? id,
  }) => PetEntity(
    id: id ?? '${species.name}-${now.millisecondsSinceEpoch}',
    name: name,
    species: species,
    status: PetStatusEntity.initial(now),
    skills: PetSkillsEntity.forSpecies(species),
  );

  factory PetEntity.fromJson(Map<String, dynamic> json) =>
      _$PetEntityFromJson(json);
}
