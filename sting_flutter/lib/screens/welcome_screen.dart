import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/aperture.dart';
import '../widgets/atmospheric_background.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final AppState state;
  const WelcomeScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [T.violet, T.coral],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: T.violet.withValues(alpha: 0.6),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Aperture(size: 52, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  "sting",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Live it. Don't fake it.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: T.violetGlow,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "No filters. No drafts. Zero gallery uploads.",
                  style: TextStyle(fontSize: 13, color: T.muted),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [T.violet, Color(0xFF9333EA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: T.violet.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen(state: state))),
                    child: const Text("Create Account", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: T.violet.withValues(alpha: 0.4)),
                    backgroundColor: const Color(0x331E1238),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(state: state))),
                  child: const Text("I already have an account", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
