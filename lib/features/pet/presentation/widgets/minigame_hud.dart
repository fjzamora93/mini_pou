import 'package:flutter/material.dart';

import '../game/minigame_state.dart';

class MinigameHud extends StatelessWidget {
  const MinigameHud({super.key, required this.state});

  final MinigameState state;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⭐ ${state.score}', style: style),
              Text(
                'Arrastra para moverte',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text('⏱ ${state.secondsLeft}s', style: style),
            ],
          ),
        ),
      ),
    );
  }
}
