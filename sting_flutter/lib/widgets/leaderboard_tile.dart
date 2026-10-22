import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/leaderboard_entry.dart';
import '../screens/user_profile_screen.dart';
import '../theme.dart';
import 'streak_badge.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final AppState state;
  final bool sortByScore;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.entry,
    required this.state,
    this.sortByScore = false,
  });

  Widget _buildRankBadge() {
    if (rank == 1) {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8800)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB703).withValues(alpha: 0.6),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Text("1", style: TextStyle(color: Color(0xFF0E071A), fontWeight: FontWeight.w900, fontSize: 14)),
      );
    }
    if (rank == 2) {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF94A3B8).withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Text("2", style: TextStyle(color: Color(0xFF0E071A), fontWeight: FontWeight.w900, fontSize: 14)),
      );
    }
    if (rank == 3) {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFB923C), Color(0xFFC2410C)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFB923C).withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Text("3", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
      );
    }
    return SizedBox(
      width: 32,
      child: Text(
        "#$rank",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: T.muted),
      ),
    );
  }

  Color _rankAuraColor() {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF00F0FF);
    if (rank == 3) return const Color(0xFFFF2E63);
    return T.violet.withValues(alpha: 0.6);
  }

  @override
  Widget build(BuildContext context) {
    final isMe = state.username.isNotEmpty && entry.username.toLowerCase() == state.username.toLowerCase();
    final initial = (entry.name.isNotEmpty ? entry.name : entry.username).substring(0, 1).toUpperCase();
    final aura = _rankAuraColor();

    return InkWell(
      onTap: () {
        if (!isMe) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(username: entry.username, state: state),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isMe ? T.violet.withValues(alpha: 0.16) : const Color(0xB3150D2B),
          border: Border.all(
            color: isMe
                ? T.violet
                : rank == 1
                    ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                    : T.line,
            width: isMe || rank == 1 ? 1.4 : 1.0,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (isMe || rank == 1)
              BoxShadow(
                color: (isMe ? T.violet : const Color(0xFFFFD700)).withValues(alpha: 0.18),
                blurRadius: 14,
              ),
          ],
        ),
        child: Row(
          children: [
            _buildRankBadge(),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: aura, width: rank <= 3 ? 2 : 1),
                boxShadow: rank <= 3
                    ? [
                        BoxShadow(
                          color: aura.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF1B1130),
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name.isNotEmpty ? entry.name : entry.username,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: T.violet,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "YOU",
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "@${entry.username}",
                    style: const TextStyle(fontSize: 11, color: T.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (sortByScore)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${entry.stingScore} pts",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: T.violetGlow),
                  ),
                  const SizedBox(height: 3),
                  StreakBadge(streak: entry.streak, compact: true),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StreakBadge(streak: entry.streak, compact: true),
                  const SizedBox(height: 3),
                  Text(
                    "${entry.stingScore} pts",
                    style: const TextStyle(fontSize: 11, color: T.muted),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
