import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_state.dart';
import 'widgets/aperture.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const StingApp());
}

class StingApp extends StatelessWidget {
  const StingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sting',
      debugShowCheckedModeBanner: false,
      theme: stingTheme(),
      home: const _Bootstrap(),
    );
  }
}

/// Loads any saved login token before deciding whether to show Welcome
/// or drop the person straight into the app.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  final AppState state = AppState();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await state.init();
    if (state.api.isLoggedIn) {
      try {
        await state.refreshMe();
        await state.refreshFollowing();
        await state.refreshMyPosts();
      } catch (_) {
        // Token might be stale or the backend unreachable — fall back to
        // Welcome rather than getting stuck.
        await state.api.clearToken();
      }
    }
    if (mounted) setState(() => ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(
        backgroundColor: T.bg,
        body: Center(child: Aperture(size: 56)),
      );
    }
    return state.api.isLoggedIn ? MainShell(state: state) : WelcomeScreen(state: state);
  }
}
