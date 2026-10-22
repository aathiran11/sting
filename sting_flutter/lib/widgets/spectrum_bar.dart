import 'package:flutter/material.dart';

/// Segmented spectrum meter modeled after the Dribbble Team Analytics UI.
/// Displays a horizontal strip of vertical pill bars transitioning smoothly
/// from Electric Cyan -> Royal Blue -> Violet -> Hot Pink -> Neon Coral.
class SpectrumBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int barCount;
  final double height;
  final String? leftLabel;
  final String? rightLabel;

  const SpectrumBar({
    super.key,
    required this.progress,
    this.barCount = 34,
    this.height = 20,
    this.leftLabel,
    this.rightLabel,
  });

  // Calculate the color for each bar along the spectrum gradient
  Color _colorForIndex(int index, int total) {
    final t = (index / (total - 1)).clamp(0.0, 1.0);
    // Interpolate through 5 key spectrum colors
    if (t < 0.25) {
      final subT = t / 0.25;
      return Color.lerp(const Color(0xFF00F0FF), const Color(0xFF3B82F6), subT)!;
    } else if (t < 0.5) {
      final subT = (t - 0.25) / 0.25;
      return Color.lerp(const Color(0xFF3B82F6), const Color(0xFFA855F7), subT)!;
    } else if (t < 0.75) {
      final subT = (t - 0.5) / 0.25;
      return Color.lerp(const Color(0xFFA855F7), const Color(0xFFEC4899), subT)!;
    } else {
      final subT = (t - 0.75) / 0.25;
      return Color.lerp(const Color(0xFFEC4899), const Color(0xFFFF2E63), subT)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = (barCount * progress.clamp(0.0, 1.0)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalSpacing = (barCount - 1) * 3.0;
              final barWidth = ((constraints.maxWidth - totalSpacing) / barCount).clamp(2.0, 6.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(barCount, (i) {
                  final isActive = i < activeCount;
                  final color = _colorForIndex(i, barCount);
                  // Subtle height wave variation like an equalizer
                  final barHeight = height * (0.65 + 0.35 * (((i * 7) % 11) / 10.0));

                  return Container(
                    width: barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isActive ? color : const Color(0xFF281C44).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.45),
                                blurRadius: 4,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              );
            },
          ),
        ),
        if (leftLabel != null || rightLabel != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leftLabel != null)
                Text(
                  leftLabel!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA59EC4),
                  ),
                ),
              if (rightLabel != null)
                Text(
                  rightLabel!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC4B5FD),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
