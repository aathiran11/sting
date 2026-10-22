import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/aperture.dart';
import '../widgets/common.dart';
import 'profile_setup_screen.dart';

enum UStatus { idle, checking, available, taken, error }

class UsernameScreen extends StatefulWidget {
  final AppState state;
  const UsernameScreen({super.key, required this.state});
  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  UStatus status = UStatus.idle;
  Timer? debounce;

  void check(String v) {
    widget.state.username = v;
    debounce?.cancel();
    if (v.isEmpty) {
      setState(() => status = UStatus.idle);
      return;
    }
    setState(() => status = UStatus.checking);
    debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final available = await widget.state.api.checkUsername(v);
        if (!mounted) return;
        setState(() => status = available ? UStatus.available : UStatus.taken);
      } catch (_) {
        if (!mounted) return;
        setState(() => status = UStatus.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color = T.muted;
    String text = "Pick something you'll want on a 100-day streak";
    if (status == UStatus.checking) {
      text = "Checking\u2026";
    } else if (status == UStatus.available) {
      color = T.green;
      text = "Available";
    } else if (status == UStatus.taken) {
      color = T.coral;
      text = "Already taken, or 3-20 chars a-z 0-9 . _";
    } else if (status == UStatus.error) {
      color = T.coral;
      text = "Couldn't reach the server";
    }

    return Scaffold(
      appBar: const StingTopBar(title: "Choose a username"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            const Center(child: Aperture(size: 48, progress: 0.6)),
            const SizedBox(height: 24),
            TextField(
              onChanged: (v) => check(v.replaceAll(" ", "").toLowerCase()),
              decoration: InputDecoration(
                prefixText: "@ ",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: status == UStatus.taken
                        ? T.coral
                        : status == UStatus.available
                            ? T.green
                            : T.line,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Text(text, style: TextStyle(color: color, fontSize: 12))),
            const Spacer(),
            ElevatedButton(
              onPressed: status == UStatus.available
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(state: widget.state)))
                  : null,
              child: const Text("Continue"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
