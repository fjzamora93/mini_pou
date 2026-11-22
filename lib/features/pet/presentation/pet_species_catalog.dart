import 'dart:ui' show Color;

import '../domain/pet_species.dart';

/// Layout shared by every bird spritesheet: a 4x4 grid of 64x64 frames.
abstract final class BirdSheet {
  /// Side of one frame in texels. On-screen sizes are integer multiples of
  /// it so every art pixel covers the same number of screen pixels.
  static const frameSize = 64.0;
  static const columns = 4;

  /// Row index of each animation in the sheet.
  static const flyRow = 0;
  static const reactRow = 1;
  static const idleRow = 2;
  static const hopRow = 3;
}

/// Presentation data for each [PetSpecies]: display name and spritesheet.
/// Kept out of the domain so the rules never depend on asset paths.
extension PetSpeciesCatalog on PetSpecies {
  String get label => switch (this) {
    PetSpecies.cardinal => 'Cardenal',
    PetSpecies.blueJay => 'Arrendajo azul',
    PetSpecies.cedarWaxwing => 'Ampelis',
    PetSpecies.chickadee => 'Carbonero',
    PetSpecies.crow => 'Cuervo',
    PetSpecies.houseFinch => 'Pinzón',
    PetSpecies.hummingbird => 'Colibrí',
    PetSpecies.magpie => 'Urraca',
    PetSpecies.redRobin => 'Petirrojo',
    PetSpecies.stellersJay => 'Chara',
    PetSpecies.whiteDove => 'Paloma blanca',
    PetSpecies.woodThrush => 'Zorzal',
  };

  String get _fileName => switch (this) {
    PetSpecies.cardinal => 'cardinal',
    PetSpecies.blueJay => 'blue_jay',
    PetSpecies.cedarWaxwing => 'cedar_waxwing',
    PetSpecies.chickadee => 'chickadee',
    PetSpecies.crow => 'crow',
    PetSpecies.houseFinch => 'house_finch',
    PetSpecies.hummingbird => 'hummingbird',
    PetSpecies.magpie => 'magpie',
    PetSpecies.redRobin => 'red_robin',
    PetSpecies.stellersJay => 'stellers_jay',
    PetSpecies.whiteDove => 'white_dove',
    PetSpecies.woodThrush => 'wood_thrush',
  };

  /// Key for Flame's image cache (relative to `assets/images/`).
  /// Every species now uses its redrawn 64px-frame sheet in `pets_final/`
  /// (regenerate with `python3 tool/bird_sprites.py`).
  String get flameImage => 'pets_final/$_fileName.png';

  /// Full path for Flutter's `Image.asset`.
  String get assetPath => 'assets/images/$flameImage';

  /// Signature colour of the bird (e.g. its projectiles in defense mode).
  Color get color => switch (this) {
    PetSpecies.cardinal => const Color(0xFFD42A12),
    PetSpecies.blueJay => const Color(0xFF3F7FE0),
    PetSpecies.cedarWaxwing => const Color(0xFFF2D25A),
    PetSpecies.chickadee => const Color(0xFFF4F2EC),
    PetSpecies.crow => const Color(0xFF3E4256),
    PetSpecies.houseFinch => const Color(0xFFD84A48),
    PetSpecies.hummingbird => const Color(0xFF3A9A1E),
    PetSpecies.magpie => const Color(0xFF1C58B0),
    PetSpecies.redRobin => const Color(0xFFD4542A),
    PetSpecies.stellersJay => const Color(0xFF1E4FA0),
    PetSpecies.whiteDove => const Color(0xFFECEEF2),
    PetSpecies.woodThrush => const Color(0xFFC47A3A),
  };
}
