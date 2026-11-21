import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// Short-lived floating heart shown when the pet is cuddled.
class HeartComponent extends PositionComponent with HasPaint {
  HeartComponent({required super.position})
    : super(size: Vector2.all(26), anchor: Anchor.center, priority: 5) {
    paint.color = const Color(0xFFFF4F79);
  }

  static const _life = 0.9;

  @override
  Future<void> onLoad() async {
    addAll([
      MoveByEffect(Vector2(0, -70), EffectController(duration: _life)),
      OpacityEffect.fadeOut(EffectController(duration: _life)),
      RemoveEffect(delay: _life),
    ]);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final path = Path()
      ..moveTo(w / 2, h * 0.9)
      ..cubicTo(-w * 0.1, h * 0.45, w * 0.2, -h * 0.1, w / 2, h * 0.28)
      ..cubicTo(w * 0.8, -h * 0.1, w * 1.1, h * 0.45, w / 2, h * 0.9)
      ..close();
    canvas.drawPath(path, paint);
  }
}
