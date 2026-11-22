import '../../pet_species/domain/pet_species.dart';

/// Classical element of a pet. Will drive element-specific abilities.
enum PetElement { fire, air, water, earth }

/// Alignment of a pet. Will drive type-specific abilities.
enum PetType { light, darkness, elemental }

/// Where a species usually lives. Only used to derive [PetElement], so the
/// classification reads as natural history instead of an arbitrary table.
enum Habitat {
  /// Hot, dry scrub and desert edges.
  aridScrub,

  /// Tree canopy, open sky: lives mostly in the air.
  canopy,

  /// Damp forest floor, streams, wetlands.
  wetland,

  /// Forages on the ground: fields, lawns, open country.
  ground;

  PetElement get element => switch (this) {
    Habitat.aridScrub => PetElement.fire,
    Habitat.canopy => PetElement.air,
    Habitat.wetland => PetElement.water,
    Habitat.ground => PetElement.earth,
  };
}

/// Natural traits of each species. Pure data + classification rules; a pet
/// copies them when it's adopted (see `PetSkillsEntity.forSpecies`).
extension PetSpeciesTraits on PetSpecies {
  Habitat get habitat => switch (this) {
    // Thickets and Sonoran desert scrub.
    PetSpecies.cardinal => Habitat.aridScrub,
    // Originally a bird of the western deserts.
    PetSpecies.houseFinch => Habitat.aridScrub,
    // Damp deciduous forest floor near streams.
    PetSpecies.woodThrush => Habitat.wetland,
    // Ground foragers of fields, lawns and open country.
    PetSpecies.crow => Habitat.ground,
    PetSpecies.magpie => Habitat.ground,
    PetSpecies.redRobin => Habitat.ground,
    // Canopy dwellers and aerial specialists.
    PetSpecies.blueJay => Habitat.canopy,
    PetSpecies.cedarWaxwing => Habitat.canopy,
    PetSpecies.chickadee => Habitat.canopy,
    PetSpecies.hummingbird => Habitat.canopy,
    PetSpecies.stellersJay => Habitat.canopy,
    PetSpecies.whiteDove => Habitat.canopy,
  };

  /// Element derived from the habitat.
  PetElement get element => habitat.element;

  /// Default type: everyone is elemental except the crow (darkness) and the
  /// white dove (light).
  PetType get type => switch (this) {
    PetSpecies.crow => PetType.darkness,
    PetSpecies.whiteDove => PetType.light,
    _ => PetType.elemental,
  };
}
