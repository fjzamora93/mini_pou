import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared_features/pet_status/application/pet_controller.dart';
import '../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../shared_features/pet_status/domain/entities/pet_roster_entity.dart';
import '../../defense/presentation/defense_screen.dart';
import 'game/pet_game.dart';
import 'widgets/action_bar.dart';
import 'widgets/pet_name_dialog.dart';
import 'widgets/species_picker.dart';
import 'widgets/status_panel.dart';

/// The only place where Riverpod and Flame meet:
/// state  -> game : `ref.listenManual` pushes every new [PetEntity] into the game.
/// game -> state  : game callbacks call controller methods.
class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({super.key});

  @override
  ConsumerState<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen> {
  late final PetGame _game;

  PetController get _controller => ref.read(petControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _game = PetGame(onPetTapped: () => _controller.cuddle());
    ref.listenManual<AsyncValue<PetRosterEntity>>(petControllerProvider, (
      _,
      next,
    ) {
      final pet = next.value?.active;
      if (pet != null) _game.pet = pet;
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final rosterAsync = ref.watch(petControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          SafeArea(
            child: switch (rosterAsync) {
              AsyncData(:final value) => switch (value.active) {
                final pet? => _Hud(
                  pet: pet,
                  roster: value,
                  game: _game,
                  controller: _controller,
                ),
                null => _FirstPet(roster: value, controller: _controller),
              },
              AsyncError(:final error) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('No se pudo cargar la mascota:\n$error'),
                    TextButton(
                      onPressed: () => ref.invalidate(petControllerProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

/// Picking a species: back to the raised pet of that species, or adopt a
/// new one (level 0) after naming it — a pet can't be saved without a name.
Future<void> _pickPet(
  BuildContext context,
  PetRosterEntity roster,
  PetController controller, {
  String title = 'Elige tu mascota',
}) async {
  final species = await showSpeciesPicker(
    context,
    roster: roster,
    title: title,
  );
  if (species == null || !context.mounted) return;
  final raised = roster.bySpecies(species);
  if (raised != null) {
    controller.switchTo(raised.id);
    return;
  }
  await showPetNameDialog(
    context,
    species: species,
    submit: (name) => controller.adopt(species, name),
  );
}

/// Shown until the first pet is adopted.
class _FirstPet extends StatelessWidget {
  const _FirstPet({required this.roster, required this.controller});

  final PetRosterEntity roster;
  final PetController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Bienvenido!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Elige tu primera mascota y ponle nombre.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.pets),
                label: const Text('Elegir mascota'),
                onPressed: () => _pickPet(
                  context,
                  roster,
                  controller,
                  title: 'Tu primera mascota',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.pet,
    required this.roster,
    required this.game,
    required this.controller,
  });

  final PetEntity pet;
  final PetRosterEntity roster;
  final PetGame game;
  final PetController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatusPanel(
          pet: pet,
          onChangeSpecies: () => _pickPet(context, roster, controller),
          onReset: kDebugMode ? controller.reset : null,
        ),
        const Spacer(),
        ActionBar(
          pet: pet,
          onFeed: controller.feed,
          onToggleSleep: controller.toggleSleep,
          onClean: controller.clean,
          onDefend: () => Navigator.of(context).push(DefenseScreen.route()),
        ),
      ],
    );
  }
}
