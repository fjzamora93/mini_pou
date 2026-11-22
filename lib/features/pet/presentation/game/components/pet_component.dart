import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../../../../../shared_features/pet_species/domain/pet_species.dart';
import '../../../../../shared_features/pet_species/presentation/pet_species_catalog.dart';
import '../../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../../../shared_features/pet_status/domain/pet_mood.dart';
import 'heart_component.dart';

enum _Anim { idle, react }

/// The creature, drawn from the chosen species' pixel-art spritesheet.
///
/// Expressiveness comes from picking the animation (idle / hop / fly / react),
/// facing direction, desaturation when unwell and dirt masked onto the sprite.
/// All of it eases towards targets derived from the latest [PetEntity] snapshot.
class PetComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FlameGame> {
  PetComponent({required this.onTapped}) : super(anchor: Anchor.bottomCenter);

  final VoidCallback onTapped;

  // --- Public API used by the game ---------------------------------------

  set pet(PetEntity value) {
    final speciesChanged = value.species != _pet?.species;
    _pet = value;
    _targetSaturation = 0.3 + 0.7 * value.status.wellbeing.clamp(0.0, 1.0);
    if (speciesChanged && isLoaded) _loadSpecies(value.species);
  }

  void layout({required Vector2 screen, required double groundY}) {
    // Integer multiple of the frame keeps pixel art crisp (no uneven texels).
    final raw = math.min(screen.x * 0.45, screen.y * 0.32);
    final scale = math.max(2, (raw / BirdSheet.frameSize).round());
    final side = scale * BirdSheet.frameSize;
    size.setValues(side, side);
    position.setValues(screen.x / 2, groundY);
    _zzzPaint = TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: side * 0.18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // --- Internal state ------------------------------------------------------

  PetEntity? _pet;
  double _time = 0;

  Map<_Anim, SpriteAnimation> _anims = const {};
  _Anim _anim = _Anim.idle;
  SpriteAnimationTicker? _ticker;

  bool _facingRight = false; // sheets are drawn facing left
  double _nextTurnIn = 3;
  double _sleepT = 0; // 0 awake, 1 asleep (smoothed)

  double _saturation = 1, _targetSaturation = 1, _appliedSaturation = -1;

  final _random = math.Random();
  Effect? _bounce;
  TextPaint? _zzzPaint;

  // Reusable paints: avoid allocations in render().
  final _spritePaint = Paint()..filterQuality = FilterQuality.none;
  final _fill = Paint();
  final _layerPaint = Paint();
  final _dirtPaint = Paint()..blendMode = BlendMode.srcATop;

  // Mud splats in texel coordinates of the 64px frame, placed over the
  // body/wing/head of the standing pose. Drawn on the sprite's own pixel grid
  // so dirt reads as part of the pixel art.
  static const _dirtSplats = [
    (28, 40),
    (36, 37),
    (22, 31),
    (32, 45),
    (41, 47),
    (24, 44),
    (17, 27),
    (45, 53),
  ];

  // Texel offsets of one splat: irregular blob plus a darker core.
  static const _splatShape = [
    (1, 0),
    (2, 0),
    (0, 1),
    (1, 1),
    (2, 1),
    (3, 1),
    (1, 2),
    (2, 2),
    (3, 2),
  ];
  static const _splatCore = [(1, 1), (2, 1), (2, 2)];
  final _dirtCorePaint = Paint()..blendMode = BlendMode.srcATop;

  @override
  Future<void> onLoad() async {
    await game.images.loadAll([
      for (final s in PetSpecies.values) s.flameImage,
    ]);
    _loadSpecies(_pet?.species ?? PetSpecies.fallback);
  }

  void _loadSpecies(PetSpecies species) {
    final image = game.images.fromCache(species.flameImage);
    final frame = image.width / BirdSheet.columns;
    SpriteAnimation row(int row, double stepTime, {bool loop = true}) =>
        SpriteAnimation.fromFrameData(
          image,
          SpriteAnimationData.sequenced(
            amount: BirdSheet.columns,
            stepTime: stepTime,
            textureSize: Vector2.all(frame),
            texturePosition: Vector2(0, row * frame),
            loop: loop,
          ),
        );
    _anims = {
      _Anim.idle: row(BirdSheet.idleRow, 0.45),
      _Anim.react: row(BirdSheet.reactRow, 0.1, loop: false),
    };
    _play(_anim, force: true);
  }

  void _play(_Anim anim, {bool force = false}) {
    if (anim == _anim && !force && _ticker != null) return;
    _anim = anim;
    _ticker = _anims[anim]?.createTicker();
  }

  // --- Simulation ------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    final asleep = _pet?.status.isSleeping ?? false;
    final ease = (dt * 4).clamp(0.0, 1.0);

    _saturation += (_targetSaturation - _saturation) * ease;
    _sleepT += ((asleep ? 1 : 0) - _sleepT) * ease;
    _updateColorFilter();

    _updateFacing(dt, asleep);
    _updateAnimation(asleep);

    // Sleeping freezes the idle pose on its first frame.
    if (!asleep) _ticker?.update(dt);
  }

