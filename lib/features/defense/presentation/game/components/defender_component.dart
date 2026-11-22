import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../../../../pet/domain/pet_species.dart';
import '../../../../pet/presentation/pet_species_catalog.dart';
import '../../../domain/defense_rules.dart';
import '../defense_game.dart';
import 'enemy_component.dart';
import 'projectile_component.dart';

/// The player's pet standing on the map. Fire rate and range are constant
/// for the whole run; it always shoots the enemy closest to the exit.
class DefenderComponent extends PositionComponent
    with HasGameReference<DefenseGame> {
  DefenderComponent({
    required this.species,
    required Image image,
    required Vector2 foot,
  }) : _image = image,
       super(
         position: foot + Vector2(0, DefenseBalance.petFootprintRadius * 0.6),
         anchor: Anchor.bottomCenter,
         size: Vector2.all(spriteSize),
       );

  static String imageFor(PetSpecies species) => species.flameImage;

  /// On-map size: 2x the 64px frame keeps the pixel art crisp.
  static const spriteSize = 128.0;

  final PetSpecies species;
  final Image _image;

  late final SpriteAnimationComponent _sprite;
  double _cooldown = 0;

  /// Where shots leave from (the bird's chest), in world coordinates.
  Vector2 get muzzle => position - Vector2(0, spriteSize * 0.45);

  @override
  Future<void> onLoad() async {
    final frame = _image.width / BirdSheet.columns;
    _sprite = SpriteAnimationComponent(
      animation: SpriteAnimation.fromFrameData(
        _image,
        SpriteAnimationData.sequenced(
          amount: BirdSheet.columns,
          stepTime: 0.45,
          textureSize: Vector2.all(frame),
          texturePosition: Vector2(0, BirdSheet.idleRow * frame),
        ),
      ),
      size: size.clone(),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y),
      paint: Paint()..filterQuality = FilterQuality.none,
    );
    add(_sprite);
    add(
      ScaleEffect.by(
        Vector2.all(1.15),
        EffectController(duration: 0.12, reverseDuration: 0.18),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.round();
    if (!game.running) return;
    _cooldown -= dt;
    if (_cooldown > 0) return;
    final target = _pickTarget();
    if (target == null) return;
    _cooldown = DefenseBalance.petFireInterval;
    _face(target.position.x);
    game.world.add(
      ProjectileComponent(
        from: muzzle,
        target: target,
        color: species.color,
        speed: DefenseBalance.projectileSpeed,
        damage: DefenseBalance.projectileDamage,
      ),
    );
    _sprite.add(
      ScaleEffect.to(
        Vector2(_sprite.scale.x.sign * 1.08, 0.92),
        EffectController(duration: 0.06, reverseDuration: 0.1),
      ),
    );
  }

  EnemyComponent? _pickTarget() {
    const range2 = DefenseBalance.petRange * DefenseBalance.petRange;
    final from = muzzle;
    EnemyComponent? best;
    for (final e in game.world.children.whereType<EnemyComponent>()) {
      if (!e.alive || e.position.distanceToSquared(from) > range2) continue;
      if (best == null || e.progress > best.progress) best = e;
    }
    return best;
  }

  /// Sheets face left; mirror when the target is to the right.
  void _face(double targetX) {
    final right = targetX > position.x;
    _sprite.scale.x = right ? -1 : 1;
    _sprite.scale.y = 1;
  }

  static final _rangeFill = Paint()..color = const Color(0x14FFFFFF);
  static final _rangeStroke = Paint()
    ..color = const Color(0x55FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final _shadow = Paint()..color = const Color(0x40000000);

  @override
  void render(Canvas canvas) {
    final feet = Offset(size.x / 2, size.y);
    final range = Offset(size.x / 2, size.y - spriteSize * 0.45);
    canvas.drawCircle(range, DefenseBalance.petRange, _rangeFill);
    canvas.drawCircle(range, DefenseBalance.petRange, _rangeStroke);
    canvas.drawOval(
      Rect.fromCenter(center: feet, width: size.x * 0.5, height: 12),
      _shadow,
    );
  }
}

/// Short-lived red cross where the player tapped a forbidden spot.
class InvalidTapMarker extends PositionComponent {
  InvalidTapMarker({required super.position})
    : super(anchor: Anchor.center, size: Vector2.all(40), priority: 200000);

  double _life = 0.6;

  static final _paint = Paint()
    ..color = const Color(0xFFE53935)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    _paint.color = _paint.color.withValues(alpha: math.min(1, _life / 0.3));
    canvas.drawLine(const Offset(8, 8), const Offset(32, 32), _paint);
    canvas.drawLine(const Offset(32, 8), const Offset(8, 32), _paint);
  }
}
