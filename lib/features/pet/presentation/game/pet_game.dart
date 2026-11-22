import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/flame/outside_build.dart';
import '../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import 'components/background_component.dart';
import 'components/pet_component.dart';

/// Flame scene. It knows nothing about Riverpod or persistence:
/// - input: [pet] snapshots pushed by the widget layer;
/// - output: plain callbacks expressing player intents.
/// That keeps the game loop testable and swappable (e.g. a different genre).
class PetGame extends FlameGame {
  PetGame({required VoidCallback onPetTapped})
    : onPetTapped = (() => runOutsideBuild(onPetTapped));

  /// Tapping the pet is how it gets attention (and happiness).
  final VoidCallback onPetTapped;

  late final BackgroundComponent background;
  late final PetComponent petComponent;

  PetEntity? _pet;

  /// Latest domain snapshot; visuals interpolate towards it.
  set pet(PetEntity value) {
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

  void _applyPet(PetEntity pet) {
    petComponent.pet = pet;
    background.night = pet.status.isSleeping;
  }
}
