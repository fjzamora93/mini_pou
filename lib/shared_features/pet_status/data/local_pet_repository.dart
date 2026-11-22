import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/persistence/key_value_store.dart';
import '../../pet_skills/domain/pet_traits.dart';
import '../../pet_species/domain/pet_species.dart';
import '../domain/entities/pet_roster_entity.dart';
import '../domain/pet_repository.dart';

/// Stores every raised pet as one versioned JSON document.
///
/// The roster is a small aggregate that is always read/written as a unit,
/// so a key/value store is the right tool: no schema, no adapters, no native
/// DB engine. Swapping to Hive/Drift later only touches this class.
///
/// Versions:
/// - v1: a single flat pet `{'v': 1, 'pet': {...}}` (no id/traits/level).
/// - v2: roster of flat pets (stats, level, xp, element, type side by side).
/// - v3: roster of pets with nested `status` and `skills`.
class LocalPetRepository implements PetRepository {
  LocalPetRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'pet_state';
  static const _schemaVersion = 3;

  @override
  Future<PetRosterEntity?> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return decode(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (e) {
      // Corrupt or incompatible save: start fresh rather than crash.
      debugPrint('Discarding unreadable pet save: $e');
      return null;
    }
  }

  @override
  Future<void> save(PetRosterEntity roster) =>
      _prefs.setString(_key, jsonEncode(encode(roster)));

  @override
  Future<void> clear() => _prefs.remove(_key);

  static Map<String, dynamic> encode(PetRosterEntity roster) => {
    'v': _schemaVersion,
    'roster': roster.toJson(),
  };

  /// Reads any known save version; `null` for unknown versions.
  @visibleForTesting
  static PetRosterEntity? decode(Map<String, dynamic> envelope) =>
      switch (envelope['v']) {
        1 => _fromV2(_v1ToV2(envelope['pet'] as Map<String, dynamic>)),
        2 => _fromV2(envelope['roster'] as Map<String, dynamic>),
        3 => PetRosterEntity.fromJson(
          envelope['roster'] as Map<String, dynamic>,
        ),
        _ => null,
      };

  /// The old single pet becomes the first (and active) pet of a v2 roster,
  /// at level 0, with the traits of its species.
  static Map<String, dynamic> _v1ToV2(Map<String, dynamic> pet) {
    final species = PetSpecies.values.firstWhere(
      (s) => s.name == pet['species'],
      orElse: () => PetSpecies.fallback,
    );
    final id = '${species.name}-v1';
    return {
      'activeId': id,
      'pets': [
        {
          ...pet,
          'id': id,
          'species': species.name,
          'element': species.element.name,
          'type': species.type.name,
        },
      ],
    };
  }

  /// v2 pets kept stats and skills side by side: nest them.
  static PetRosterEntity _fromV2(Map<String, dynamic> roster) {
    Map<String, dynamic> nest(Map<String, dynamic> p) => {
      'id': p['id'],
      'name': p['name'],
      'species': p['species'],
      'status': {
        for (final k in const [
          'satiety',
          'energy',
          'happiness',
          'hygiene',
          'isSleeping',
          'lastUpdatedAt',
        ])
          if (p.containsKey(k)) k: p[k],
      },
      'skills': {
        for (final k in const ['element', 'type', 'level', 'xp'])
          if (p.containsKey(k)) k: p[k],
      },
    };
    return PetRosterEntity.fromJson({
      'activeId': roster['activeId'],
      'pets': [
        for (final p in roster['pets'] as List<dynamic>)
          nest(p as Map<String, dynamic>),
      ],
    });
  }
}

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => LocalPetRepository(ref.watch(sharedPreferencesProvider)),
);
