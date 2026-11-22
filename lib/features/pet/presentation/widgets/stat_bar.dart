import 'package:flutter/material.dart';

import '../../../../shared_features/pet_status/domain/pet_status_balance.dart';

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = (value / PetStatusBalance.maxStat).clamp(0.0, 1.0);
    final color = Color.lerp(
      const Color(0xFFE5484D),
      const Color(0xFF46A758),
      Curves.easeIn.transform(t),
    )!;

    return Semantics(
      label: '$label ${value.round()}%',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: t),
              duration: const Duration(milliseconds: 400),
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: color,
                backgroundColor: Colors.black12,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
