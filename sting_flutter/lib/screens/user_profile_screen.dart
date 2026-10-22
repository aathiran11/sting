import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/daily_task.dart';
import '../data/mock_data.dart';
import '../theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/common.dart';
import '../widgets/friend_challenge_modal.dart';
import '../widgets/streak_badge.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;
  final AppState state;
  const UserProfileScreen({super.key, required this.username, required this.state});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? user;
  bool followBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await widget.state.api.getUser(widget.username);
      if (mounted) setState(() => user = data);
    } catch (_) {
      // Offline fallback: check mockUsers
      final mock = mockUsers.where((u) => u.username == widget.username).firstOrNull;
      if (mock != null && mounted) {
        setState(() {
          user = {
            "name": mock.name,
            "username": mock.username,
            "bio": mock.bio,
            "currentStreak": mock.streak,
            "longestStreak": mock.streak + 5,
            "streakTier": mock.streakTier,
            "stingScore": mock.stingScore,
          };
        });
      } else if (mounted) {
        setState(() => error = "Couldn't load this profile.");
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _auraColor(String username) {
    final colors = [
      const Color(0xFF00F0FF),
      const Color(0xFF10B981),
      const Color(0xFFFF2E63),
      const Color(0xFFA855F7),
      const Color(0xFFFFB703),
    ];
    return colors[username.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return AtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: StingTopBar(title: "@${widget.username}"),
          body: const Center(child: CircularProgressIndicator(color: T.violet)),
        ),
      );
    }
    if (error != null || user == null) {
      return AtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: StingTopBar(title: "@${widget.username}"),
          body: Center(child: Text(error ?? "Not found", style: const TextStyle(color: T.coral))),
        ),
      );
    }

    final u = user!;
    final following = widget.state.isFollowing(widget.username);
    final initial = ((u["name"] ?? "").isNotEmpty ? u["name"] : widget.username).substring(0, 1).toUpperCase();
    final streak = u["currentStreak"] ?? 0;
    final stingScore = u["stingScore"] ?? 100;
    final aura = _auraColor(widget.username);

    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: StingTopBar(title: "@${widget.username}"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: aura, width: 2.8),
                  boxShadow: [
                    BoxShadow(
                      color: aura.withValues(alpha: 0.55),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF1B1033),
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                u["name"] ?? "",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.3),
              ),
              const SizedBox(height: 2),
              Text("@${u["username"]}", style: const TextStyle(fontSize: 13, color: T.muted)),
              if ((u["bio"] ?? "").toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(u["bio"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFFD4CCE6))),
              ],
              const SizedBox(height: 14),
              StreakBadge(streak: streak, showMilestoneHint: true),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xB3150D2B),
                  border: Border.all(color: T.violet.withValues(alpha: 0.28), width: 1.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: T.violet.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat("🔥 $streak", "Streak", T.coral),
                    _stat("${u["longestStreak"] ?? streak}", "Best Streak", Colors.white),
                    _stat("$stingScore pts", "Sting Score", T.violetGlow),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: following ? const Color(0x661F133D) : T.violet,
                    foregroundColor: Colors.white,
                    side: BorderSide(color: following ? T.line : T.violet),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: following ? Colors.transparent : T.violet.withValues(alpha: 0.5),
                  ),
                  onPressed: followBusy
                      ? null
                      : () async {
                          setState(() => followBusy = true);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await widget.state.toggleFollow(widget.username);
                          } catch (_) {
                            if (mounted) {
                              messenger.showSnackBar(const SnackBar(content: Text("Couldn't update follow.")));
                            }
                          } finally {
                            if (mounted) setState(() => followBusy = false);
                          }
                        },
                  child: followBusy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          following ? "Following" : "Follow",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [T.coral.withValues(alpha: 0.25), const Color(0x331E1238)],
                  ),
                ),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: T.coral.withValues(alpha: 0.6)),
                    foregroundColor: T.coral,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    FriendChallengeModal.show(
                      context,
                      friendUsername: widget.username,
                      taskLabel: todaysTask(),
                      state: widget.state,
                    );
                  },
                  icon: const Icon(Icons.flash_on, size: 16),
                  label: const Text("Challenge to Today's Sting", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xB3150D2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: T.line),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 22, color: T.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Unfiltered Verified: Every post by this user is captured live inside Sting with zero gallery uploads or filters.",
                        style: TextStyle(fontSize: 12, color: T.muted, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: T.muted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
