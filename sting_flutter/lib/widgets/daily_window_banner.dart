import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import 'spectrum_bar.dart';

class DailyWindowBanner extends StatefulWidget {
  final AppState state;
  final String? label;
  final String? category;
  final VoidCallback? onCaptureTap;

  const DailyWindowBanner({
    super.key,
    required this.state,
    this.label,
    this.category,
    this.onCaptureTap,
  });

  @override
  State<DailyWindowBanner> createState() => _DailyWindowBannerState();
}

class _DailyWindowBannerState extends State<DailyWindowBanner> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_calculateRemaining);
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final diff = midnight.difference(now);
    _remaining = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "${hours}h ${minutes}m ${seconds}s";
  }

  double _dayProgress() {
    final now = DateTime.now();
    const totalSeconds = 24 * 3600.0;
    final secondsPassed = now.hour * 3600 + now.minute * 60 + now.second;
    return (secondsPassed / totalSeconds).clamp(0.0, 1.0);
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'nature':
        return Icons.park_rounded;
      case 'kindness':
        return Icons.volunteer_activism_rounded;
      case 'learning':
        return Icons.menu_book_rounded;
      case 'creativity':
        return Icons.palette_rounded;
      case 'mental health':
      case 'mindfulness':
        return Icons.spa_rounded;
      case 'finance':
        return Icons.savings_rounded;
      case 'photography':
        return Icons.camera_alt_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.state.postedToday;
    final cat = widget.category ?? "Daily Habit";
    final isUrgent = _remaining.inHours < 2;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xB3150D2B),
        border: Border.all(
          color: isDone
              ? T.line
              : isUrgent
                  ? T.coral.withValues(alpha: 0.7)
                  : T.violet.withValues(alpha: 0.35),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? T.coral : T.violet).withValues(alpha: 0.12),
            blurRadius: 20,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: T.violet.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getCategoryIcon(cat), size: 13, color: T.violetGlow),
                    const SizedBox(width: 6),
                    Text(
                      cat.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: T.violetGlow,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x331E1238),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: isUrgent ? T.coral : T.muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDuration(_remaining),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isUrgent ? T.coral : T.muted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.label ?? "Show us today, unfiltered.",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          // Spectrum meter showing time tracking progress across the day
          SpectrumBar(
            progress: _dayProgress(),
            barCount: 28,
            height: 14,
            leftLabel: "Window window",
            rightLabel: isUrgent ? "Window closing fast!" : "Daily active window",
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: isDone
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: T.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: T.green.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 16, color: T.green),
                            SizedBox(width: 6),
                            Text(
                              "Completed for Today • Streak Safe",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: T.green),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: isUrgent ? [T.coral, const Color(0xFFE11D48)] : [T.violet, T.coral],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isUrgent ? T.coral : T.violet).withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: widget.onCaptureTap,
                          icon: const Icon(Icons.camera_alt_rounded, size: 17),
                          label: Text(
                            isUrgent ? "Capture Now (Window Closing)" : "Capture Unfiltered Proof",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
