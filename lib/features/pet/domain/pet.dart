import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/persistence/json_converters.dart';
import 'pet_species.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

/// Immutable snapshot of the pet.
///
/// Every stat follows the same convention: 0 = critical, 100 = perfect.
/// (That is why the "hunger" stat is modelled as [satiety]: a bar that
/// means "good" when full avoids inverted logic everywhere.)
@freezed
abstract class Pet with _$Pet {
  const factory Pet({
    required String name,
    required double satiety,
    required double energy,
    required double happiness,
    required double hygiene,
    @Default(false) bool isSleeping,
    // Saves from before species existed (or with a removed one) fall back
    // to the default bird instead of being discarded as unreadable.
    @Default(PetSpecies.fallback)
    @JsonKey(unknownEnumValue: PetSpecies.fallback)
    PetSpecies species,
    @UtcEpochMillisConverter() required DateTime lastUpdatedAt,
  }) = _Pet;

  factory Pet.newborn({required String name, required DateTime now}) => Pet(
    name: name,
    satiety: 80,
    energy: 80,
    happiness: 80,
    hygiene: 80,
    lastUpdatedAt: now,
  );

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}
