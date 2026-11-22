import 'entities/pet_status_entity.dart';
import 'pet_status_balance.dart';

/// High-level emotional state, derived (never stored) from the status.
/// Ordered by priority: the first matching mood wins.
enum PetMood { sleeping, hungry, tired, dirty, sad, content, happy }

extension PetMoodX on PetStatusEntity {
  /// Average of all stats, 0..1.
  double get wellbeing =>
      (satiety + energy + happiness + hygiene) / (4 * PetStatusBalance.maxStat);

  PetMood get mood {
    if (isSleeping) return PetMood.sleeping;
    if (satiety < 25) return PetMood.hungry;
    if (energy < 20) return PetMood.tired;
    if (hygiene < 25) return PetMood.dirty;
    if (happiness < 35) return PetMood.sad;
    if (happiness >= 70 && wellbeing >= 0.65) return PetMood.happy;
    return PetMood.content;
  }
}
