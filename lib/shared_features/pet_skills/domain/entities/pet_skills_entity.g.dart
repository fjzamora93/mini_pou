// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_skills_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetSkillsEntity _$PetSkillsEntityFromJson(Map<String, dynamic> json) =>
    _PetSkillsEntity(
      element: $enumDecode(
        _$PetElementEnumMap,
        json['element'],
        unknownValue: PetElement.air,
      ),
      type: $enumDecode(
        _$PetTypeEnumMap,
        json['type'],
        unknownValue: PetType.elemental,
      ),
      level: (json['level'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PetSkillsEntityToJson(_PetSkillsEntity instance) =>
    <String, dynamic>{
      'element': _$PetElementEnumMap[instance.element]!,
      'type': _$PetTypeEnumMap[instance.type]!,
      'level': instance.level,
      'xp': instance.xp,
    };

const _$PetElementEnumMap = {
  PetElement.fire: 'fire',
  PetElement.air: 'air',
  PetElement.water: 'water',
  PetElement.earth: 'earth',
};

const _$PetTypeEnumMap = {
  PetType.light: 'light',
  PetType.darkness: 'darkness',
  PetType.elemental: 'elemental',
};
