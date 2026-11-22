// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_roster_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetRosterEntity _$PetRosterEntityFromJson(Map<String, dynamic> json) =>
    _PetRosterEntity(
      pets:
          (json['pets'] as List<dynamic>?)
              ?.map((e) => PetEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PetEntity>[],
      activeId: json['activeId'] as String?,
    );

Map<String, dynamic> _$PetRosterEntityToJson(_PetRosterEntity instance) =>
    <String, dynamic>{
      'pets': instance.pets.map((e) => e.toJson()).toList(),
      'activeId': instance.activeId,
    };
