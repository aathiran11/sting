import 'dart:async';
import 'dart:collection';
import 'package:sensors_plus/sensors_plus.dart';

/// Keeps a rolling buffer of recent accelerometer magnitude samples.
/// A real hand-held phone shows small continuous jitter; a phone lying
/// flat, or pointed at a static screen/photo, tends to show unnaturally
/// low variance. This is a lightweight heuristic, not a guarantee.
class MotionMonitor {
  final Queue<double> _buffer = Queue<double>();
  final int maxSamples;
  StreamSubscription<AccelerometerEvent>? _sub;

  MotionMonitor({this.maxSamples = 40});

  void start() {
    _sub = accelerometerEventStream().listen((e) {
      final magnitude = (e.x.abs() + e.y.abs() + e.z.abs());
      _buffer.add(magnitude);
      if (_buffer.length > maxSamples) _buffer.removeFirst();
    });
  }

  void stop() {
    _sub?.cancel();
  }

  /// Returns true if there's enough natural hand jitter to look like
  /// a genuine live capture rather than a static re-photograph.
  bool get looksLive {
    if (_buffer.length < 8) return true; // not enough data yet, don't block
    final avg = _buffer.reduce((a, b) => a + b) / _buffer.length;
    final variance =
        _buffer.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / _buffer.length;
    return variance > 0.02; // empirical threshold for "held in hand"
  }
}
