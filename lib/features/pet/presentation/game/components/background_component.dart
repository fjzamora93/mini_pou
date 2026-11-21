import 'dart:ui';

import 'package:flame/components.dart';

/// Sky + floor drawn procedurally. Cross-fades to night while the pet sleeps.
class BackgroundComponent extends PositionComponent {
  BackgroundComponent() : super(priority: -10);

  bool night = false;
  double _nightT = 0; // 0 = day, 1 = night (smoothed)

  static const _daySky = [Color(0xFF8FD3FF), Color(0xFFE3F6FF)];
  static const _nightSky = [Color(0xFF1B2147), Color(0xFF3B3F78)];
  static const _dayFloor = Color(0xFFF2C894);
  static const _nightFloor = Color(0xFF6B5A7A);

  final _floorPaint = Paint();
  final _skyPaint = Paint();
  final _celestialPaint = Paint();

  @override
  void update(double dt) {
    final target = night ? 1.0 : 0.0;
    _nightT += (target - _nightT) * (dt * 2.5).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final groundY = h * 0.78;
    final top = Color.lerp(_daySky[0], _nightSky[0], _nightT)!;
    final bottom = Color.lerp(_daySky[1], _nightSky[1], _nightT)!;

    _skyPaint.shader = Gradient.linear(Offset.zero, Offset(0, groundY), [
      top,
      bottom,
    ]);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, groundY), _skyPaint);

    // Sun fades into a moon.
    final celestialCenter = Offset(w * 0.8, h * 0.14);
    _celestialPaint.color = Color.lerp(
      const Color(0xFFFFE066),
      const Color(0xFFF4F1DE),
      _nightT,
    )!;
    canvas.drawCircle(celestialCenter, w * 0.07, _celestialPaint);
    if (_nightT > 0.01) {
      // Crescent: overlap a sky-coloured circle.
      _celestialPaint.color = top.withValues(alpha: _nightT);
      canvas.drawCircle(
        celestialCenter.translate(w * 0.03, -w * 0.015),
        w * 0.065,
        _celestialPaint,
      );
    }

    _floorPaint.color = Color.lerp(_dayFloor, _nightFloor, _nightT)!;
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, h - groundY), _floorPaint);
    _floorPaint.color = _floorPaint.color.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH(0, groundY, w, 6), _floorPaint);
  }
}