  /// Looks around now and then while awake.
  void _updateFacing(double dt, bool asleep) {
    if (asleep) return;
    _nextTurnIn -= dt;
    if (_nextTurnIn <= 0) {
      _nextTurnIn = 2.5 + _random.nextDouble() * 4;
      _facingRight = !_facingRight;
    }
  }

  /// Idle, except while the tap reaction is playing.
  void _updateAnimation(bool asleep) {
    if (asleep || _anim != _Anim.react || (_ticker?.done() ?? true)) {
      _play(_Anim.idle);
    }
  }

  /// Unwell pets look washed out. Rebuilt only on visible change.
  void _updateColorFilter() {
    if ((_saturation - _appliedSaturation).abs() < 0.02) return;
    _appliedSaturation = _saturation;
    final s = _saturation, i = 1 - s;
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    _spritePaint.colorFilter = ColorFilter.matrix([
      lr * i + s, lg * i, lb * i, 0, 0, //
      lr * i, lg * i + s, lb * i, 0, 0, //
      lr * i, lg * i, lb * i + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);
  }

  // --- Interaction -------------------------------------------------------------

  @override
  void onTapDown(TapDownEvent event) {
    _playBounce();
    if (!(_pet?.status.isSleeping ?? false)) {
      _play(_Anim.react, force: true);
      parent?.add(HeartComponent(position: position - Vector2(0, size.y)));
    }
    onTapped();
  }

  /// Squash & stretch. Scale is reserved for this effect; idle breathing is
  /// applied in render() so both never fight over the same property.
  void _playBounce() {
    _bounce?.removeFromParent();
    scale.setAll(1);
    _bounce = SequenceEffect([
      ScaleEffect.to(
        Vector2(1.18, 0.82),
        EffectController(duration: 0.07, curve: Curves.easeOut),
      ),
      ScaleEffect.to(Vector2(0.9, 1.12), EffectController(duration: 0.1)),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.18, curve: Curves.elasticOut),
      ),
    ]);
    add(_bounce!);
  }

  // --- Rendering ---------------------------------------------------------------

  @override
  void render(Canvas canvas) {
    final pet = _pet;
    final sprite = _ticker?.getSprite();
    if (pet == null || sprite == null) return;
    final w = size.x, h = size.y;

    // Ground shadow.
    _fill.color = const Color(0x26000000);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h),
        width: w * 0.6,
        height: h * 0.08,
      ),
      _fill,
    );

    // Idle breathing: slower and deeper while sleeping.
    final speed = 2.2 - _sleepT * 1.2;
    final amount = 0.02 + _sleepT * 0.02;
    final b = math.sin(_time * speed) * amount;
    canvas.save();
    canvas.translate(w / 2, h);
    canvas.scale(_facingRight ? -(1 + b) : 1 + b, 1 - b);
    canvas.translate(-w / 2, -h);

    final dirtiness = ((60 - pet.status.hygiene) / 60).clamp(0.0, 1.0);
    if (dirtiness > 0) {
      // Layer so dirt (srcATop) only lands on the bird's own pixels.
      canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), _layerPaint);
      sprite.render(canvas, size: size, overridePaint: _spritePaint);
      _renderDirt(canvas, w, h, dirtiness);
      canvas.restore();
    } else {
      sprite.render(canvas, size: size, overridePaint: _spritePaint);
    }

    canvas.restore();

    if (_sleepT > 0.5) _renderZzz(canvas, w);
  }

  void _renderDirt(Canvas canvas, double w, double h, double dirtiness) {
    final count = (dirtiness * _dirtSplats.length).ceil();
    final texel = w / BirdSheet.frameSize;
    final alpha = 0.55 + dirtiness * 0.4;
    _dirtPaint.color = const Color(0xFF8A5E34).withValues(alpha: alpha);
    _dirtCorePaint.color = const Color(0xFF5A3A1E).withValues(alpha: alpha);
    for (var i = 0; i < count; i++) {
      final (sx, sy) = _dirtSplats[i];
      for (final (dx, dy) in _splatShape) {
        canvas.drawRect(
          Rect.fromLTWH((sx + dx) * texel, (sy + dy) * texel, texel, texel),
          _dirtPaint,
        );
      }
      for (final (dx, dy) in _splatCore) {
        canvas.drawRect(
          Rect.fromLTWH((sx + dx) * texel, (sy + dy) * texel, texel, texel),
          _dirtCorePaint,
        );
      }
    }
  }

  void _renderZzz(Canvas canvas, double w) {
    final paint = _zzzPaint;
    if (paint == null) return;
    for (var i = 0; i < 3; i++) {
      final phase = (_time * 0.5 + i / 3) % 1.0;
      paint.render(
        canvas,
        'z',
        Vector2(w * (0.7 + phase * 0.25), w * 0.15 - phase * w * 0.4),
        anchor: Anchor.center,
      );
    }
  }
}
