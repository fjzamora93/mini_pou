import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart' show SpriteAnimationTicker;
import 'package:flutter/painting.dart' show FontWeight, Shadow, TextStyle;

import '../../../../../shared_features/pet_skills/domain/entities/pet_skill_entity.dart';
import '../../../../../shared_features/pet_skills/domain/pet_traits.dart';
import '../defense_game.dart';
import 'enemy_component.dart';
import 'skill_sheet.dart';

/// A pet's attack: the skill of its element flying at an enemy, drawn with
/// that element's sprite and rotated to its heading.
///
/// A hit ([hits], decided when fired from the pet's fun) homes in and lets
/// the skill's effect act on the enemy (burn, slow, knockback...); a miss
/// flies past and shows "¡Fallo!". If the target dies first the shot flies
/// on to the last known position and vanishes there.
class ProjectileComponent extends PositionComponent
    with HasGameReference<DefenseGame> {
  ProjectileComponent({
    required Vector2 from,
    required this.target,
    required this.element,
    required this.skill,
    required this.ownerId,
    required this.speed,
    required this.damage,
    required this.hits,
  }) : _lastTarget = target.bodyCenter,
       super(
         position: from,
         anchor: Anchor.center,
         size: Vector2.all(SkillSheet.size),
         priority: 100000,
       );

  final EnemyComponent target;
  final PetElement element;
  final PetSkillEntity skill;

  /// Pet that fired it: credited if this shot defeats the enemy.
  final String ownerId;
  final double speed;

  /// Fixed when fired: the shooter's damage at that moment.
  final double damage;
  final bool hits;
  final Vector2 _lastTarget;
  late final SpriteAnimationTicker _flight;
  late final Image _image;

  /// Where a miss ends up relative to the enemy: just past its side.
  late final Vector2 _missOffset = Vector2(
    (position.x < target.position.x ? 1 : -1) * EnemyComponent.radius * 1.6,
    -EnemyComponent.radius * 0.9,
  );

  static final _paint = Paint()..filterQuality = FilterQuality.none;

  @override
  Future<void> onLoad() async {
    _image = game.images.fromCache(SkillSheet.image(element));
    _flight = SkillSheet.animation(
      _image,
      row: SkillSheet.projectileRow,
      stepTime: 0.07,
    ).createTicker();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _flight.update(dt);
    if (target.alive) {
      _lastTarget.setFrom(target.bodyCenter);
      if (!hits) _lastTarget.add(_missOffset);
    }
    final delta = _lastTarget - position;
    final step = speed * dt;
    final hitDistance = target.alive && hits
        ? EnemyComponent.radius * 0.7
        : step;
    if (delta.length <= hitDistance || delta.length <= step) {
      if (!hits) {
        parent?.add(MissText(position: _lastTarget.clone()));
      } else {
        parent?.add(SkillImpact(image: _image, position: _lastTarget.clone()));
        if (target.alive) {
          target.takeHit(
            damage: damage,
            effect: skill.effect,
            byPetId: ownerId,
          );
        }
      }
      removeFromParent();
      return;
    }
    // The sprite is drawn travelling right: turn it to face its heading.
    angle = math.atan2(delta.y, delta.x);
    position.add(delta.normalized()..scale(step));
  }

  @override
  void render(Canvas canvas) {
    _flight.getSprite().render(canvas, size: size, overridePaint: _paint);
  }
}

/// "¡Fallo!" floating up where a missed shot ended.
class MissText extends TextComponent {
  MissText({required super.position})
    : super(
        text: '¡Fallo!',
        anchor: Anchor.center,
        priority: 200000,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Color(0xFF000000), offset: Offset(1, 1))],
          ),
        ),
      );

  double _life = 0.7;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    position.y -= 25 * dt;
    if (_life <= 0) removeFromParent();
  }
}
