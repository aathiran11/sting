import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../screens/user_profile_screen.dart';
import 'streak_badge.dart';

class UserTile extends StatefulWidget {
  final String username;
  final String name;
  final int streak;
  final AppState state;
  final VoidCallback onChanged;
  const UserTile({
    super.key,
    required this.username,
    required this.name,
    required this.streak,
    required this.state,
    required this.onChanged,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool busy = false;

  Color _auraColor(String username) {
    final colors = [
      const Color(0xFF00F0FF), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFFF2E63), // Coral
      const Color(0xFFA855F7), // Violet
      const Color(0xFFFFB703), // Amber
    ];
    return colors[username.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final following = widget.state.isFollowing(widget.username);
    final initial = (widget.name.isNotEmpty ? widget.name : widget.username).substring(0, 1).toUpperCase();
    final aura = _auraColor(widget.username);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserProfileScreen(username: widget.username, state: widget.state)),
      ),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: aura, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: aura.withValues(alpha: 0.35),
              blurRadius: 8,
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF1B1033),
          child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
      ),
      title: Text(
        widget.name.isEmpty ? widget.username : widget.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Text("@${widget.username}", style: const TextStyle(fontSize: 12, color: T.muted)),
            const SizedBox(width: 8),
            StreakBadge(streak: widget.streak, compact: true),
          ],
        ),
      ),
      trailing: SizedBox(
        width: 96,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(34),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: following ? Colors.transparent : T.violet,
            foregroundColor: Colors.white,
            side: BorderSide(color: following ? T.line : T.violet),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await widget.state.toggleFollow(widget.username);
                    widget.onChanged();
                  } catch (_) {
                    if (mounted) {
                      messenger.showSnackBar(const SnackBar(content: Text("Couldn't update follow.")));
                    }
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
          child: busy
              ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  following ? "Following" : "Follow",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
