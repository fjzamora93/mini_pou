import 'package:flutter/material.dart';

import '../../domain/pet_species.dart';
import '../pet_species_catalog.dart';

/// One crisp, upscaled frame of a bird spritesheet (idle pose by default).
class BirdFrame extends StatelessWidget {
  const BirdFrame({
    super.key,
    required this.species,
    required this.size,
    this.row = BirdSheet.idleRow,
    this.column = 0,
  });

  final PetSpecies species;
  final double size;
  final int row;
  final int column;

  @override
  Widget build(BuildContext context) {
    const n = BirdSheet.columns;
    // Alignment maps -1..1 across the overflow, so cell i sits at -1 + 2i/(n-1).
    final alignment = Alignment(
      -1 + 2 * column / (n - 1),
      -1 + 2 * row / (n - 1),
    );
    return SizedBox.square(
      dimension: size,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: size * n,
          maxHeight: size * n,
          alignment: alignment,
          child: Image.asset(
            species.assetPath,
            width: size * n,
            height: size * n,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
