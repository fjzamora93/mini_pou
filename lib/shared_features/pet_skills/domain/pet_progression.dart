import 'entities/pet_skills_entity.dart';

/// Experience and levels. 1 defeated enemy = 1 XP. Reaching level n+1 from
/// level n costs `10 * (n + 1)` XP (10, 20, 30...), and the XP counter resets
/// to 0 on every level-up. Level 10 is the cap.
abstract final class PetProgression {
  static const maxLevel = 10;
  static const xpPerEnemy = 1;

  /// XP needed to go from [level] to the next one; 0 at the cap.
  static int xpToNextLevel(int level) =>
      level >= maxLevel ? 0 : 10 * (level + 1);

  static bool isMaxLevel(PetSkillsEntity skills) => skills.level >= maxLevel;

  /// Progress towards the next level, 0..1 (1 at the cap).
  static double levelProgress(PetSkillsEntity skills) {
    final need = xpToNextLevel(skills.level);
    return need == 0 ? 1 : skills.xp / need;
  }

  /// Adds [amount] XP, levelling up when it pays for the next level. Leftover
  /// XP beyond a level-up is discarded ("los puntos se resetean a 0").
  /// At the cap XP stays at 0.
  static PetSkillsEntity gainXp(PetSkillsEntity skills, int amount) {
    if (amount <= 0 || isMaxLevel(skills)) return skills;
    final xp = skills.xp + amount;
    final need = xpToNextLevel(skills.level);
    if (xp < need) return skills.copyWith(xp: xp);
    return skills.copyWith(level: skills.level + 1, xp: 0);
  }
}
