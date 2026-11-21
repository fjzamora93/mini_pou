import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/core/time/clock.dart';
import 'package:mini_pou/features/pet/application/pet_controller.dart';
import 'package:mini_pou/features/pet/data/local_pet_repository.dart';
import 'package:mini_pou/features/pet/domain/pet.dart';
import 'package:mini_pou/features/pet/domain/pet_repository.dart';
import 'package:mini_pou/features/pet/domain/pet_species.dart';

class InMemoryPetRepository implements PetRepository {
  Pet? stored;

  @override
  Future<Pet?> load() async => stored;

  @override
  Future<void> save(Pet pet) async => stored = pet;

  @override
  Future<void> clear() async => stored = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryPetRepository repo;
  late DateTime now;
  late ProviderContainer container;

  setUp(() {
    repo = InMemoryPetRepository();
    now = DateTime.utc(2026, 1, 1, 12);
    container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => now),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('creates and persists a newborn when there is no save', () async {
    final pet = await container.read(petControllerProvider.future);
    expect(pet.satiety, 80);
    expect(repo.stored, pet);
  });

  test('applies offline decay since lastUpdatedAt on load', () async {
    repo.stored = Pet.newborn(
      name: 'Saved',
      now: now.subtract(const Duration(minutes: 5)),
    );

    final pet = await container.read(petControllerProvider.future);

    expect(pet.name, 'Saved');
    expect(pet.satiety, lessThan(80));
    expect(pet.lastUpdatedAt, now);
    expect(repo.stored, pet, reason: 'caught-up state is persisted');
  });

  test('actions advance time first, then apply the rule', () async {
    await container.read(petControllerProvider.future);
    now = now.add(const Duration(hours: 1));

    container.read(petControllerProvider.notifier).toggleSleep();

    final pet = container.read(petControllerProvider).value!;
    expect(pet.isSleeping, isTrue);
    expect(pet.lastUpdatedAt, now);
    expect(pet.energy, lessThan(80));
  });

  test('changeSpecies updates state and persists immediately', () async {
    await container.read(petControllerProvider.future);

    container
        .read(petControllerProvider.notifier)
        .changeSpecies(PetSpecies.hummingbird);

    final pet = container.read(petControllerProvider).value!;
    expect(pet.species, PetSpecies.hummingbird);
    await Future<void>.delayed(Duration.zero);
    expect(repo.stored?.species, PetSpecies.hummingbird);
  });
}
