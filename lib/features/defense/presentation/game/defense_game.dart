import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/flame/outside_build.dart';
import '../../../../shared_features/pet_species/domain/pet_species.dart';
import '../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../domain/defense_rules.dart';
import '../../domain/entities/defense_map_entity.dart';
import '../../domain/entities/enemy_entity.dart';
import '../../domain/route_path.dart';
import 'components/defender_component.dart';
import 'components/enemy_component.dart';
import 'components/placement_overlay.dart';
import 'components/projectile_component.dart';
import 'components/skill_sheet.dart';
import 'defense_hud_state.dart';

/// Tower-defense scene. World coordinates are map pixels; a fixed-resolution
/// camera letterboxes the whole map onto any screen.
///
/// Flow: the player picks one of their raised pets and taps a grass spot to
/// place it; every raised pet can be placed once. The run starts with the
/// first placement — enemies spawn and walk the routes, getting faster every
/// [DefenseBalance.speedStepSeconds], while pets keep a constant fire rate.
/// Each defeated enemy reports the pet that landed the final hit
/// ([onEnemyKilledBy]) so it can earn XP. Enemies reaching the exit cost a
/// life; at 0 lives the run ends.
class DefenseGame extends FlameGame {
  DefenseGame({
    required this.map,
    required ValueChanged<String> onEnemyKilledBy,
    required ValueChanged<String> onPetFired,
  }) : onEnemyKilledBy = ((petId) =>
           runOutsideBuild(() => onEnemyKilledBy(petId))),
       onPetFired = ((petId) => runOutsideBuild(() => onPetFired(petId))),
       super(
         camera: CameraComponent.withFixedResolution(
           width: map.width.toDouble(),
           height: map.height.toDouble(),
         ),
       );

  final DefenseMapEntity map;
  final ValueChanged<String> onEnemyKilledBy;

  /// A pet fired a shot (it gets tired: energy is spent per shot).
  final ValueChanged<String> onPetFired;

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

  // --- Pets ------------------------------------------------------------------

  /// Raised pets available for this run, by id (latest snapshots).
  var _pets = <String, PetEntity>{};
  String? _selectedId;

  /// Latest snapshots from the widget layer (levels change as pets earn XP).
  set pets(List<PetEntity> value) {
    _pets = {for (final p in value) p.id: p};
    for (final d in _defenders.values) {
      final pet = _pets[d.petId];
      if (pet != null) d.pet = pet;
    }
    if (_selectedId == null || !_pets.containsKey(_selectedId)) {
      _selectedId = _firstUnplaced();
    }
    _publish();
  }

  /// Chooses which pet the next tap on the map places.
  void selectPet(String petId) {
    if (!_pets.containsKey(petId) || _defenders.containsKey(petId)) return;
    _selectedId = petId;
    _publish();
  }

  String? _firstUnplaced() {
    for (final id in _pets.keys) {
      if (!_defenders.containsKey(id)) return id;
    }
    return null;
  }

  // --- Run state -------------------------------------------------------------

  final _defenders = <String, DefenderComponent>{};
  PlacementOverlay? _overlay;
  double _elapsed = 0;
  double _spawnIn = 0;
  int _nextRoute = 0;
  int _kills = 0;
  int _lives = DefenseBalance.lives;
  bool _gameOver = false;

  bool get running => _defenders.isNotEmpty && !_gameOver;

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
    await images.load(SlimeSheet.image);
    await images.loadAll(SkillSheet.allImages);
    await images.loadAll([
      for (final s in PetSpecies.values) DefenderComponent.imageFor(s),
    ]);
    world.add(
      _MapSurface(
        sprite: Sprite(image),
        size: Vector2(map.width.toDouble(), map.height.toDouble()),
        onTap: placePetAt,
      ),
    );
    _resetRun();
  }

  /// Places the selected pet with its footprint centred on [p] if that spot
  /// is free grass; otherwise shows a red cross.
  void placePetAt(Vector2 p) {
    final pet = _pets[_selectedId];
    if (pet == null || _gameOver) return;
    final point = MapPoint(p.x, p.y);
    final free = _defenders.values.every(
      (d) => d.foot.distanceTo(p) >= DefenseBalance.petFootprintRadius * 2,
    );
    if (!free ||
        !map.canPlace(point, radius: DefenseBalance.petFootprintRadius)) {
      world.add(InvalidTapMarker(position: p));
      return;
    }
    final defender = DefenderComponent(
      pet: pet,
      image: images.fromCache(DefenderComponent.imageFor(pet.species)),
      foot: p,
    );
    _defenders[pet.id] = defender;
    world.add(defender);
    _selectedId = _firstUnplaced();
    _syncOverlay();
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
      world.add(
        EnemyComponent(
          route: route,
          enemy: EnemyEntity.spawn(DefenseRules.enemyLevel(_elapsed)),
        ),
      );
    }
    _publish();
  }

  // --- Events from components -------------------------------------------------

  void onEnemyKilled(String byPetId) {
    _kills++;
    onEnemyKilledBy(byPetId);
    _publish();
  }

  void onEnemyEscaped() {
    if (_gameOver) return;
    _lives--;
    if (_lives <= 0) {
      _lives = 0;
      _gameOver = true;
      _syncOverlay();
    }
    _publish();
  }

  /// Wipes the map and goes back to the placement step.
  void restart() => _resetRun();

  void _resetRun() {
    for (final c in [
      ...world.children.whereType<EnemyComponent>(),
      ...world.children.whereType<ProjectileComponent>(),
      ...world.children.whereType<DefenderComponent>(),
    ]) {
      c.removeFromParent();
    }
    _defenders.clear();
    _selectedId = _firstUnplaced();
    _elapsed = 0;
    _spawnIn = 0.5;
    _nextRoute = 0;
    _kills = 0;
    _lives = DefenseBalance.lives;
    _gameOver = false;
    _syncOverlay();
    _publish();
  }

  /// The green "you can stand here" tint is visible while a pet is waiting
  /// to be placed.
  void _syncOverlay() {
    final show = !_gameOver && _pets.containsKey(_selectedId);
    if (show && _overlay == null) {
      _overlay = PlacementOverlay(map: map);
      world.add(_overlay!);
    } else if (!show && _overlay != null) {
      _overlay!.removeFromParent();
      _overlay = null;
    }
  }

  void _publish() {
    if (isLoaded) _syncOverlay();
    final next = DefenseHudState(
      placedIds: Set.unmodifiable(_defenders.keys.toSet()),
      selectedId: _selectedId,
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
