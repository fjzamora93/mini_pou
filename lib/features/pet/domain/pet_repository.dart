import 'pet.dart';

/// Persistence contract. The domain doesn't care whether it's
/// SharedPreferences, Hive or a remote backend.
abstract interface class PetRepository {
  /// Returns `null` when there is no (valid) saved pet yet.
  Future<Pet?> load();

  Future<void> save(Pet pet);

  Future<void> clear();
}
