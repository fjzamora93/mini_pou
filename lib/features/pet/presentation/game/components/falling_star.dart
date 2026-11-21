import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import 'pet_component.dart';

/// Collectible for the catch minigame. Caught by touching the pet or by
/// tapping it directly.
class FallingStar extends PositionComponent
    with TapCallbacks, CollisionCallbacks, HasPaint {
  FallingStar({
    required super.position,
    required double radius,
    required this.speed,
    required this.floorY,
    required this.onCaught,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center) {
    paint.color = const Color(0xFFFFD23F);
  }

  final double speed;
  final double floorY;
  final VoidCallback onCaught;

  bool _caught = false;
  late final Path _shape;
  final _outline = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xFFE09F00)
    ..strokeWidth = 2;

  @override
  Future<void> onLoad() async {
    _shape = _starPath(size.x / 2, size.x / 4.2);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_caught) return;
    position.y += speed * dt;
    angle += dt * 2.5;
    if (position.y - size.y > floorY) {
      // Missed: fade into the ground.
      _caught = true;
      _vanish(grow: false);
    }
  }

  @override
  void onTapDown(TapDownEvent event) => _catch();

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PetComponent) _catch();
  }

  void _catch() {
    if (_caught) return;
    _caught = true;
    onCaught();
    _vanish(grow: true);
  }

  void _vanish({required bool grow}) {
    const t = 0.25;
    addAll([
      if (grow) ScaleEffect.to(Vector2.all(1.8), EffectController(duration: t)),
      OpacityEffect.fadeOut(EffectController(duration: t)),
      RemoveEffect(delay: t),
    ]);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.drawPath(_shape, paint);
    _outline.color = _outline.color.withValues(alpha: paint.color.a);
    canvas.drawPath(_shape, _outline);
    canvas.restore();
  }

  static Path _starPath(double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }
}
