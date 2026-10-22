import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../services/motion_monitor.dart';
import '../widgets/aperture.dart';
import 'post_review_screen.dart';

/// The Unfiltered capture flow: camera preview only, no gallery access,
/// no filters, no drafts. Shutter fires immediately — there is no
/// "choose from library" path anywhere in this screen by design.
class CameraCaptureScreen extends StatefulWidget {
  final AppState state;
  final String taskLabel;
  const CameraCaptureScreen({super.key, required this.state, required this.taskLabel});
  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  final MotionMonitor _motion = MotionMonitor();
  bool _ready = false;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _motion.start();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = "No camera found on this device.");
        return;
      }
      final cam = cameras.first;
      final controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _ready = true;
      });
    } catch (e) {
      setState(() => _error = "Couldn't access the camera. Check app permissions.");
    }
  }

  Future<void> _capture() async {
    if (_controller == null || _capturing) return;
    setState(() => _capturing = true);

    final capturedAt = DateTime.now();
    final verifiedLive = _motion.looksLive;
    XFile? file;
    try {
      file = await _controller!.takePicture();
    } catch (_) {
      // offline/sim fallback
    }

    if (!mounted) return;
    setState(() => _capturing = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PostReviewScreen(
          state: widget.state,
          taskLabel: widget.taskLabel,
          imagePath: file?.path,
          capturedAt: capturedAt,
          verifiedLive: verifiedLive,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _motion.stop();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080414),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0x331E1238),
                      shape: BoxShape.circle,
                      border: Border.all(color: T.line),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: T.violet.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: T.violet.withValues(alpha: 0.35)),
                          ),
                          child: const Text(
                            "UNFILTERED LIVE",
                            style: TextStyle(
                              color: T.violetGlow,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.taskLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? _ErrorState(message: _error!)
                  : _ready
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: T.violet.withValues(alpha: 0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: T.violet.withValues(alpha: 0.2),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: CameraPreview(_controller!),
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator(color: T.violet)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Live camera only — zero gallery uploads, zero filters.",
                style: TextStyle(color: T.muted, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              child: GestureDetector(
                onTap: _ready && !_capturing ? _capture : null,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [T.violet, T.coral],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: T.violet.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3.5),
                  ),
                  child: _capturing
                      ? const Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Center(
                          child: Aperture(size: 30, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Aperture(size: 40, color: T.coral),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
