import 'package:flutter/material.dart';

import '../../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../../shared_features/pet_status/domain/pet_status_rules.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.pet,
    required this.onFeed,
    required this.onToggleSleep,
    required this.onClean,
    required this.onDefend,
  });

  final PetEntity pet;
  final VoidCallback onFeed;
  final VoidCallback onToggleSleep;
  final VoidCallback onClean;
  final VoidCallback onDefend;

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
            onPressed: PetStatusRules.canFeed(pet.status) ? onFeed : null,
          ),
          _ActionButton(
            icon: pet.status.isSleeping ? Icons.wb_sunny : Icons.bedtime,
            label: pet.status.isSleeping ? 'Despertar' : 'Dormir',
            onPressed: onToggleSleep,
          ),
          _ActionButton(
            icon: Icons.shower,
            label: 'Limpiar',
            onPressed: PetStatusRules.canClean(pet.status) ? onClean : null,
          ),
          _ActionButton(
            icon: Icons.shield,
            label: 'Defender',
            onPressed: onDefend,
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
