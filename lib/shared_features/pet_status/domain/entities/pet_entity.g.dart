// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetEntity _$PetEntityFromJson(Map<String, dynamic> json) => _PetEntity(
  id: json['id'] as String,
  name: json['name'] as String,
  species: $enumDecode(
    _$PetSpeciesEnumMap,
    json['species'],
    unknownValue: PetSpecies.cardinal,
  ),
  status: PetStatusEntity.fromJson(json['status'] as Map<String, dynamic>),
  skills: PetSkillsEntity.fromJson(json['skills'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PetEntityToJson(_PetEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': _$PetSpeciesEnumMap[instance.species]!,
      'status': instance.status.toJson(),
      'skills': instance.skills.toJson(),
    };

const _$PetSpeciesEnumMap = {
  PetSpecies.cardinal: 'cardinal',
  PetSpecies.blueJay: 'blueJay',
  PetSpecies.cedarWaxwing: 'cedarWaxwing',
  PetSpecies.chickadee: 'chickadee',
  PetSpecies.crow: 'crow',
  PetSpecies.houseFinch: 'houseFinch',
  PetSpecies.hummingbird: 'hummingbird',
  PetSpecies.magpie: 'magpie',
  PetSpecies.redRobin: 'redRobin',
  PetSpecies.stellersJay: 'stellersJay',
  PetSpecies.whiteDove: 'whiteDove',
  PetSpecies.woodThrush: 'woodThrush',
};
