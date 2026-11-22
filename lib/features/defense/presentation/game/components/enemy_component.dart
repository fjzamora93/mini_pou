import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart' show SpriteAnimationTicker;
import 'package:flutter/painting.dart' show FontWeight, Shadow, TextStyle;

import '../../../../../shared_features/pet_skills/domain/entities/skill_effect_entity.dart';
import '../../../../../shared_features/pet_skills/domain/pet_traits.dart';
import '../../../domain/combat_rules.dart';
import '../../../domain/defense_rules.dart';
import '../../../domain/entities/defense_map_entity.dart';
import '../../../domain/entities/enemy_entity.dart';
import '../../../domain/route_path.dart';
import '../defense_game.dart';
import 'skill_sheet.dart';

/// Layout of `enemies/slime.png`: 32x32 frames, facing left.
abstract final class SlimeSheet {
  static const image = 'enemies/slime.png';
  static const frame = 32.0;
  static const moveRow = 0;
  static const moveFrames = 8;
  static const deathRow = 1;
  static const deathFrames = 6;

  /// Ground line inside the frame (where the slime touches the floor).
  static const groundY = 29.0;

  /// On-map size: 2x the frame keeps the pixel art crisp.
  static const scale = 2.0;
  static const size = frame * scale;

  static SpriteAnimation animation(
    Image image, {
    required int row,
    required int amount,
    required double stepTime,
    bool loop = true,
  }) => SpriteAnimation.fromFrameData(
    image,
    SpriteAnimationData.sequenced(
      amount: amount,
      stepTime: stepTime,
      textureSize: Vector2.all(frame),
      texturePosition: Vector2(0, row * frame),
      loop: loop,
    ),
  );
}

