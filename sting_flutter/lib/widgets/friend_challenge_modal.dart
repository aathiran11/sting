import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import 'aperture.dart';

class FriendChallengeModal extends StatefulWidget {
  final String friendUsername;
  final String taskLabel;
  final AppState state;

  const FriendChallengeModal({
    super.key,
    required this.friendUsername,
    required this.taskLabel,
    required this.state,
  });

  static Future<void> show(
    BuildContext context, {
    required String friendUsername,
    required String taskLabel,
    required AppState state,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FriendChallengeModal(
        friendUsername: friendUsername,
        taskLabel: taskLabel,
        state: state,
      ),
    );
  }

  @override
  State<FriendChallengeModal> createState() => _FriendChallengeModalState();
}

class _FriendChallengeModalState extends State<FriendChallengeModal> {
  bool sending = false;

  Future<void> _send() async {
    setState(() => sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      if (widget.state.api.isLoggedIn) {
        await widget.state.api.sendFriendChallenge(widget.friendUsername, widget.taskLabel);
      }
      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text("⚔️ Challenge sent to @${widget.friendUsername}! Finish before midnight to claim bonus XP."),
          backgroundColor: const Color(0xFF1B1130),
        ),
      );
    } catch (_) {
      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text("⚔️ Challenge issued to @${widget.friendUsername}!"),
          backgroundColor: const Color(0xFF1B1130),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF2120A24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: T.coral.withValues(alpha: 0.35), width: 1.2),
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
            decoration: BoxDecoration(color: T.line, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: T.coral.withValues(alpha: 0.15),
                ),
                child: const Aperture(size: 18, color: T.coral),
              ),
              const SizedBox(width: 8),
              const Text(
                "STING 1V1 CHALLENGE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: T.coral,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Challenge @${widget.friendUsername}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          const Text(
            "“I bet you can't finish today's Unfiltered.”",
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: T.muted),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xB3180E33),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: T.coral.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S MISSION",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: T.coral, letterSpacing: 0.6),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.taskLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Divider(color: T.line, height: 1),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Deadline", style: TextStyle(fontSize: 12, color: T.muted)),
                    Text("Tonight at 11:59 PM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: T.violetGlow)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stakes & Reward", style: TextStyle(fontSize: 12, color: T.muted)),
                    Text("+50 XP & Profile Crown", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: T.green)),
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
                colors: [T.coral, Color(0xFFE11D48)],
              ),
              boxShadow: [
                BoxShadow(
                  color: T.coral.withValues(alpha: 0.45),
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
              onPressed: sending ? null : _send,
              icon: sending
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.flash_on, size: 18),
              label: Text(
                sending ? "Issuing Challenge..." : "Send Challenge Bet",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
