import 'package:flutter/material.dart';

import '../../domain/pet_species.dart';
import '../pet_species_catalog.dart';

/// Opens the species menu; resolves to the picked species, or `null` if the
/// sheet was dismissed.
Future<PetSpecies?> showSpeciesPicker(
  BuildContext context, {
  required PetSpecies current,
}) => showModalBottomSheet<PetSpecies>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => _SpeciesPicker(current: current),
);

class _SpeciesPicker extends StatelessWidget {
  const _SpeciesPicker({required this.current});

  final PetSpecies current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Elige tu mascota', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.extent(
                shrinkWrap: true,
                maxCrossAxisExtent: 120,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: [
                  for (final species in PetSpecies.values)
                    _SpeciesTile(
                      species: species,
                      selected: species == current,
                      onTap: () => Navigator.of(context).pop(species),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesTile extends StatelessWidget {
  const _SpeciesTile({
    required this.species,
    required this.selected,
    required this.onTap,
  });

  final PetSpecies species;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: selected
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Center(child: BirdFrame(species: species, size: 64)),
              ),
              const SizedBox(height: 4),
              Text(
                species.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
