import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/flame/outside_build.dart';
import '../../domain/pet.dart';
import 'components/background_component.dart';
import 'components/catch_minigame.dart';
import 'components/pet_component.dart';
import 'minigame_state.dart';

/// Flame scene. It knows nothing about Riverpod or persistence:
/// - input: [pet] snapshots pushed by the widget layer;
/// - output: plain callbacks expressing player intents.
/// That keeps the game loop testable and swappable (e.g. a different genre).
class PetGame extends FlameGame with HasCollisionDetection {
  PetGame({
    required VoidCallback onPetTapped,
    required VoidCallback onStarCaught,
    required ValueChanged<int> onMinigameFinished,
  }) : onPetTapped = (() => runOutsideBuild(onPetTapped)),
       onStarCaught = (() => runOutsideBuild(onStarCaught)),
       onMinigameFinished = ((score) =>
           runOutsideBuild(() => onMinigameFinished(score)));

  final VoidCallback onPetTapped;
  final VoidCallback onStarCaught;
  final ValueChanged<int> onMinigameFinished;

  /// Read-only for the HUD; components publish through [publishMinigame].
  ValueListenable<MinigameState> get minigame => _minigame;
  final _minigame = ValueNotifier<MinigameState>(MinigameState.idle);

  void publishMinigame(MinigameState state) =>
      runOutsideBuild(() => _minigame.value = state);

  /// Releases resources owned by the widget layer's lifetime.
  void disposeNotifiers() => _minigame.dispose();

  late final BackgroundComponent background;
  late final PetComponent petComponent;

  Pet? _pet;

  /// Latest domain snapshot; visuals interpolate towards it.
  set pet(Pet value) {
    _pet = value;
    if (isLoaded) _applyPet(value);
  }

  /// Ground line (top of the floor) in world coordinates.
  double get groundY => size.y * 0.78;

  @override
  Future<void> onLoad() async {
    // World coordinates == logical screen pixels, origin top-left.
    camera.viewfinder.anchor = Anchor.topLeft;

    background = BackgroundComponent();
    petComponent = PetComponent(onTapped: onPetTapped);
    await world.addAll([background, petComponent]);
    _layout();

    if (_pet != null) _applyPet(_pet!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _layout();
  }

  void _layout() {
    background.size = size;
    petComponent.layout(screen: size, groundY: groundY);
  }

  void _applyPet(Pet pet) {
    petComponent.pet = pet;
    background.night = pet.isSleeping;
  }

  bool _minigameRunning = false;

  void startMinigame() {
    // Own flag: the published state may lag one frame behind.
    if (_minigameRunning) return;
    _minigameRunning = true;
    world.add(
      CatchMinigame(
        onCatch: onStarCaught,
        onFinished: (score) {
          _minigameRunning = false;
          petComponent.returnHome();
          onMinigameFinished(score);
        },
      ),
    );
  }
}
