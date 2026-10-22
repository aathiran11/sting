import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/daily_task.dart';
import '../data/mock_data.dart';
import '../models/leaderboard_entry.dart';
import '../theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/avatar_constellation.dart';
import '../widgets/friend_challenge_modal.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/spectrum_bar.dart';
import 'user_profile_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  final AppState state;
  const LeaderboardScreen({super.key, required this.state});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String sortMode = "streaks"; // "streaks", "scores", "friends"
  bool loading = true;
  List<LeaderboardEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      List<dynamic> raw;
      if (sortMode == "scores") {
        raw = await widget.state.api.getLeaderboardScores();
      } else if (sortMode == "friends") {
        raw = await widget.state.api.getLeaderboardFriends();
      } else {
        raw = await widget.state.api.getLeaderboardStreaks();
      }
      if (mounted) setState(() => entries = raw.map((j) => LeaderboardEntry.fromJson(j)).toList());
    } catch (_) {
      // Offline fallback: derive from mockUsers
      if (mounted) {
        final sorted = List<SUser>.from(mockUsers);
        if (sortMode == "scores") {
          sorted.sort((a, b) => b.stingScore.compareTo(a.stingScore));
        } else {
          sorted.sort((a, b) => b.streak.compareTo(a.streak));
        }
        setState(() {
          entries = sorted
              .map((u) => LeaderboardEntry(
                    id: u.username.hashCode,
                    username: u.username,
                    name: u.name,
                    streak: u.streak,
                    streakTier: u.streakTier,
                    stingScore: u.stingScore,
                    bio: u.bio,
                  ))
              .toList();
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _openProfile(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(username: username, state: widget.state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top header with back pill and notification bell badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0x331E1238),
                              shape: BoxShape.circle,
                              border: Border.all(color: T.line),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 18, color: T.text),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0x331E1238),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: T.line),
                                ),
                                child: const Icon(Icons.notifications_none_rounded, size: 20, color: T.text),
                              ),
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: T.coral,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: T.coral.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "3",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Avatar constellation directly inspired by Dribbble UI
                      AvatarConstellation(
                        onMemberTap: _openProfile,
                        onAddTap: () {
                          FriendChallengeModal.show(
                            context,
                            friendUsername: "priya_m",
                            taskLabel: todaysTask(),
                            state: widget.state,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Performance Overview & 61% Hero Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xBF140C2A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: T.violet.withValues(alpha: 0.28),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: T.violet.withValues(alpha: 0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Analytics Team",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Performance Overview",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: T.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: T.violet.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    "Team Score",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: T.violetGlow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  "61%",
                                  style: TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5,
                                    height: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: T.green,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "+14.2% vs last week",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: T.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Daily Active Proofs",
                                      style: TextStyle(fontSize: 10, color: T.muted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Equalizer spectrum vertical bar
                            const SpectrumBar(
                              progress: 0.61,
                              barCount: 36,
                              height: 22,
                              leftLabel: "Time tracking",
                              rightLabel: "Efficiency: 97%",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Pill Tab Bar
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xCC130B24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: T.line),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: T.violet,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: T.violet.withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: T.muted,
                          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          padding: const EdgeInsets.all(4),
                          tabs: const [
                            Tab(text: "🔥 Streaks"),
                            Tab(text: "⭐ Score"),
                            Tab(text: "⚔️ 1v1 Bets"),
                          ],
                          onTap: (index) {
                            if (index == 0) sortMode = "streaks";
                            if (index == 1) sortMode = "scores";
                            if (index < 2) _load();
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildRankingsList(isScore: false),
                _buildRankingsList(isScore: true),
                _buildChallengeBetsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingsList({required bool isScore}) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: T.violet));
    }
    if (entries.isEmpty) {
      return const Center(child: Text("No rankings found.", style: TextStyle(color: T.muted)));
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: T.violet,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
        itemCount: entries.length,
        itemBuilder: (_, i) => LeaderboardTile(
          rank: i + 1,
          entry: entries[i],
          state: widget.state,
          sortByScore: isScore,
        ),
      ),
    );
  }

  Widget _buildChallengeBetsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                T.coral.withValues(alpha: 0.2),
                const Color(0xD9160D2D),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: T.coral.withValues(alpha: 0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: T.coral.withValues(alpha: 0.12),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: T.coral.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "ACTIVE HEAD-TO-HEAD",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: T.coral,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Text("Closes 11:59 PM", style: TextStyle(fontSize: 11, color: T.violetGlow, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                todaysTask(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                "Both participants must post an Unfiltered live capture before midnight. Winners receive +50 XP and a profile showcase flair.",
                style: TextStyle(fontSize: 12, color: T.muted, height: 1.35),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: T.coral,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  shadowColor: T.coral.withValues(alpha: 0.5),
                  elevation: 8,
                ),
                onPressed: () {
                  FriendChallengeModal.show(
                    context,
                    friendUsername: "priya_m",
                    taskLabel: todaysTask(),
                    state: widget.state,
                  );
                },
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text("Challenge a Friend Now", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "FEATURED RIVALRIES",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: T.muted, letterSpacing: 0.6),
        ),
        const SizedBox(height: 10),
        _buildBetCard(
          user1: "priya_m",
          user2: "kwame_o",
          task: "One set or rep you almost skipped",
          user1Done: true,
          user2Done: false,
          stakes: "+50 XP • Gold Border",
        ),
        _buildBetCard(
          user1: "sana.k",
          user2: "devon.p",
          task: "Small act of kindness in progress",
          user1Done: true,
          user2Done: true,
          stakes: "Both Completed! 👑",
          isWinner: true,
        ),
      ],
    );
  }

  Widget _buildBetCard({
    required String user1,
    required String user2,
    required String task,
    required bool user1Done,
    required bool user2Done,
    required String stakes,
    bool isWinner = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xB3150D2B),
        border: Border.all(
          color: isWinner ? T.green.withValues(alpha: 0.5) : T.line,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "@$user1  ⚔️  @$user2",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isWinner ? T.green.withValues(alpha: 0.15) : T.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stakes,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isWinner ? T.green : T.violetGlow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(task, style: const TextStyle(fontSize: 12, color: T.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              _participantChip(user1, user1Done),
              const SizedBox(width: 8),
              _participantChip(user2, user2Done),
            ],
          ),
        ],
      ),
    );
  }

  Widget _participantChip(String username, bool done) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: done ? T.green.withValues(alpha: 0.14) : T.surface2,
          border: Border.all(color: done ? T.green : T.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(done ? Icons.check_circle : Icons.hourglass_top, size: 13, color: done ? T.green : T.muted),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                "@$username",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: done ? T.green : T.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
