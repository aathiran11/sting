import 'package:flutter/material.dart';
import '../models/streak_tier.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool compact;
  final bool showMilestoneHint;

  const StreakBadge({
    super.key,
    required this.streak,
    this.compact = false,
    this.showMilestoneHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final tier = StreakTier.fromDays(streak);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: tier.gradientColors.map((c) => c.withValues(alpha: 0.15)).toList(),
          ),
          border: Border.all(
            color: tier.accentColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tier.icon, size: 12, color: tier.accentColor),
            const SizedBox(width: 4),
            Text(
              "$streak",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tier.accentColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                tier.gradientColors.first.withValues(alpha: 0.25),
                tier.gradientColors.last.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: tier.accentColor.withValues(alpha: 0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: tier.accentColor.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tier.icon, size: 14, color: tier.accentColor),
              const SizedBox(width: 5),
              Text(
                "🔥 $streak",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tier.accentColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tier.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: tier.accentColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        if (showMilestoneHint && tier.nextMilestoneDays != null) ...[
          const SizedBox(height: 4),
          Text(
            "${tier.daysUntilNext(streak)}d to ${StreakTier.fromDays(tier.nextMilestoneDays!).title}",
            style: TextStyle(
              fontSize: 10,
              color: tier.accentColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
