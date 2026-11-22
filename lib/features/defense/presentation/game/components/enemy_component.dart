import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../domain/defense_map.dart';
import '../defense_game.dart';

/// Placeholder enemy: a slime that crawls along a route. Its speed is read
/// from the game every frame, so speed-ups apply to enemies already walking.
class EnemyComponent extends PositionComponent
    with HasGameReference<DefenseGame> {
  EnemyComponent({required this.route, required int hp})
    : _hp = hp,
      _maxHp = hp,
      super(anchor: Anchor.center, size: Vector2.all(radius * 2));

  static const radius = 22.0;

  final RoutePath route;
  final int _maxHp;
  int _hp;
  double _travelled = 0;
  double _time = math.Random().nextDouble() * 10;
  double _flash = 0;
  bool _facingRight = false;

  bool get alive => _hp > 0 && !isRemoving && isMounted;

  /// How far along its route it is; the pet targets the most advanced one.
  double get progress => _travelled / route.length;

  @override
  void onMount() {
    super.onMount();
    _moveTo(route.positionAt(0));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _flash = math.max(0, _flash - dt);
    if (!game.running) return;
    _travelled += game.enemySpeed * dt;
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

  void hit(int damage) {
    if (!alive) return;
    _hp -= damage;
    _flash = 0.12;
    if (_hp <= 0) {
      removeFromParent();
      game.onEnemyKilled();
    }
  }

  static final _body = Paint()..color = const Color(0xFF8E4FC8);
  static final _bodyLight = Paint()..color = const Color(0xFFB57CE6);
  static final _flashPaint = Paint()..color = const Color(0xFFFFFFFF);
  static final _outline = Paint()
    ..color = const Color(0xFF2A123F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static final _white = Paint()..color = const Color(0xFFFFFFFF);
  static final _black = Paint()..color = const Color(0xFF14081F);
  static final _shadow = Paint()..color = const Color(0x40000000);
  static final _barBg = Paint()..color = const Color(0xAA000000);
  static final _barFg = Paint()..color = const Color(0xFF6CE07A);

  @override
  void render(Canvas canvas) {
    const r = radius;
    final c = Offset(r, r);
    final wobble = math.sin(_time * 8) * 0.08;
    canvas.drawOval(
      Rect.fromCenter(
        center: c + const Offset(0, r * 0.8),
        width: r * 1.8,
        height: r * 0.5,
      ),
      _shadow,
    );
    final body = Rect.fromCenter(
      center: c + Offset(0, r * wobble),
      width: r * 2 * (1 + wobble),
      height: r * 1.7 * (1 - wobble),
    );
    canvas.drawOval(body, _flash > 0 ? _flashPaint : _body);
    canvas.drawOval(
      Rect.fromLTWH(
        body.left + r * 0.35,
        body.top + r * 0.2,
        r * 0.7,
        r * 0.45,
      ),
      _bodyLight,
    );
    canvas.drawOval(body, _outline);

    final dir = _facingRight ? 1.0 : -1.0;
    for (final ex in [-0.3, 0.3]) {
      final e = c + Offset(r * (ex + dir * 0.25), -r * 0.15);
      canvas.drawCircle(e, r * 0.22, _white);
      canvas.drawCircle(e + Offset(dir * r * 0.08, 0), r * 0.11, _black);
    }

    if (_hp < _maxHp) {
      final w = r * 1.8;
      final bar = Rect.fromLTWH(r - w / 2, -10, w, 6);
      canvas.drawRect(bar, _barBg);
      canvas.drawRect(
        Rect.fromLTWH(bar.left + 1, bar.top + 1, (w - 2) * _hp / _maxHp, 4),
        _barFg,
      );
    }
  }
}
