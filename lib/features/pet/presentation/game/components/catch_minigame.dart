import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/pet_balance.dart';
import '../minigame_state.dart';
import '../pet_game.dart';
import 'falling_star.dart';

/// Self-contained "catch the stars" round. Owns its stars and input surface,
/// so finishing the round is just `removeFromParent()`.
class CatchMinigame extends Component with HasGameReference<PetGame> {
  CatchMinigame({required this.onCatch, required this.onFinished})
    : super(priority: 10);

  final VoidCallback onCatch;
  final ValueChanged<int> onFinished;

  static const _duration = PetBalance.minigameDurationSeconds;

  final _random = math.Random();
  double _elapsed = 0;
  double _spawnIn = 0.3;
  int _score = 0;
  bool _finished = false;

  @override
  Future<void> onLoad() async {
    add(
      _DragSurface(
        size: game.size.clone(),
        onDragX: (x) => game.petComponent.moveTargetX = x,
      ),
    );
    _publish();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished) return;
    _elapsed += dt;

    _spawnIn -= dt;
    if (_spawnIn <= 0) {
      _spawnStar();
      // Gets progressively faster: 0.8s -> 0.35s between stars.
      final progress = (_elapsed / _duration).clamp(0.0, 1.0);
      _spawnIn = 0.8 - 0.45 * progress;
    }

    _trackNearestStar();
    _publish();
    if (_elapsed >= _duration) _finish();
  }

  void _spawnStar() {
    final w = game.size.x, h = game.size.y;
    final radius = math.max(16.0, w * 0.045);
    add(
      FallingStar(
        position: Vector2(
          radius + _random.nextDouble() * (w - radius * 2),
          -radius,
        ),
        radius: radius,
        speed: h * (0.25 + _random.nextDouble() * 0.2),
        floorY: game.groundY,
        onCaught: () {
          _score++;
          onCatch();
        },
      ),
    );
  }

  /// Eyes follow the closest incoming star — cheap but very alive.
  void _trackNearestStar() {
    final pet = game.petComponent;
    FallingStar? nearest;
    var best = double.infinity;
    for (final star in children.whereType<FallingStar>()) {
      final d = star.position.distanceToSquared(pet.center);
      if (d < best) {
        best = d;
        nearest = star;
      }
    }
    pet.lookTarget = nearest?.position;
  }

  void _publish() {
    game.publishMinigame(
      MinigameState(
        active: !_finished,
        score: _score,
        secondsLeft: math.max(0, (_duration - _elapsed).ceil()),
      ),
    );
  }

  void _finish() {
    _finished = true;
    game.publishMinigame(MinigameState.idle);
    removeFromParent();
    onFinished(_score);
  }
}

/// Invisible full-screen layer that turns horizontal drags into pet movement.
/// It has no TapCallbacks, so taps still reach the stars and the pet.
class _DragSurface extends PositionComponent with DragCallbacks {
  _DragSurface({required super.size, required this.onDragX});

  final ValueChanged<double> onDragX;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    onDragX(event.localPosition.x);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) => onDragX(event.localEndPosition.x);
}
