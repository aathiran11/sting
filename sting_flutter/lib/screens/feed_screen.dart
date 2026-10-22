import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/daily_task.dart';
import '../data/mock_data.dart';
import '../theme.dart';
import '../widgets/aperture.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/daily_window_banner.dart';
import '../widgets/community_verification_bar.dart';
import '../widgets/streak_badge.dart';
import 'camera_screen.dart';

class FeedScreen extends StatefulWidget {
  final AppState state;
  const FeedScreen({super.key, required this.state});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool loading = true;
  String? error;
  String source = "trending";
  List<FeedPost> posts = [];
  Map<String, dynamic>? todayTask;

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
      final feed = await widget.state.api.feed();
      final task = await widget.state.api.todaysTask();
      await widget.state.refreshMyPosts();
      if (mounted) {
        setState(() {
          source = feed["source"] ?? "trending";
          posts = (feed["posts"] as List).map((p) => FeedPost.fromJson(p)).toList();
          todayTask = task;
        });
      }
    } catch (_) {
      // Offline fallback: load mock posts & deterministic task
      if (mounted) {
        setState(() {
          source = "trending (demo)";
          posts = mockPosts
              .map((p) => FeedPost(
                    id: p.id,
                    username: p.username,
                    name: p.username,
                    taskLabel: p.taskLabel,
                    category: p.category,
                    caption: p.caption,
                    streak: p.streak,
                    streakTier: p.streakTier,
                    stingScore: p.stingScore,
                    likes: p.likes,
                    createdAt: p.timeAgo,
                    verification: p.verification,
                  ))
              .toList();
          todayTask = {
            "label": todaysTask(),
            "category": todaysCategory(),
          };
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openCamera() async {
    final label = todayTask?["label"] ?? todaysTask();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCaptureScreen(state: widget.state, taskLabel: label),
        fullscreenDialog: true,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final label = todayTask?["label"] ?? todaysTask();
    final category = todayTask?["category"] ?? todaysCategory();

    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: T.violet.withValues(alpha: 0.18),
                        border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                      ),
                      child: const Aperture(size: 20, color: T.violetGlow),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "sting",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    StreakBadge(streak: widget.state.myStreak, compact: true),
                  ],
                ),
              ),
              DailyWindowBanner(
                state: widget.state,
                label: label,
                category: category,
                onCaptureTap: _openCamera,
              ),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: T.violet))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: T.violet,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                          children: [
                            ...widget.state.myPosts.map((p) => _MyPostCard(post: p, state: widget.state)),
                            if (posts.isEmpty && widget.state.myPosts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Center(
                                  child: Text(
                                    "No posts yet — be the first Unfiltered today.",
                                    style: TextStyle(color: T.muted),
                                  ),
                                ),
                              ),
                            ...posts.map((p) => _PostCard(
                                  post: p,
                                  state: widget.state,
                                  onVerificationChanged: () => setState(() {}),
                                )),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPostCard extends StatelessWidget {
  final MyPost post;
  final AppState state;
  const _MyPostCard({required this.post, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xB3150D2B),
        border: Border.all(color: T.violet.withValues(alpha: 0.4), width: 1.2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: T.violet.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: T.coral, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: T.coral.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF1E1238),
                    child: Text(
                      state.username.isNotEmpty ? state.username[0].toUpperCase() : "Y",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "@${state.username.isEmpty ? 'you' : state.username}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (post.verifiedLive ? T.green : T.coral).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.verifiedLive ? Icons.verified : Icons.warning_amber_rounded,
                        size: 11,
                        color: post.verifiedLive ? T.green : T.coral,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.verifiedLive ? "Unfiltered Live" : "Unverified Motion",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: post.verifiedLive ? T.green : T.coral,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                StreakBadge(streak: state.myStreak, compact: true),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.taskLabel,
              style: const TextStyle(color: T.violetGlow, fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(post.caption, style: const TextStyle(fontSize: 14, height: 1.35)),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final FeedPost post;
  final AppState state;
  final VoidCallback onVerificationChanged;

  const _PostCard({
    required this.post,
    required this.state,
    required this.onVerificationChanged,
  });

  // Assign a distinct neon aura color for each user like the Dribbble constellation
  Color _userAuraColor(String username) {
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
    final aura = _userAuraColor(post.username);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xB3150D2B),
        border: Border.all(color: T.line),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: aura, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: aura.withValues(alpha: 0.45),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF1B1033),
                    child: Text(
                      post.username.isNotEmpty ? post.username[0].toUpperCase() : "?",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@${post.username}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "Sting Score: ${post.stingScore}",
                        style: const TextStyle(fontSize: 11, color: T.muted),
                      ),
                    ],
                  ),
                ),
                StreakBadge(streak: post.streak, compact: true),
              ],
            ),
          ),
          Container(
            height: 240,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F081E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.violet.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle camera lens circular ring overlay
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: T.violet.withValues(alpha: 0.15), width: 1.5),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: T.surface2.withValues(alpha: 0.8),
                        border: Border.all(color: T.line),
                      ),
                      child: const Aperture(size: 32, color: T.violetGlow),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Live Unfiltered Capture",
                      style: TextStyle(color: T.text, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Zero Gallery Uploads • Verified Live",
                      style: TextStyle(color: T.muted, fontSize: 10),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: T.green.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: T.green),
                        SizedBox(width: 4),
                        Text(
                          "Unfiltered Verified",
                          style: TextStyle(fontSize: 10, color: T.green, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              post.taskLabel,
              style: const TextStyle(
                color: T.violetGlow,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Text(post.caption, style: const TextStyle(fontSize: 14, height: 1.3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: CommunityVerificationBar(
              stats: post.verification,
              onReact: (reaction) async {
                await state.reactToPost(post, reaction);
                onVerificationChanged();
              },
              onClear: () async {
                await state.clearReaction(post);
                onVerificationChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}
