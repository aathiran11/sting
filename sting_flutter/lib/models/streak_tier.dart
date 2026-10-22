import 'package:flutter/material.dart';

enum TierType {
  none,
  bronze,
  silver,
  gold,
  diamond,
  legend,
}

class StreakTier {
  final TierType type;
  final String title;
  final String badgeText;
  final int minDays;
  final int? nextMilestoneDays;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const StreakTier({
    required this.type,
    required this.title,
    required this.badgeText,
    required this.minDays,
    this.nextMilestoneDays,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });

  static StreakTier fromDays(int streak) {
    if (streak >= 1000) {
      return const StreakTier(
        type: TierType.legend,
        title: "Legend",
        badgeText: "🌌 Legend",
        minDays: 1000,
        nextMilestoneDays: null,
        gradientColors: [Color(0xFFFF0055), Color(0xFFFFAA00), Color(0xFF7928CA)],
        accentColor: Color(0xFFFF2A85),
        icon: Icons.auto_awesome,
      );
    }
    if (streak >= 365) {
      return const StreakTier(
        type: TierType.diamond,
        title: "Diamond",
        badgeText: "💎 Diamond",
        minDays: 365,
        nextMilestoneDays: 1000,
        gradientColors: [Color(0xFF00F0FF), Color(0xFF7000FF), Color(0xFF00FFE0)],
        accentColor: Color(0xFF00E5FF),
        icon: Icons.diamond_outlined,
      );
    }
    if (streak >= 100) {
      return const StreakTier(
        type: TierType.gold,
        title: "Gold",
        badgeText: "👑 Gold",
        minDays: 100,
        nextMilestoneDays: 365,
        gradientColors: [Color(0xFFFFD700), Color(0xFFFF9E00), Color(0xFFFFE066)],
        accentColor: Color(0xFFFFC107),
        icon: Icons.emoji_events_outlined,
      );
    }
    if (streak >= 30) {
      return const StreakTier(
        type: TierType.silver,
        title: "Silver",
        badgeText: "⚡ Silver",
        minDays: 30,
        nextMilestoneDays: 100,
        gradientColors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFFCBD5E1)],
        accentColor: Color(0xFFCBD5E1),
        icon: Icons.bolt,
      );
    }
    if (streak >= 7) {
      return const StreakTier(
        type: TierType.bronze,
        title: "Bronze",
        badgeText: "🥉 Bronze",
        minDays: 7,
        nextMilestoneDays: 30,
        gradientColors: [Color(0xFFCD7F32), Color(0xFFA0522D), Color(0xFFD49B6A)],
        accentColor: Color(0xFFD49B6A),
        icon: Icons.shield_outlined,
      );
    }
    return const StreakTier(
      type: TierType.none,
      title: "Rookie",
      badgeText: "🔥 Rookie",
      minDays: 0,
      nextMilestoneDays: 7,
      gradientColors: [Color(0xFF334155), Color(0xFF1E293B)],
      accentColor: Color(0xFF64748B),
      icon: Icons.local_fire_department,
    );
  }

  /// Calculates days left until the next streak tier
  int daysUntilNext(int currentStreak) {
    if (nextMilestoneDays == null) return 0;
    return (nextMilestoneDays! - currentStreak).clamp(0, 1000);
  }
}
