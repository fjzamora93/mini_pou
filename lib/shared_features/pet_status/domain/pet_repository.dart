import 'entities/pet_roster_entity.dart';

/// Persistence contract. The domain doesn't care whether it's
/// SharedPreferences, Hive or a remote backend.
abstract interface class PetRepository {
  /// Returns `null` when there is no (valid) save yet.
  Future<PetRosterEntity?> load();

  Future<void> save(PetRosterEntity roster);

  Future<void> clear();
}
