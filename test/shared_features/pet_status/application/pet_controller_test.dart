import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/core/time/clock.dart';
import 'package:mini_pou/shared_features/pet_species/domain/pet_species.dart';
import 'package:mini_pou/shared_features/pet_status/application/pet_controller.dart';
import 'package:mini_pou/shared_features/pet_status/data/local_pet_repository.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/entities/pet_roster_entity.dart';
import 'package:mini_pou/shared_features/pet_status/domain/pet_repository.dart';
import 'package:mini_pou/shared_features/pet_status/domain/roster_rules.dart';

class InMemoryPetRepository implements PetRepository {
  PetRosterEntity? stored;

  @override
  Future<PetRosterEntity?> load() async => stored;

  @override
  Future<void> save(PetRosterEntity roster) async => stored = roster;

  @override
  Future<void> clear() async => stored = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryPetRepository repo;
  late DateTime now;
  late ProviderContainer container;

  PetController controller() => container.read(petControllerProvider.notifier);
  PetRosterEntity roster() => container.read(petControllerProvider).value!;

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

  test(
    'starts empty (no unnamed pet is created) when there is no save',
    () async {
      final r = await container.read(petControllerProvider.future);
      expect(r.pets, isEmpty);
      expect(r.active, isNull);
      expect(repo.stored, isNull);
    },
  );

  test('adopting requires a name and persists immediately', () async {
    await container.read(petControllerProvider.future);

    expect(controller().adopt(PetSpecies.crow, '  '), PetNameError.empty);
    expect(roster().pets, isEmpty);

    expect(controller().adopt(PetSpecies.crow, 'Kai'), isNull);
    expect(roster().active!.name, 'Kai');
    expect(roster().active!.skills.level, 0);
    expect(repo.stored, roster());
  });

  test('applies offline decay to the active pet only', () async {
    final earlier = now.subtract(const Duration(minutes: 30));
    final active = PetEntity.newborn(
      name: 'A',
      species: PetSpecies.crow,
      now: earlier,
    );
    final resting = PetEntity.newborn(
      name: 'B',
      species: PetSpecies.magpie,
      now: earlier,
    );
    repo.stored = PetRosterEntity(pets: [active, resting], activeId: active.id);

    final r = await container.read(petControllerProvider.future);

    expect(r.active!.status.satiety, lessThan(80));
    expect(r.active!.status.lastUpdatedAt, now);
    expect(r.byId(resting.id), resting, reason: 'resting pets are frozen');
    expect(repo.stored, r);
  });

  test('actions advance time first, then apply the rule', () async {
    await container.read(petControllerProvider.future);
    controller().adopt(PetSpecies.crow, 'Kai');
    now = now.add(const Duration(hours: 1));

    controller().toggleSleep();

    final status = roster().active!.status;
    expect(status.isSleeping, isTrue);
    expect(status.lastUpdatedAt, now);
    expect(status.satiety, lessThan(80));
  });

  test('fighting tires a pet, and sleeping 10 s restores it', () async {
    await container.read(petControllerProvider.future);
    controller().adopt(PetSpecies.crow, 'Kai');
    final id = roster().active!.id;

    for (var i = 0; i < 60; i++) {
      controller().spendEnergy(id, 1);
    }
    expect(roster().active!.status.energy, 40);

    controller().toggleSleep();
    now = now.add(const Duration(seconds: 10));
    controller().feed(); // any action brings the status up to "now"
    expect(roster().active!.status.energy, 100);
    expect(roster().active!.status.isSleeping, isFalse);
  });

  test('switching keeps each pet with its own level', () async {
    await container.read(petControllerProvider.future);
    controller().adopt(PetSpecies.crow, 'Kai');
    final crowId = roster().active!.id;
    controller().awardXp(crowId, 10);
    controller().adopt(PetSpecies.whiteDove, 'Luz');

    expect(roster().active!.skills.level, 0);
    controller().switchTo(crowId);
    expect(roster().active!.name, 'Kai');
    expect(roster().active!.skills.level, 1);
    await Future<void>.delayed(Duration.zero);
    expect(repo.stored?.activeId, crowId);
  });
}
