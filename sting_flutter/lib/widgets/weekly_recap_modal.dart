import 'package:flutter/material.dart';
import '../models/streak_tier.dart';
import '../theme.dart';
import 'aperture.dart';

class WeeklyRecapModal extends StatelessWidget {
  final String username;
  final int streak;
  final int score;
  final int challengesCompleted;
  final int verifiedReceived;

  const WeeklyRecapModal({
    super.key,
    required this.username,
    required this.streak,
    required this.score,
    required this.challengesCompleted,
    required this.verifiedReceived,
  });

  static Future<void> show(
    BuildContext context, {
    required String username,
    required int streak,
    required int score,
    int challengesCompleted = 6,
    int verifiedReceived = 18,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WeeklyRecapModal(
        username: username,
        streak: streak,
        score: score,
        challengesCompleted: challengesCompleted,
        verifiedReceived: verifiedReceived,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = StreakTier.fromDays(streak);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF2120A24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: T.violet.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: T.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: T.violet.withValues(alpha: 0.18),
                ),
                child: const Aperture(size: 18, color: T.violetGlow),
              ),
              const SizedBox(width: 8),
              const Text(
                "STING WEEKLY RECAP",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: T.violetGlow,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Authentic Consistency • @$username",
            style: const TextStyle(fontSize: 14, color: T.muted),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xB3180E33),
              border: Border.all(color: T.violet.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: T.violet.withValues(alpha: 0.1),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _RecapStat(label: "Completed", value: "$challengesCompleted/7", icon: Icons.task_alt_rounded),
                    _RecapStat(label: "Current Streak", value: "🔥 $streak", icon: Icons.local_fire_department_rounded),
                    _RecapStat(label: "Peer Verified", value: "✅ $verifiedReceived", icon: Icons.verified_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: T.line, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Current Milestone", style: TextStyle(fontSize: 11, color: T.muted)),
                        const SizedBox(height: 2),
                        Text(
                          tier.badgeText,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tier.accentColor),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Sting Score", style: TextStyle(fontSize: 11, color: T.muted)),
                        const SizedBox(height: 2),
                        Text(
                          "$score pts",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: T.violetGlow),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [T.violet, Color(0xFF9333EA)],
              ),
              boxShadow: [
                BoxShadow(
                  color: T.violet.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Weekly Recap card copied to clipboard for sharing!"),
                    backgroundColor: Color(0xFF1B1130),
                  ),
                );
              },
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text("Share Consistency Card", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _RecapStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: T.violetGlow),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: T.muted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
