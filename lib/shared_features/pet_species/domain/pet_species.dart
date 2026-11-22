/// Which creature the player has chosen. Purely cosmetic: it never affects
/// [PetStatusRules]. Values are persisted by name, so renaming one is a migration.
enum PetSpecies {
  cardinal,
  blueJay,
  cedarWaxwing,
  chickadee,
  crow,
  houseFinch,
  hummingbird,
  magpie,
  redRobin,
  stellersJay,
  whiteDove,
  woodThrush;

  static const fallback = PetSpecies.cardinal;
}
