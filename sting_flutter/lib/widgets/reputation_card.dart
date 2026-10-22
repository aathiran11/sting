import 'package:flutter/material.dart';
import '../models/streak_tier.dart';
import '../theme.dart';

class ReputationCard extends StatelessWidget {
  final int streak;
  final int score;
  final int freezePasses;
  final VoidCallback? onFreezeTap;
  final VoidCallback? onRecapTap;

  const ReputationCard({
    super.key,
    required this.streak,
    required this.score,
    required this.freezePasses,
    this.onFreezeTap,
    this.onRecapTap,
  });

  String _getScoreRating(int score) {
    if (score >= 800) return "Top 1% Authentic";
    if (score >= 500) return "High Trust";
    if (score >= 250) return "Consistent Proof";
    return "Building Trust";
  }

  @override
  Widget build(BuildContext context) {
    final tier = StreakTier.fromDays(streak);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xB3150D2B),
        border: Border.all(color: T.violet.withValues(alpha: 0.28), width: 1.2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: T.violet.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: T.violet.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.shield_rounded, size: 14, color: T.violetGlow),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    "REAL REPUTATION",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: T.muted,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              if (onRecapTap != null)
                InkWell(
                  onTap: onRecapTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x331E1238),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insights_rounded, size: 12, color: T.violetGlow),
                        SizedBox(width: 5),
                        Text(
                          "Weekly Recap",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: T.violetGlow),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x66180E33),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: T.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sting Score",
                        style: TextStyle(fontSize: 11, color: T.muted, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "$score",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: T.violetGlow,
                            ),
                          ),
                          const Text(
                            " /1000",
                            style: TextStyle(fontSize: 11, color: T.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _getScoreRating(score),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: T.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x66180E33),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: T.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sting Freeze",
                        style: TextStyle(fontSize: 11, color: T.muted, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.ac_unit_rounded, size: 16, color: Color(0xFF00F0FF)),
                          const SizedBox(width: 6),
                          Text(
                            freezePasses > 0 ? "$freezePasses Pass Active" : "Recharging",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: freezePasses > 0 ? const Color(0xFF00F0FF) : T.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        freezePasses > 0 ? "Protects 1 missed day" : "1 every 90 days",
                        style: const TextStyle(fontSize: 10, color: T.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tier.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tier.accentColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(tier.icon, size: 15, color: tier.accentColor),
                    const SizedBox(width: 7),
                    Text(
                      "Milestone: ${tier.title}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: tier.accentColor,
                      ),
                    ),
                  ],
                ),
                if (tier.nextMilestoneDays != null)
                  Text(
                    "${tier.daysUntilNext(streak)} days to ${StreakTier.fromDays(tier.nextMilestoneDays!).title}",
                    style: const TextStyle(fontSize: 10, color: T.muted, fontWeight: FontWeight.w600),
                  )
                else
                  const Text(
                    "Highest Tier Achieved 🌌",
                    style: TextStyle(fontSize: 10, color: T.violetGlow, fontWeight: FontWeight.w800),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
