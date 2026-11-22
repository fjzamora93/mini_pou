import 'dart:ui';

import 'package:flame/components.dart';

import 'enemy_component.dart';

/// Homing shot in the pet's colour. If its target dies first it flies on to
/// the last known position and vanishes there.
/// Placeholder look until the real projectile art exists.
class ProjectileComponent extends PositionComponent {
  ProjectileComponent({
    required Vector2 from,
    required this.target,
    required this.color,
    required this.speed,
    required this.damage,
  }) : _lastTarget = target.position.clone(),
       super(
         position: from,
         anchor: Anchor.center,
         size: Vector2.all(radius * 2),
         priority: 100000,
       );

  static const radius = 8.0;

  final EnemyComponent target;
  final Color color;
  final double speed;
  final int damage;
  final Vector2 _lastTarget;

  late final _fill = Paint()..color = color;
  static final _outline = Paint()
    ..color = const Color(0xCC111111)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  static final _glint = Paint()..color = const Color(0xCCFFFFFF);

  @override
  void update(double dt) {
    super.update(dt);
    if (target.alive) _lastTarget.setFrom(target.position);
    final delta = _lastTarget - position;
    final step = speed * dt;
    final hitDistance = target.alive ? EnemyComponent.radius * 0.7 : step;
    if (delta.length <= hitDistance || delta.length <= step) {
      if (target.alive) target.hit(damage);
      removeFromParent();
      return;
    }
    position.add(delta.normalized()..scale(step));
  }

  @override
  void render(Canvas canvas) {
    const c = Offset(radius, radius);
    canvas.drawCircle(c, radius, _fill);
    canvas.drawCircle(c, radius, _outline);
    canvas.drawCircle(c - const Offset(2.5, 2.5), radius * 0.3, _glint);
  }
}
