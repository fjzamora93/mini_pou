import 'package:flutter/material.dart';

import '../../../../shared_features/pet_species/domain/pet_species.dart';
import '../../../../shared_features/pet_species/presentation/pet_species_catalog.dart';
import '../../../../shared_features/pet_species/presentation/widgets/bird_frame.dart';
import '../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../../shared_features/pet_status/domain/entities/pet_roster_entity.dart';

/// Opens the species menu; resolves to the picked species, or `null` if the
/// sheet was dismissed. Raised species show their pet's name and level;
/// the rest are marked as new (picking one adopts a new pet at level 0).
Future<PetSpecies?> showSpeciesPicker(
  BuildContext context, {
  required PetRosterEntity roster,
  String title = 'Elige tu mascota',
}) => showModalBottomSheet<PetSpecies>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => _SpeciesPicker(roster: roster, title: title),
);

class _SpeciesPicker extends StatelessWidget {
  const _SpeciesPicker({required this.roster, required this.title});

  final PetRosterEntity roster;
  final String title;

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
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.extent(
                shrinkWrap: true,
                maxCrossAxisExtent: 120,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
                children: [
                  for (final species in PetSpecies.values)
                    _SpeciesTile(
                      species: species,
                      pet: roster.bySpecies(species),
                      selected: roster.active?.species == species,
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
    required this.pet,
    required this.selected,
    required this.onTap,
  });

  final PetSpecies species;

  /// The raised pet of this species, if any.
  final PetEntity? pet;
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
                pet?.name ?? species.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                pet == null ? 'Nueva' : 'Nv. ${pet!.skills.level}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: pet == null ? scheme.outline : scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
