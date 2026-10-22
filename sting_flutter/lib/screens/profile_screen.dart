import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/aperture.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/spectrum_bar.dart';
import '../widgets/streak_badge.dart';
import '../widgets/reputation_card.dart';
import '../widgets/weekly_recap_modal.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'follow_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState state;
  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final initial = (state.name.isNotEmpty ? state.name : (state.username.isNotEmpty ? state.username : "S"))
        .substring(0, 1)
        .toUpperCase();

    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0x331E1238),
                        shape: BoxShape.circle,
                        border: Border.all(color: T.line),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined, color: T.text, size: 20),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SettingsScreen(state: state)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Hero circular avatar with Dribbble glowing crimson aura
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: T.coral.withValues(alpha: 0.65),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: T.violet.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: T.coral, width: 3),
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2A1542), Color(0xFF0F081E)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  state.name.isEmpty ? "Your Name" : state.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                const SizedBox(height: 3),
                Text(
                  "@${state.username.isEmpty ? "username" : state.username}",
                  style: const TextStyle(fontSize: 13, color: T.muted),
                ),
                if (state.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFD4CCE6), height: 1.3),
                  ),
                ],
                const SizedBox(height: 14),
                StreakBadge(streak: state.myStreak, showMilestoneHint: true),
                const SizedBox(height: 18),

                // Frosted glass stats container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xB3150D2B),
                    border: Border.all(color: T.violet.withValues(alpha: 0.28), width: 1.2),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: T.violet.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(label: "Current Streak", value: "${state.myStreak}", flame: true),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FollowListScreen(state: state, showFollowingOnly: true),
                              ),
                            ),
                            child: _Stat(label: "Following", value: "${state.following.length}"),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FollowListScreen(state: state, showFollowingOnly: false),
                              ),
                            ),
                            child: const _Stat(label: "Followers", value: "—"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Spectrum consistency meter inside the stat card
                      SpectrumBar(
                        progress: (state.myStreak / 30.0).clamp(0.08, 1.0),
                        barCount: 30,
                        height: 16,
                        leftLabel: "Streak consistency",
                        rightLabel: "Top ${state.myStreak > 10 ? '5%' : '15%'} performer",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ReputationCard(
                  streak: state.myStreak,
                  score: state.myStingScore,
                  freezePasses: state.myFreezePasses,
                  onRecapTap: () {
                    WeeklyRecapModal.show(
                      context,
                      username: state.username.isEmpty ? "you" : state.username,
                      streak: state.myStreak,
                      score: state.myStingScore,
                    );
                  },
                ),
                const SizedBox(height: 16),

                if (state.myPosts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xB3150D2B),
                      border: Border.all(color: T.line),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 28, color: T.muted),
                        SizedBox(height: 8),
                        Text("No Unfiltered posts yet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text(
                          "Complete today's challenge to ignite your streak.",
                          style: TextStyle(fontSize: 12, color: T.muted),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: state.myPosts
                        .map((p) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xB3150D2B),
                                border: Border.all(color: T.violet.withValues(alpha: 0.25)),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        p.taskLabel,
                                        style: const TextStyle(
                                          color: T.violetGlow,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (p.verifiedLive)
                                        const Text("Verified live ✅", style: TextStyle(fontSize: 11, color: T.green, fontWeight: FontWeight.w700))
                                      else
                                        const Text("Low motion ⚠️", style: TextStyle(fontSize: 11, color: T.coral, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(p.caption, style: const TextStyle(fontSize: 13, height: 1.3)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 16),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: T.violet.withValues(alpha: 0.45)),
                    backgroundColor: const Color(0x33190E33),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen(state: state)),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool flame;
  const _Stat({required this.label, required this.value, this.flame = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          (flame ? "🔥 " : "") + value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: flame ? T.coral : Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: T.muted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
