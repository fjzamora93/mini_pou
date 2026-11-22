import 'package:flutter/foundation.dart';

/// Snapshot the HUD renders. Frame-driven and never persisted, so it lives
/// in the game and is observed through a ValueNotifier.
@immutable
class DefenseHudState {
  const DefenseHudState({
    this.placedIds = const {},
    this.selectedId,
    this.seconds = 0,
    this.speedMultiplier = 1,
    this.kills = 0,
    this.lives = 0,
    this.gameOver = false,
  });

  /// Pets already on the map (each raised pet can be placed once).
  final Set<String> placedIds;

  /// PetEntity the next tap on the map places; `null` when all are placed.
  final String? selectedId;
  final int seconds;
  final double speedMultiplier;
  final int kills;
  final int lives;
  final bool gameOver;

  bool get anyPlaced => placedIds.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is DefenseHudState &&
      setEquals(other.placedIds, placedIds) &&
      other.selectedId == selectedId &&
      other.seconds == seconds &&
      other.speedMultiplier == speedMultiplier &&
      other.kills == kills &&
      other.lives == lives &&
      other.gameOver == gameOver;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(placedIds),
    selectedId,
    seconds,
    speedMultiplier,
    kills,
    lives,
    gameOver,
  );
}
