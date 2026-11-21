import 'package:flutter/material.dart';

import '../../domain/pet.dart';
import '../../domain/pet_rules.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.pet,
    required this.onFeed,
    required this.onToggleSleep,
    required this.onPlay,
    required this.onClean,
  });

  final Pet pet;
  final VoidCallback onFeed;
  final VoidCallback onToggleSleep;
  final VoidCallback onPlay;
  final VoidCallback onClean;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.restaurant,
            label: 'Alimentar',
            // Rules decide availability; the UI just reflects them.
            onPressed: PetRules.canFeed(pet) ? onFeed : null,
          ),
          _ActionButton(
            icon: pet.isSleeping ? Icons.wb_sunny : Icons.bedtime,
            label: pet.isSleeping ? 'Despertar' : 'Dormir',
            onPressed: onToggleSleep,
          ),
          _ActionButton(
            icon: Icons.sports_esports,
            label: 'Jugar',
            onPressed: PetRules.canPlay(pet) ? onPlay : null,
          ),
          _ActionButton(
            icon: Icons.shower,
            label: 'Limpiar',
            onPressed: PetRules.canClean(pet) ? onClean : null,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              FittedBox(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}
