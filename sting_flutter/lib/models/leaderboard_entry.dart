import 'streak_tier.dart';

class LeaderboardEntry {
  final int id;
  final String username;
  final String name;
  final int streak;
  final String streakTier;
  final int stingScore;
  final String bio;

  const LeaderboardEntry({
    required this.id,
    required this.username,
    required this.name,
    required this.streak,
    required this.streakTier,
    required this.stingScore,
    this.bio = "",
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) {
    final s = j["current_streak"] ?? j["currentStreak"] ?? 0;
    return LeaderboardEntry(
      id: j["id"] ?? 0,
      username: j["username"] ?? "",
      name: j["name"] ?? "",
      streak: s,
      streakTier: j["streak_tier"] ?? j["streakTier"] ?? StreakTier.fromDays(s).title,
      stingScore: j["sting_score"] ?? j["stingScore"] ?? 100,
      bio: j["bio"] ?? "",
    );
  }
}
