import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/persistence/json_converters.dart';

part 'pet_status_entity.freezed.dart';
part 'pet_status_entity.g.dart';

/// Day-to-day needs of a pet. Every stat follows the same convention:
/// 0 = critical, 100 = perfect.
///
/// - [satiety]   hunger bar (full = not hungry). In combat: damage.
/// - [energy]    tiredness bar (full = rested). In combat: attack speed.
///               Only fighting drains it; sleeping refills it.
/// - [happiness] fun bar. In combat: hit chance.
/// - [hygiene]   cleanliness.
@freezed
abstract class PetStatusEntity with _$PetStatusEntity {
  const factory PetStatusEntity({
    required double satiety,
    required double energy,
    required double happiness,
    required double hygiene,
    @Default(false) bool isSleeping,
    @UtcEpochMillisConverter() required DateTime lastUpdatedAt,
  }) = _PetStatusEntity;

  /// A freshly adopted pet: fully rested, everything else at 80.
  factory PetStatusEntity.initial(DateTime now) => PetStatusEntity(
    satiety: 80,
    energy: 100,
    happiness: 80,
    hygiene: 80,
    lastUpdatedAt: now,
  );

  factory PetStatusEntity.fromJson(Map<String, dynamic> json) =>
      _$PetStatusEntityFromJson(json);
}
