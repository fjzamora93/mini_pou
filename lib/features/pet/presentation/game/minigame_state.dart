import 'package:flutter/foundation.dart';

/// Transient, per-session minigame status. Lives in the game (not Riverpod)
/// because it's frame-driven and never persisted; the HUD observes it
/// through a [ValueNotifier].
@immutable
class MinigameState {
  const MinigameState({
    required this.active,
    this.score = 0,
    this.secondsLeft = 0,
  });

  static const idle = MinigameState(active: false);

  final bool active;
  final int score;
  final int secondsLeft;

  @override
  bool operator ==(Object other) =>
      other is MinigameState &&
      other.active == active &&
      other.score == score &&
      other.secondsLeft == secondsLeft;

  @override
  int get hashCode => Object.hash(active, score, secondsLeft);
}
