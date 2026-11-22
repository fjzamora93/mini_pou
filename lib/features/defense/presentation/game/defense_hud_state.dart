import 'package:flutter/foundation.dart';

/// Snapshot the HUD renders. Frame-driven and never persisted, so it lives
/// in the game and is observed through a ValueNotifier.
@immutable
class DefenseHudState {
  const DefenseHudState({
    this.petPlaced = false,
    this.seconds = 0,
    this.speedMultiplier = 1,
    this.kills = 0,
    this.lives = 0,
    this.gameOver = false,
  });

  final bool petPlaced;
  final int seconds;
  final double speedMultiplier;
  final int kills;
  final int lives;
  final bool gameOver;

  @override
  bool operator ==(Object other) =>
      other is DefenseHudState &&
      other.petPlaced == petPlaced &&
      other.seconds == seconds &&
      other.speedMultiplier == speedMultiplier &&
      other.kills == kills &&
      other.lives == lives &&
      other.gameOver == gameOver;

  @override
  int get hashCode =>
      Object.hash(petPlaced, seconds, speedMultiplier, kills, lives, gameOver);
}
