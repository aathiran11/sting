import 'package:flutter/material.dart';
import '../models/verification.dart';
import '../theme.dart';

class CommunityVerificationBar extends StatelessWidget {
  final VerificationStats stats;
  final Function(String reaction) onReact;
  final VoidCallback onClear;

  const CommunityVerificationBar({
    super.key,
    required this.stats,
    required this.onReact,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user_rounded, size: 12, color: T.violetGlow.withValues(alpha: 0.8)),
                const SizedBox(width: 5),
                const Text(
                  "COMMUNITY VERIFICATION",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: T.muted,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            if (stats.totalCommunityVotes > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (stats.trustPercent >= 80 ? T.green : T.coral).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${stats.trustPercent}% Authentic",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: stats.trustPercent >= 80 ? T.green : T.coral,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ReactionChip(
              emoji: "✅",
              label: "Verified",
              count: stats.verifiedCount,
              isSelected: stats.myReaction == "verified",
              selectedColor: T.green,
              onTap: () {
                if (stats.myReaction == "verified") {
                  onClear();
                } else {
                  onReact("verified");
                }
              },
            ),
            const SizedBox(width: 8),
            _ReactionChip(
              emoji: "⭐",
              label: "Inspiring",
              count: stats.inspiringCount,
              isSelected: stats.myReaction == "inspiring",
              selectedColor: T.violetGlow,
              onTap: () {
                if (stats.myReaction == "inspiring") {
                  onClear();
                } else {
                  onReact("inspiring");
                }
              },
            ),
            const SizedBox(width: 8),
            _ReactionChip(
              emoji: "⚠️",
              label: "Review",
              count: stats.reviewCount,
              isSelected: stats.myReaction == "needs_review",
              selectedColor: T.coral,
              onTap: () {
                if (stats.myReaction == "needs_review") {
                  onClear();
                } else {
                  onReact("needs_review");
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.emoji,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withValues(alpha: 0.18) : const Color(0x661A0F35),
            border: Border.all(
              color: isSelected ? selectedColor : T.line,
              width: isSelected ? 1.4 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? selectedColor : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? selectedColor : T.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
