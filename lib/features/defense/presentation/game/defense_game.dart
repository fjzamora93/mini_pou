import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/flame/outside_build.dart';
import '../../../pet/domain/pet_species.dart';
import '../../domain/defense_map.dart';
import '../../domain/defense_rules.dart';
import 'components/defender_component.dart';
import 'components/enemy_component.dart';
import 'components/placement_overlay.dart';
import 'components/projectile_component.dart';
import 'defense_hud_state.dart';

/// Tower-defense scene. World coordinates are map pixels; a fixed-resolution
/// camera letterboxes the whole map onto any screen.
///
/// Flow: the player taps a grass spot to place their single pet; then the
/// run starts — enemies spawn and walk the routes, getting faster every
/// [DefenseBalance.speedStepSeconds], while the pet keeps a constant fire
/// rate. Enemies reaching the exit cost a life; at 0 lives the run ends.
class DefenseGame extends FlameGame {
  DefenseGame({required this.map, required this.species})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: map.width.toDouble(),
          height: map.height.toDouble(),
        ),
      );

  final DefenseMap map;
  final PetSpecies species;

  late final List<RoutePath> _routes = [
    for (final r in map.routes) RoutePath(r),
  ];

  ValueListenable<DefenseHudState> get hud => _hud;
  final _hud = ValueNotifier(const DefenseHudState());

  bool _disposed = false;

  void disposeNotifiers() {
    _disposed = true;
    _hud.dispose();
  }

  // --- Run state -------------------------------------------------------------

  DefenderComponent? _defender;
  PlacementOverlay? _overlay;
  double _elapsed = 0;
  double _spawnIn = 0;
  int _nextRoute = 0;
  int _kills = 0;
  int _lives = DefenseBalance.lives;
  bool _gameOver = false;

  bool get running => _defender != null && !_gameOver;

  /// Current speed of every enemy on the map (map px/s).
  double get enemySpeed => DefenseRules.enemySpeed(_elapsed);

  @override
  Color backgroundColor() => const Color(0xFF26301E);

  @override
  Future<void> onLoad() async {
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    final image = await images.load(map.image);
    await images.load(_speciesImage);
    world.add(
      _MapSurface(
        sprite: Sprite(image),
        size: Vector2(map.width.toDouble(), map.height.toDouble()),
        onTap: placePetAt,
      ),
    );
    _resetRun();
  }

  String get _speciesImage => DefenderComponent.imageFor(species);

  /// Places the pet with its footprint centred on [p] if that spot is grass;
  /// otherwise shows a red cross. Ignored once a pet is on the map.
  void placePetAt(Vector2 p) {
    if (_defender != null || _gameOver) return;
    final point = MapPoint(p.x, p.y);
    if (!map.canPlace(point, radius: DefenseBalance.petFootprintRadius)) {
      world.add(InvalidTapMarker(position: p));
      return;
    }
    _overlay?.removeFromParent();
    _overlay = null;
    final defender = DefenderComponent(
      species: species,
      image: images.fromCache(_speciesImage),
      foot: p,
    );
    _defender = defender;
    world.add(defender);
    _publish();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!running) return;
    _elapsed += dt;
    _spawnIn -= dt;
    if (_spawnIn <= 0) {
      _spawnIn += DefenseBalance.spawnInterval;
      final route = _routes[_nextRoute];
      _nextRoute = (_nextRoute + 1) % _routes.length;
      world.add(EnemyComponent(route: route, hp: DefenseBalance.enemyHp));
    }
    _publish();
  }

  // --- Events from components -------------------------------------------------

  void onEnemyKilled() {
    _kills++;
    _publish();
  }

  void onEnemyEscaped() {
    if (_gameOver) return;
    _lives--;
    if (_lives <= 0) {
      _lives = 0;
      _gameOver = true;
    }
    _publish();
  }

  /// Wipes the map and goes back to the "place your pet" step.
  void restart() => _resetRun();

  void _resetRun() {
    for (final c in [
      ...world.children.whereType<EnemyComponent>(),
      ...world.children.whereType<ProjectileComponent>(),
      ...world.children.whereType<DefenderComponent>(),
      ...world.children.whereType<PlacementOverlay>(),
    ]) {
      c.removeFromParent();
    }
    _defender = null;
    _elapsed = 0;
    _spawnIn = 0.5;
    _nextRoute = 0;
    _kills = 0;
    _lives = DefenseBalance.lives;
    _gameOver = false;
    _overlay = PlacementOverlay(map: map);
    world.add(_overlay!);
    _publish();
  }

  void _publish() {
    final next = DefenseHudState(
      petPlaced: _defender != null,
      seconds: _elapsed.floor(),
      speedMultiplier: DefenseRules.speedMultiplier(_elapsed),
      kills: _kills,
      lives: _lives,
      gameOver: _gameOver,
    );
    if (next == _hud.value) return;
    runOutsideBuild(() {
      if (!_disposed) _hud.value = next;
    });
  }
}

/// The map image; also the input surface for placing the pet.
class _MapSurface extends SpriteComponent with TapCallbacks {
  _MapSurface({
    required Sprite super.sprite,
    required Vector2 super.size,
    required this.onTap,
  }) : super(priority: -10);

  final ValueChanged<Vector2> onTap;

  @override
  void onTapDown(TapDownEvent event) => onTap(event.localPosition.clone());
}
