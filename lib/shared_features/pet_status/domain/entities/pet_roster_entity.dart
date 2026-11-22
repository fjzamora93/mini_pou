// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../pet_species/domain/pet_species.dart';
import 'pet_entity.dart';

part 'pet_roster_entity.freezed.dart';
part 'pet_roster_entity.g.dart';

/// Every pet the player has raised (one per species) plus the one currently
/// being looked after on the main screen.
@freezed
abstract class PetRosterEntity with _$PetRosterEntity {
  const PetRosterEntity._();

  @JsonSerializable(explicitToJson: true)
  const factory PetRosterEntity({
    @Default(<PetEntity>[]) List<PetEntity> pets,

    /// `null` only before the first adoption.
    String? activeId,
  }) = _PetRosterEntity;

  static const empty = PetRosterEntity();

  factory PetRosterEntity.fromJson(Map<String, dynamic> json) =>
      _$PetRosterEntityFromJson(json);

  PetEntity? get active {
    for (final p in pets) {
      if (p.id == activeId) return p;
    }
    return null;
  }

  PetEntity? byId(String id) {
    for (final p in pets) {
      if (p.id == id) return p;
    }
    return null;
  }

  PetEntity? bySpecies(PetSpecies species) {
    for (final p in pets) {
      if (p.species == species) return p;
    }
    return null;
  }

  bool hasRaised(PetSpecies species) => bySpecies(species) != null;

  /// Same roster with the pet that has [pet]'s id replaced by [pet].
  PetRosterEntity replace(PetEntity pet) =>
      copyWith(pets: [for (final p in pets) p.id == pet.id ? pet : p]);
}
