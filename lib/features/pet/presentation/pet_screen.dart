import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/pet_controller.dart';
import '../domain/pet.dart';
import 'game/minigame_state.dart';
import 'game/pet_game.dart';
import 'widgets/action_bar.dart';
import 'widgets/minigame_hud.dart';
import 'widgets/species_picker.dart';
import 'widgets/status_panel.dart';

/// The only place where Riverpod and Flame meet:
/// state  -> game : `ref.listenManual` pushes every new [Pet] into the game.
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
    _game = PetGame(
      onPetTapped: () => _controller.cuddle(),
      onStarCaught: () => _controller.rewardCatch(),
      onMinigameFinished: (_) => _controller.finishMinigame(),
    );
    ref.listenManual<AsyncValue<Pet>>(petControllerProvider, (_, next) {
      final pet = next.value;
      if (pet != null) _game.pet = pet;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _game.disposeNotifiers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          SafeArea(
            child: switch (petAsync) {
              AsyncData(:final value) => _Hud(
                pet: value,
                game: _game,
                controller: _controller,
              ),
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

class _Hud extends StatelessWidget {
  const _Hud({required this.pet, required this.game, required this.controller});

  final Pet pet;
  final PetGame game;
  final PetController controller;

  Future<void> _pickSpecies(BuildContext context) async {
    final picked = await showSpeciesPicker(context, current: pet.species);
    if (picked != null) controller.changeSpecies(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MinigameState>(
      valueListenable: game.minigame,
      builder: (context, minigame, _) => Column(
        children: [
          StatusPanel(
            pet: pet,
            onChangeSpecies: minigame.active
                ? null
                : () => _pickSpecies(context),
            onReset: kDebugMode && !minigame.active ? controller.reset : null,
          ),
          const Spacer(),
          if (minigame.active)
            MinigameHud(state: minigame)
          else
            ActionBar(
              pet: pet,
              onFeed: controller.feed,
              onToggleSleep: controller.toggleSleep,
              onPlay: game.startMinigame,
              onClean: controller.clean,
            ),
        ],
      ),
    );
  }
}