/// A slime crawling along a route. Game state lives in its [EnemyEntity] (level
/// and HP); this component moves, animates and draws it. Its speed is read
/// from the game every frame, so speed-ups apply to enemies already walking.
class EnemyComponent extends PositionComponent
    with HasGameReference<DefenseGame> {
  EnemyComponent({required this.route, required EnemyEntity enemy})
    : _enemy = enemy,
      super(
        // Position = the slime's feet on the path line.
        anchor: const Anchor(0.5, SlimeSheet.groundY / SlimeSheet.frame),
        size: Vector2.all(SlimeSheet.size),
      );

  /// Rough body radius in map px (hit tests, projectile impact).
  static const radius = 22.0;

  final RoutePath route;
  EnemyEntity _enemy;
  double _travelled = 0;
  double _flash = 0;
  bool _facingRight = false;
  double _gust = 0; // seconds left of the knockback overlay
  late final SpriteAnimationTicker _move;
  late final SpriteAnimationTicker _burning;
  late final SpriteAnimationTicker _wet;
  late final SpriteAnimationTicker _blown;

  EnemyEntity get enemy => _enemy;
  bool get alive => !_enemy.isDefeated && !isRemoving && isMounted;

  /// How far along its route it is; pets target the most advanced one.
  double get progress => _travelled / route.length;

  /// Middle of the body in world coordinates (what projectiles aim at).
  Vector2 get bodyCenter => position - Vector2(0, radius * 0.75);

  static int _spawned = 0;

  @override
  Future<void> onLoad() async {
    _move = SlimeSheet.animation(
      game.images.fromCache(SlimeSheet.image),
      row: SlimeSheet.moveRow,
      amount: SlimeSheet.moveFrames,
      stepTime: 0.1,
    ).createTicker();
    // Desync neighbours so a queue of slimes doesn't hop in lockstep.
    _move.currentIndex = (_spawned++ * 3) % SlimeSheet.moveFrames;
    SpriteAnimationTicker overlay(PetElement e, double step) =>
        SkillSheet.animation(
          game.images.fromCache(SkillSheet.image(e)),
          row: SkillSheet.statusRow,
          stepTime: step,
        ).createTicker();
    _burning = overlay(PetElement.fire, 0.1);
    _wet = overlay(PetElement.water, 0.15);
    _blown = overlay(PetElement.air, 0.08);
  }

  @override
  void onMount() {
    super.onMount();
    _moveTo(route.positionAt(0));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) _flash -= dt;
    if (_gust > 0) _gust -= dt;
    if (!game.running) return;

    // Burns tick and slows wear off; a burn can finish it.
    _enemy = _enemy.tick(dt);
    if (_enemy.isDefeated) {
      _die();
      return;
    }
    if (_enemy.isBurning) _burning.update(dt);
    if (_enemy.isSlowed) _wet.update(dt);
    if (_gust > 0) _blown.update(dt);

    final speed = game.enemySpeed * _enemy.speedFactor;
    // Animation pace follows the walking speed.
    _move.update(dt * speed / DefenseBalance.baseEnemySpeed);
    _travelled += speed * dt;
    if (_travelled >= route.length) {
      removeFromParent();
      game.onEnemyEscaped();
      return;
    }
    _moveTo(route.positionAt(_travelled));
    priority = position.y.round(); // lower enemies drawn in front
  }

  void _moveTo(MapPoint p) {
    if ((p.x - position.x).abs() > 0.01) _facingRight = p.x > position.x;
    position.setValues(p.x, p.y);
  }

  /// A pet's shot landed: its skill [effect] decides what happens.
  void takeHit({
    required double damage,
    required SkillEffectEntity effect,
    required String byPetId,
  }) {
    if (!alive) return;
    final outcome = CombatRules.applyHit(
      _enemy,
      damage: damage,
      effect: effect,
      petId: byPetId,
    );
    _enemy = outcome.enemy;
    _flash = 0.12;
    if (outcome.knockback > 0) {
      _travelled = math.max(0, _travelled - outcome.knockback);
      _moveTo(route.positionAt(_travelled));
      _gust = 0.35;
    }
    if (_enemy.isDefeated) _die();
  }

  void _die() {
    parent?.add(SlimeDeath(position: position.clone(), mirrored: _facingRight));
    removeFromParent();
    final killer = _enemy.lastHitBy;
    if (killer != null) game.onEnemyKilled(killer);
  }

  // --- Rendering ---------------------------------------------------------------

  static final _sprite = Paint()..filterQuality = FilterQuality.none;
  static final _flashPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..colorFilter = const ColorFilter.mode(
      Color(0xFFFFFFFF),
      BlendMode.srcATop,
    );
  static final _shadow = Paint()..color = const Color(0x40000000);
  static final _barBg = Paint()..color = const Color(0xAA000000);
  static final _barFg = Paint()..color = const Color(0xFF6CE07A);
  static final _levelText = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 13,
      fontWeight: FontWeight.w800,
      shadows: [Shadow(color: Color(0xFF000000), offset: Offset(1, 1))],
    ),
  );

  @override
  void render(Canvas canvas) {
    final w = size.x;
    const ground = SlimeSheet.groundY * SlimeSheet.scale;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, ground),
        width: w * 0.62,
        height: 10,
      ),
      _shadow,
    );

    canvas.save();
    if (_facingRight) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }
    _move.getSprite().render(
      canvas,
      size: size,
      overridePaint: _flash > 0 ? _flashPaint : _sprite,
    );
    // Effect overlays share the slime's 32px frame, so they line up.
    if (_enemy.isSlowed) {
      _wet.getSprite().render(canvas, size: size, overridePaint: _sprite);
    }
    if (_enemy.isBurning) {
      _burning.getSprite().render(canvas, size: size, overridePaint: _sprite);
    }
    if (_gust > 0) {
      _blown.getSprite().render(canvas, size: size, overridePaint: _sprite);
    }
    canvas.restore();

    // Level + health bar above the head.
    const barW = 40.0;
    final bar = Rect.fromLTWH((w - barW) / 2, 6, barW, 6);
    canvas.drawRect(bar, _barBg);
    canvas.drawRect(
      Rect.fromLTWH(
        bar.left + 1,
        bar.top + 1,
        (barW - 2) * _enemy.healthFraction,
        4,
      ),
      _barFg,
    );
    _levelText.render(
      canvas,
      'Nv.${_enemy.level}',
      Vector2(w / 2, bar.top - 1),
      anchor: Anchor.bottomCenter,
    );
  }
}

/// One-shot splat left behind by a defeated slime.
class SlimeDeath extends SpriteAnimationComponent
    with HasGameReference<DefenseGame> {
  SlimeDeath({required Vector2 position, required this.mirrored})
    : super(
        position: position,
        anchor: const Anchor(0.5, SlimeSheet.groundY / SlimeSheet.frame),
        size: Vector2.all(SlimeSheet.size),
        removeOnFinish: true,
        paint: Paint()..filterQuality = FilterQuality.none,
      );

  final bool mirrored;

  @override
  Future<void> onLoad() async {
    animation = SlimeSheet.animation(
      game.images.fromCache(SlimeSheet.image),
      row: SlimeSheet.deathRow,
      amount: SlimeSheet.deathFrames,
      stepTime: 0.07,
      loop: false,
    );
    if (mirrored) flipHorizontallyAroundCenter();
    priority = position.y.round();
  }
}
