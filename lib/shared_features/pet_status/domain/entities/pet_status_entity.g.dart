// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_status_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetStatusEntity _$PetStatusEntityFromJson(Map<String, dynamic> json) =>
    _PetStatusEntity(
      satiety: (json['satiety'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      happiness: (json['happiness'] as num).toDouble(),
      hygiene: (json['hygiene'] as num).toDouble(),
      isSleeping: json['isSleeping'] as bool? ?? false,
      lastUpdatedAt: const UtcEpochMillisConverter().fromJson(
        (json['lastUpdatedAt'] as num).toInt(),
      ),
    );

Map<String, dynamic> _$PetStatusEntityToJson(_PetStatusEntity instance) =>
    <String, dynamic>{
      'satiety': instance.satiety,
      'energy': instance.energy,
      'happiness': instance.happiness,
      'hygiene': instance.hygiene,
      'isSleeping': instance.isSleeping,
      'lastUpdatedAt': const UtcEpochMillisConverter().toJson(
        instance.lastUpdatedAt,
      ),
    };
