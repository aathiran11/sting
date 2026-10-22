import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StingTopBar(title: "Settings"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            _row(
              "Private account",
              "Only approved followers see your streak",
              widget.state.privateAccount,
              (v) async {
                setState(() => widget.state.privateAccount = v);
                try {
                  await widget.state.api.updateMe({"isPrivate": v});
                } catch (_) {}
              },
            ),
            _row(
              "Daily task notification",
              "Get pinged when today's task drops",
              widget.state.dailyNotif,
              (v) => setState(() => widget.state.dailyNotif = v),
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: T.coral,
                side: const BorderSide(color: Color(0x66FF4059)),
              ),
              onPressed: () {
                widget.state.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomeScreen(state: widget.state)),
                  (route) => false,
                );
              },
              child: const Text("Log out"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.line))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12, color: T.muted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: T.flash),
        ],
      ),
    );
  }
}
