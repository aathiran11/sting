import 'package:flutter/material.dart';
import '../theme.dart';

/// Reusable atmospheric background implementing the Dribbble cosmic violet
/// and magenta radial glows over deep midnight obsidian space.
class AtmosphericBackground extends StatelessWidget {
  final Widget child;

  const AtmosphericBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base obsidian background
        Container(color: T.bg),

        // Top-center vibrant violet atmospheric glow
        Positioned(
          top: -120,
          left: -40,
          right: -40,
          height: 480,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.1, -0.2),
                  radius: 0.95,
                  colors: [
                    const Color(0xFF6B21A8).withValues(alpha: 0.38),
                    const Color(0xFF4C1D95).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Bottom-right hot magenta / coral ambient glow
        Positioned(
          bottom: -80,
          right: -80,
          width: 380,
          height: 380,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    const Color(0xFFBE185D).withValues(alpha: 0.24),
                    const Color(0xFF831843).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Mid-screen subtle electric cyan glow
        Positioned(
          top: 320,
          left: -100,
          width: 300,
          height: 300,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    const Color(0xFF00F0FF).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
