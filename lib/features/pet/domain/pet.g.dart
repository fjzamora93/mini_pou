// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pet _$PetFromJson(Map<String, dynamic> json) => _Pet(
  name: json['name'] as String,
  satiety: (json['satiety'] as num).toDouble(),
  energy: (json['energy'] as num).toDouble(),
  happiness: (json['happiness'] as num).toDouble(),
  hygiene: (json['hygiene'] as num).toDouble(),
  isSleeping: json['isSleeping'] as bool? ?? false,
  species:
      $enumDecodeNullable(
        _$PetSpeciesEnumMap,
        json['species'],
        unknownValue: PetSpecies.cardinal,
      ) ??
      PetSpecies.fallback,
  lastUpdatedAt: const UtcEpochMillisConverter().fromJson(
    (json['lastUpdatedAt'] as num).toInt(),
  ),
);

Map<String, dynamic> _$PetToJson(_Pet instance) => <String, dynamic>{
  'name': instance.name,
  'satiety': instance.satiety,
  'energy': instance.energy,
  'happiness': instance.happiness,
  'hygiene': instance.hygiene,
  'isSleeping': instance.isSleeping,
  'species': _$PetSpeciesEnumMap[instance.species]!,
  'lastUpdatedAt': const UtcEpochMillisConverter().toJson(
    instance.lastUpdatedAt,
  ),
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
