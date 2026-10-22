import 'package:flutter/material.dart';
import '../theme.dart';

class ConstellationMember {
  final String username;
  final String name;
  final String initial;
  final int streak;
  final Color haloColor;
  final double size;
  final Offset offset;

  const ConstellationMember({
    required this.username,
    required this.name,
    required this.initial,
    required this.streak,
    required this.haloColor,
    this.size = 46,
    required this.offset,
  });
}

/// Floating avatar constellation inspired directly by the Dribbble Team Analytics UI.
/// Features a hero avatar in the center radiating a fiery crimson/coral aura,
/// flanked by satellite members with cyan, lime, amber, and violet glowing rings.
class AvatarConstellation extends StatelessWidget {
  final ValueChanged<String>? onMemberTap;
  final VoidCallback? onAddTap;

  const AvatarConstellation({
    super.key,
    this.onMemberTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    // Configured layout coordinates to match the Dribbble shot's dynamic constellation
    final members = [
      // Orbit 1: Left Cyan
      const ConstellationMember(
        username: "devon.p",
        name: "Devon P.",
        initial: "D",
        streak: 28,
        haloColor: Color(0xFF00F0FF),
        size: 44,
        offset: Offset(42, 60),
      ),
      // Orbit 2: Top Right Lime
      const ConstellationMember(
        username: "kwame_o",
        name: "Kwame O.",
        initial: "K",
        streak: 34,
        haloColor: Color(0xFF10B981),
        size: 38,
        offset: Offset(230, 24),
      ),
      // Orbit 3: Mid Right Violet
      const ConstellationMember(
        username: "sana.k",
        name: "Sana K.",
        initial: "S",
        streak: 19,
        haloColor: Color(0xFFA855F7),
        size: 36,
        offset: Offset(264, 88),
      ),
      // Orbit 4: Far Left Amber/Coral
      const ConstellationMember(
        username: "maya_v",
        name: "Maya V.",
        initial: "M",
        streak: 14,
        haloColor: Color(0xFFFFB703),
        size: 34,
        offset: Offset(18, 140),
      ),
      // Orbit 5: Lower Right Yellow/Lime
      const ConstellationMember(
        username: "leo_c",
        name: "Leo C.",
        initial: "L",
        streak: 22,
        haloColor: Color(0xFFEAB308),
        size: 38,
        offset: Offset(248, 150),
      ),
      // Center HERO: Fiery Crimson/Coral glowing aura
      const ConstellationMember(
        username: "priya_m",
        name: "Priya M.",
        initial: "P",
        streak: 42,
        haloColor: Color(0xFFFF2E63),
        size: 78,
        offset: Offset(132, 70),
      ),
    ];

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widthScale = constraints.maxWidth / 340.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Subtle background connection arcs / ambient constellation glow
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2E63).withValues(alpha: 0.22),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Orbiting avatar bubbles
              for (final m in members)
                Positioned(
                  left: m.offset.dx * widthScale,
                  top: m.offset.dy,
                  child: _buildAvatar(m),
                ),

              // Floating plus / invite action pill
              Positioned(
                right: 28 * widthScale,
                top: 40,
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: T.surface2.withValues(alpha: 0.8),
                      border: Border.all(color: T.violet.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: T.violet.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, size: 16, color: T.text),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(ConstellationMember m) {
    final isHero = m.size > 60;

    return GestureDetector(
      onTap: () => onMemberTap?.call(m.username),
      child: Container(
        width: m.size,
        height: m.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: m.haloColor.withValues(alpha: isHero ? 0.65 : 0.45),
              blurRadius: isHero ? 24 : 12,
              spreadRadius: isHero ? 4 : 1.5,
            ),
          ],
          border: Border.all(
            color: m.haloColor,
            width: isHero ? 2.5 : 1.8,
          ),
        ),
        child: ClipOval(
          child: Container(
            color: const Color(0xFF18102B),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner gradient fill
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        m.haloColor.withValues(alpha: 0.3),
                        const Color(0xFF0D061A),
                      ],
                    ),
                  ),
                ),
                Text(
                  m.initial,
                  style: TextStyle(
                    fontSize: m.size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (isHero)
                  Positioned(
                    bottom: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: m.haloColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "🔥${m.streak}",
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
