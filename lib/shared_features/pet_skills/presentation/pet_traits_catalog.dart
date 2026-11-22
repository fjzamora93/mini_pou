import 'package:flutter/material.dart';

import '../domain/pet_traits.dart';

/// Display data for traits. Kept out of the domain like the species catalog.
extension PetElementCatalog on PetElement {
  String get label => switch (this) {
    PetElement.fire => 'Fuego',
    PetElement.air => 'Aire',
    PetElement.water => 'Agua',
    PetElement.earth => 'Tierra',
  };

  IconData get icon => switch (this) {
    PetElement.fire => Icons.local_fire_department,
    PetElement.air => Icons.air,
    PetElement.water => Icons.water_drop,
    PetElement.earth => Icons.terrain,
  };

  Color get color => switch (this) {
    PetElement.fire => const Color(0xFFE65100),
    PetElement.air => const Color(0xFF0288D1),
    PetElement.water => const Color(0xFF1565C0),
    PetElement.earth => const Color(0xFF6D4C41),
  };
}

extension PetTypeCatalog on PetType {
  String get label => switch (this) {
    PetType.light => 'Luz',
    PetType.darkness => 'Oscuridad',
    PetType.elemental => 'Elemental',
  };

  IconData get icon => switch (this) {
    PetType.light => Icons.light_mode,
    PetType.darkness => Icons.dark_mode,
    PetType.elemental => Icons.auto_awesome,
  };

  Color get color => switch (this) {
    PetType.light => const Color(0xFFF9A825),
    PetType.darkness => const Color(0xFF4A148C),
    PetType.elemental => const Color(0xFF00897B),
  };
}

/// Small rounded label with an icon, e.g. [fire icon] "Fuego".
class TraitChip extends StatelessWidget {
  const TraitChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  TraitChip.element(PetElement element, {Key? key})
    : this(
        key: key,
        icon: element.icon,
        label: element.label,
        color: element.color,
      );

  TraitChip.type(PetType type, {Key? key})
    : this(key: key, icon: type.icon, label: type.label, color: type.color);

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 8, 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
