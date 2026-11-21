import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/persistence/key_value_store.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';

/// Stores the whole pet as one versioned JSON document.
///
/// The state is a single small aggregate that is always read/written as a
/// unit, so a key/value store is the right tool: no schema, no adapters, no
/// native DB engine. Swapping to Hive/Drift later only touches this class.
class LocalPetRepository implements PetRepository {
  LocalPetRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'pet_state';
  static const _schemaVersion = 1;

  @override
  Future<Pet?> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      // Future migrations: switch on envelope['v'] here.
      if (envelope['v'] != _schemaVersion) return null;
      return Pet.fromJson(envelope['pet'] as Map<String, dynamic>);
    } on Object catch (e) {
      // Corrupt or incompatible save: start fresh rather than crash.
      debugPrint('Discarding unreadable pet save: $e');
      return null;
    }
  }

  @override
  Future<void> save(Pet pet) => _prefs.setString(
    _key,
    jsonEncode({'v': _schemaVersion, 'pet': pet.toJson()}),
  );

  @override
  Future<void> clear() => _prefs.remove(_key);
}

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => LocalPetRepository(ref.watch(sharedPreferencesProvider)),
);
