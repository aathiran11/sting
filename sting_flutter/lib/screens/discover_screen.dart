import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/mock_data.dart';
import '../models/leaderboard_entry.dart';
import '../theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/user_tile.dart';

class DiscoverScreen extends StatefulWidget {
  final AppState state;
  const DiscoverScreen({super.key, required this.state});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String query = "";
  String selectedCategory = "All";
  String leaderboardSort = "streaks"; // "streaks", "scores", "friends"

  bool loadingUsers = true;
  bool loadingLeaderboard = true;
  List<SuggestedUser> suggested = [];
  List<LeaderboardEntry> leaderboard = [];

  final List<String> categories = const [
    "All",
    "Fitness",
    "Kindness",
    "Learning",
    "Nature",
    "Productivity",
    "Mental Health",
    "Creativity",
    "Photography",
    "Finance",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => loadingUsers = true);
    try {
      final raw = await widget.state.api.suggested();
      if (mounted) setState(() => suggested = raw.map((j) => SuggestedUser.fromJson(j)).toList());
    } catch (_) {
      // Offline fallback: load rich mock users
      if (mounted) {
        setState(() {
          suggested = mockUsers
              .map((u) => SuggestedUser(
                    username: u.username,
                    name: u.name,
                    bio: u.bio,
                    interest: u.interest,
                    streak: u.streak,
                    streakTier: u.streakTier,
                    stingScore: u.stingScore,
                  ))
              .toList();
        });
      }
    } finally {
      if (mounted) setState(() => loadingUsers = false);
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => loadingLeaderboard = true);
    try {
      List<dynamic> raw;
      if (leaderboardSort == "scores") {
        raw = await widget.state.api.getLeaderboardScores();
      } else if (leaderboardSort == "friends") {
        raw = await widget.state.api.getLeaderboardFriends();
      } else {
        raw = await widget.state.api.getLeaderboardStreaks();
      }
      if (mounted) setState(() => leaderboard = raw.map((j) => LeaderboardEntry.fromJson(j)).toList());
    } catch (_) {
      // Offline fallback: derive leaderboard from mockUsers
      if (mounted) {
        final sorted = List<SUser>.from(mockUsers);
        if (leaderboardSort == "scores") {
          sorted.sort((a, b) => b.stingScore.compareTo(a.stingScore));
        } else {
          sorted.sort((a, b) => b.streak.compareTo(a.streak));
        }
        setState(() {
          leaderboard = sorted
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
      if (mounted) setState(() => loadingLeaderboard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      "Explore",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xCC130B24),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: T.line),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: T.violet,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: T.violet.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: T.muted,
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        padding: const EdgeInsets.all(3),
                        tabs: const [
                          Tab(text: "Discover"),
                          Tab(text: "🏆 Podium"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDiscoverTab(),
                    _buildLeaderboardTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final filtered = suggested.where((u) {
      final matchesQuery = query.isEmpty ||
          u.name.toLowerCase().contains(query.toLowerCase()) ||
          u.username.toLowerCase().contains(query.toLowerCase());
      final matchesCat = selectedCategory == "All" ||
          u.interest.toLowerCase() == selectedCategory.toLowerCase();
      return matchesQuery && matchesCat;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: T.violet,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0x80150D2B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.violet.withValues(alpha: 0.25)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                hintText: "Search authentic creators & habits",
                prefixIcon: Icon(Icons.search_rounded, color: T.muted, size: 20),
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedCategory = cat),
                  backgroundColor: const Color(0x80180F33),
                  selectedColor: T.violet,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : T.muted,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? T.violet : T.line,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AUTHENTIC CREATORS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: T.muted,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: T.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Zero Filters Live",
                  style: TextStyle(fontSize: 10, color: T.green, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (loadingUsers)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: T.violet)))
          else if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text("No creators match this category or query.", style: TextStyle(color: T.muted)),
              ),
            )
          else
            ...filtered.map(
              (u) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xB3150D2B),
                  border: Border.all(color: T.line),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: UserTile(
                  username: u.username,
                  name: u.name,
                  streak: u.streak,
                  state: widget.state,
                  onChanged: () => setState(() {}),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              _filterButton("🔥 Streaks", "streaks"),
              const SizedBox(width: 8),
              _filterButton("⭐ Sting Score", "scores"),
              const SizedBox(width: 8),
              _filterButton("👥 Friends", "friends"),
            ],
          ),
        ),
        Expanded(
          child: loadingLeaderboard
              ? const Center(child: CircularProgressIndicator(color: T.violet))
              : RefreshIndicator(
                  onRefresh: _loadLeaderboard,
                  color: T.violet,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                    itemCount: leaderboard.length,
                    itemBuilder: (_, i) => LeaderboardTile(
                      rank: i + 1,
                      entry: leaderboard[i],
                      state: widget.state,
                      sortByScore: leaderboardSort == "scores",
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _filterButton(String label, String value) {
    final selected = leaderboardSort == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => leaderboardSort = value);
          _loadLeaderboard();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? T.violet.withValues(alpha: 0.22) : const Color(0x80180F33),
            border: Border.all(color: selected ? T.violet : T.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? Colors.white : T.muted,
            ),
          ),
        ),
      ),
    );
  }
}
