import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data/daily_task.dart';
import '../theme.dart';
import '../widgets/aperture.dart';
import 'feed_screen.dart';
import 'discover_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';

class MainShell extends StatefulWidget {
  final AppState state;
  const MainShell({super.key, required this.state});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  Future<void> _openCamera() async {
    String label;
    try {
      final task = await widget.state.api.todaysTask();
      label = task["label"] ?? todaysTask();
    } catch (_) {
      label = todaysTask(); // offline fallback
    }
    if (!mounted) return;
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
    final screens = [
      FeedScreen(state: widget.state),
      DiscoverScreen(state: widget.state),
      LeaderboardScreen(state: widget.state),
      ProfileScreen(state: widget.state),
    ];

    return Scaffold(
      backgroundColor: T.bg,
      extendBody: true,
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xF2100824),
              borderRadius: BorderRadius.circular(33),
              border: Border.all(
                color: T.violet.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: T.violet.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dockItem(icon: Icons.view_day_rounded, label: "Feed", targetIndex: 0),
                _dockItem(icon: Icons.explore_rounded, label: "Explore", targetIndex: 1),
                _cameraDockButton(),
                _dockItem(icon: Icons.emoji_events_rounded, label: "Ranks", targetIndex: 2),
                _dockItem(icon: Icons.person_rounded, label: "Profile", targetIndex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dockItem({
    required IconData icon,
    required String label,
    required int targetIndex,
  }) {
    final selected = index == targetIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => index = targetIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? T.violet.withValues(alpha: 0.22) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : const Color(0xFF867A9E),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 4 : 0,
              height: selected ? 4 : 0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: T.violet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraDockButton() {
    final isDone = widget.state.postedToday;

    return GestureDetector(
      onTap: _openCamera,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDone
                ? [const Color(0xFF2E2244), const Color(0xFF1B112D)]
                : [T.violet, T.coral],
          ),
          boxShadow: isDone
              ? []
              : [
                  BoxShadow(
                    color: T.violet.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
          border: Border.all(
            color: isDone ? T.line : Colors.white.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Center(
          child: isDone
              ? const Icon(Icons.check, size: 20, color: T.green)
              : const Aperture(size: 22, color: Colors.white),
        ),
      ),
    );
  }
}
