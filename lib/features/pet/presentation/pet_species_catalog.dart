import '../domain/pet_species.dart';

/// Layout shared by every bird spritesheet: a 4x4 grid of 16x16 frames.
abstract final class BirdSheet {
  static const frameSize = 16.0;
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
  String get flameImage => 'pets/$_fileName.png';

  /// Full path for Flutter's `Image.asset`.
  String get assetPath => 'assets/images/$flameImage';
}
