import 'package:flutter/foundation.dart';

import 'skill_effect_entity.dart';

/// A special power a pet unlocks when it reaches [unlockLevel].
/// Which pets can learn it is decided by `PetSkillsCatalog`.
@immutable
class PetSkillEntity {
  const PetSkillEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockLevel,
    this.effect = const DirectDamageEffect(),
  });

  /// Stable identifier (persist / compare by this, never by [name]).
  final String id;
  final String name;
  final String description;
  final int unlockLevel;

  /// What it does to the enemy it hits.
  final SkillEffectEntity effect;

  @override
  bool operator ==(Object other) => other is PetSkillEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PetSkillEntity($id)';
}
