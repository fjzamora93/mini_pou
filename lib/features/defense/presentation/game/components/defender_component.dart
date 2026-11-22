import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/painting.dart' show FontWeight, Shadow, TextStyle;

import '../../../../../shared_features/pet_skills/domain/pet_skills_catalog.dart';
import '../../../../../shared_features/pet_species/domain/pet_species.dart';
import '../../../../../shared_features/pet_species/presentation/pet_species_catalog.dart';
import '../../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../../../shared_features/pet_status/domain/pet_combat_effects.dart';
import '../../../domain/defense_rules.dart';
import '../defense_game.dart';
import 'enemy_component.dart';
import 'projectile_component.dart';

/// One of the player's pets standing on the map, labelled with its name,
/// level and energy. It shoots the enemy closest to the exit; how often, how
/// hard and how accurately depends on its status (tiredness, hunger, fun).
/// Every shot tires it ([DefenseGame.onPetFired]) and carries its id so the
/// kill (and the XP) is credited to it.
class DefenderComponent extends PositionComponent
    with HasGameReference<DefenseGame> {
  DefenderComponent({
    required PetEntity pet,
    required Image image,
    required Vector2 foot,
  }) : _pet = pet,
       _image = image,
       foot = foot.clone(),
       super(
         position: foot + Vector2(0, DefenseBalance.petFootprintRadius * 0.6),
         anchor: Anchor.bottomCenter,
         size: Vector2.all(spriteSize),
       );

  static String imageFor(PetSpecies species) => species.flameImage;

  /// On-map size: 2x the 64px frame keeps the pixel art crisp.
  static const spriteSize = 128.0;

  /// Centre of the ground footprint (where the player tapped).
  final Vector2 foot;
  final Image _image;
  PetEntity _pet;

  String get petId => _pet.id;
  PetSpecies get species => _pet.species;

  /// Newer snapshot of the same pet (e.g. after earning XP).
  set pet(PetEntity value) {
    final levelledUp = value.skills.level > _pet.skills.level;
    _pet = value;
    if (!isLoaded) return;
    _label.text = _labelText;
    if (levelledUp) {
      add(
        _LevelUpText(
          level: value.skills.level,
          position: Vector2(size.x / 2, 0),
        ),
      );
    }
  }

  String get _labelText => DefenseRules.fireInterval(_pet) == null
      ? '${_pet.name} · ¡Agotado!'
      : '${_pet.name} · Nv.${_pet.skills.level}';

  final _random = math.Random();
  late final SpriteAnimationComponent _sprite;
  late final TextComponent _label;
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
    _label = TextComponent(
      text: _labelText,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y * 0.16),
      textRenderer: TextPaint(style: _labelStyle),
    );
    add(_label);
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
    final interval = DefenseRules.fireInterval(_pet);
    if (interval == null) return; // exhausted: needs to sleep
    final target = _pickTarget();
    if (target == null) return;
    _cooldown = interval;
    _face(target.position.x);
    game.world.add(
      ProjectileComponent(
        from: muzzle,
        target: target,
        element: _pet.skills.element,
        skill: PetSkillsCatalog.basicAttackFor(_pet.skills),
        ownerId: petId,
        speed: DefenseBalance.projectileSpeed,
        damage: DefenseRules.shotDamage(_pet),
        hits: DefenseRules.rollHit(_pet, _random.nextDouble()),
      ),
    );
    game.onPetFired(petId);
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
  static final _barBg = Paint()..color = const Color(0xAA000000);
  final _energyFill = Paint();

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
    _renderEnergy(canvas);
  }

  /// Energy (tiredness) bar under the name: red when it's running out.
  void _renderEnergy(Canvas canvas) {
    final energy = PetCombatEffects.attackSpeed(_pet.status);
    const w = 56.0;
    final bar = Rect.fromLTWH((size.x - w) / 2, size.y * 0.16 + 2, w, 6);
    canvas.drawRect(bar, _barBg);
    _energyFill.color = Color.lerp(
      const Color(0xFFE53935),
      const Color(0xFFFFD54F),
      energy,
    )!;
    canvas.drawRect(
      Rect.fromLTWH(bar.left + 1, bar.top + 1, (w - 2) * energy, 4),
      _energyFill,
    );
  }
}

const _labelStyle = TextStyle(
  color: Color(0xFFFFFFFF),
  fontSize: 18,
  fontWeight: FontWeight.w800,
  shadows: [
    Shadow(color: Color(0xFF000000), offset: Offset(1.5, 1.5)),
    Shadow(color: Color(0xFF000000), offset: Offset(-1, -1)),
  ],
);

/// "¡Nivel 3!" floating up from a pet that just levelled up.
class _LevelUpText extends TextComponent {
  _LevelUpText({required int level, required super.position})
    : super(
        text: '¡Nivel $level!',
        anchor: Anchor.bottomCenter,
        priority: 10,
        textRenderer: TextPaint(
          style: _labelStyle.copyWith(
            fontSize: 26,
            color: const Color(0xFFFFD54F),
          ),
        ),
      );

  double _life = 1.6;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    position.y -= 30 * dt;
    if (_life <= 0) removeFromParent();
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
