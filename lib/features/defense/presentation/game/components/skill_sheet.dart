import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../shared_features/pet_skills/domain/pet_traits.dart';

/// Layout of `skills/<element>.png`: 4 columns x 3 rows of 32x32 frames.
abstract final class SkillSheet {
  static const frame = 32.0;
  static const columns = 4;

  /// Projectile in flight, drawn travelling right (rotate to its heading).
  static const projectileRow = 0;

  /// Impact burst, played once where a shot lands.
  static const impactRow = 1;

  /// Overlay drawn on an affected slime (aligned with its 32px frame).
  static const statusRow = 2;

  /// On-map size: 2x like the slime, so overlays line up texel by texel.
  static const scale = 2.0;
  static const size = frame * scale;

  static String image(PetElement element) => 'skills/${element.name}.png';

  static List<String> get allImages => [
    for (final e in PetElement.values) image(e),
  ];

  static SpriteAnimation animation(
    Image image, {
    required int row,
    required double stepTime,
    bool loop = true,
  }) => SpriteAnimation.fromFrameData(
    image,
    SpriteAnimationData.sequenced(
      amount: columns,
      stepTime: stepTime,
      textureSize: Vector2.all(frame),
      texturePosition: Vector2(0, row * frame),
      loop: loop,
    ),
  );
}

/// One-shot elemental burst where a shot landed.
class SkillImpact extends SpriteAnimationComponent {
  SkillImpact({required Image image, required Vector2 position})
    : super(
        animation: SkillSheet.animation(
          image,
          row: SkillSheet.impactRow,
          stepTime: 0.06,
          loop: false,
        ),
        position: position,
        anchor: Anchor.center,
        size: Vector2.all(SkillSheet.size),
        removeOnFinish: true,
        priority: 150000,
        paint: Paint()..filterQuality = FilterQuality.none,
      );
}
