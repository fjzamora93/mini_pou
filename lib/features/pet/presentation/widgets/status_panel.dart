import 'package:flutter/material.dart';

import '../../../../shared_features/pet_skills/domain/pet_progression.dart';
import '../../../../shared_features/pet_skills/presentation/pet_traits_catalog.dart';
import '../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../../shared_features/pet_status/domain/pet_mood.dart';
import 'stat_bar.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.pet,
    this.onChangeSpecies,
    this.onReset,
  });

  final PetEntity pet;

  /// Opens the species menu; hidden when null.
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
                Flexible(
                  child: Text(
                    pet.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_moodLabel(pet.status.mood)),
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
            _LevelRow(pet: pet),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (icon, label, value) in [
                  (Icons.restaurant, 'Hambre', pet.status.satiety),
                  (Icons.bolt, 'Descanso', pet.status.energy),
                  (Icons.celebration, 'Diversión', pet.status.happiness),
                  (Icons.water_drop, 'Higiene', pet.status.hygiene),
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

/// "Nv. 3", XP progress towards the next level, element and type.
class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.pet});

  final PetEntity pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxed = PetProgression.isMaxLevel(pet.skills);
    final need = PetProgression.xpToNextLevel(pet.skills.level);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Nv. ${pet.skills.level}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: PetProgression.levelProgress(pet.skills),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  maxed ? 'Nivel máximo' : '${pet.skills.xp} / $need XP',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TraitChip.element(pet.skills.element),
          const SizedBox(width: 4),
          TraitChip.type(pet.skills.type),
        ],
      ),
    );
  }
}
