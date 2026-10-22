import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/aperture.dart';
import 'main_shell.dart';

class PostReviewScreen extends StatefulWidget {
  final AppState state;
  final String taskLabel;
  final String? imagePath;
  final DateTime capturedAt;
  final bool verifiedLive;
  const PostReviewScreen({
    super.key,
    required this.state,
    required this.taskLabel,
    required this.imagePath,
    required this.capturedAt,
    required this.verifiedLive,
  });

  @override
  State<PostReviewScreen> createState() => _PostReviewScreenState();
}

class _PostReviewScreenState extends State<PostReviewScreen> {
  String caption = "";
  bool posting = false;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, h:mm a').format(widget.capturedAt);

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
                  const Expanded(
                    child: Text(
                      "Review Capture",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: T.violet.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: T.violet.withValues(alpha: 0.15),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: widget.imagePath != null
                            ? Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                            : Container(
                                color: const Color(0xFF130A26),
                                alignment: Alignment.center,
                                child: const Aperture(size: 48, color: T.violetGlow),
                              ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                          ),
                          child: Text(timeStr, style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (widget.verifiedLive ? T.green : T.coral).withValues(alpha: 0.2),
                            border: Border.all(color: widget.verifiedLive ? T.green : T.coral),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(widget.verifiedLive ? Icons.check_circle : Icons.warning_amber_rounded,
                                  size: 14, color: widget.verifiedLive ? T.green : T.coral),
                              const SizedBox(width: 5),
                              Text(
                                widget.verifiedLive ? "Live capture verified" : "Low motion detected",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: widget.verifiedLive ? T.green : T.coral,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xCC150D2B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: T.line),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (v) => setState(() => caption = v),
                  decoration: const InputDecoration(
                    hintText: "Say something about today's proof (optional)",
                    hintStyle: TextStyle(color: T.muted),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [T.violet, T.coral],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: T.violet.withValues(alpha: 0.5),
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
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: posting ? null : _post,
                  child: posting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Post to Today's Streak", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _post() async {
    setState(() => posting = true);
    try {
      await widget.state.api.createPost(
        taskLabel: widget.taskLabel,
        caption: caption.isEmpty ? "Unfiltered, day-of." : caption,
        verifiedLive: widget.verifiedLive,
        capturedAt: widget.capturedAt,
        imagePath: widget.imagePath,
      );
      await widget.state.refreshMe();
      await widget.state.refreshMyPosts();
    } catch (_) {
      // Local/demo fallback
      widget.state.myStreak += 1;
      widget.state.myStingScore += 25;
      widget.state.postedTodayFlag = true;
      widget.state.myPosts.insert(
        0,
        MyPost(
          taskLabel: widget.taskLabel,
          caption: caption.isEmpty ? "Unfiltered, day-of." : caption,
          verifiedLive: widget.verifiedLive,
          capturedAt: widget.capturedAt,
          imageUrl: widget.imagePath,
        ),
      );
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainShell(state: widget.state)),
      (route) => false,
    );
  }
}
