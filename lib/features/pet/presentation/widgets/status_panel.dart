import 'package:flutter/material.dart';

import '../../domain/pet.dart';
import '../../domain/pet_mood.dart';
import 'stat_bar.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.pet,
    this.onChangeSpecies,
    this.onReset,
  });

  final Pet pet;

  /// Opens the species menu; hidden when null (e.g. during the minigame).
  final VoidCallback? onChangeSpecies;

  /// Debug-only "new pet" action; hidden when null.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(pet.name, style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_moodLabel(pet.mood)),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                if (onChangeSpecies != null)
                  IconButton(
                    tooltip: 'Cambiar mascota',
                    icon: const Icon(Icons.pets),
                    onPressed: onChangeSpecies,
                  ),
                if (onReset != null)
                  IconButton(
                    tooltip: 'Nueva mascota (debug)',
                    icon: const Icon(Icons.restart_alt),
                    onPressed: onReset,
                  ),
              ],
            ),
            Row(
              children: [
                for (final (icon, label, value) in [
                  (Icons.restaurant, 'Hambre', pet.satiety),
                  (Icons.bolt, 'Energía', pet.energy),
                  (Icons.favorite, 'Felicidad', pet.happiness),
                  (Icons.water_drop, 'Higiene', pet.hygiene),
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: StatBar(icon: icon, label: label, value: value),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _moodLabel(PetMood mood) => switch (mood) {
    PetMood.sleeping => '😴 Durmiendo',
    PetMood.hungry => '🍽️ Hambriento',
    PetMood.tired => '🥱 Cansado',
    PetMood.dirty => '🫧 Sucio',
    PetMood.sad => '😢 Triste',
    PetMood.content => '🙂 Tranquilo',
    PetMood.happy => '😄 Feliz',
  };
}
