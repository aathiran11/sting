import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Camera-iris mark — Sting's recurring signature element.
class Aperture extends StatelessWidget {
  final double size;
  final double progress;
  final Color color;
  const Aperture({super.key, this.size = 28, this.progress = 1, this.color = T.flash});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AperturePainter(progress: progress, color: color),
    );
  }
}

class _AperturePainter extends CustomPainter {
  final double progress;
  final Color color;
  _AperturePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final ringPaint = Paint()
      ..color = T.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r - 1, ringPaint);

    const blades = 8;
    final inner = r * (0.32 + 0.18 * (1 - progress));
    final bladePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < blades; i++) {
      final angle = (i / blades) * 2 * pi;
      final p1 = Offset(r + cos(angle) * inner, r + sin(angle) * inner);
      final p2 = Offset(r + cos(angle) * (r - 2), r + sin(angle) * (r - 2));
      canvas.drawLine(p1, p2, bladePaint);
    }

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(center, inner * 0.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _AperturePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
