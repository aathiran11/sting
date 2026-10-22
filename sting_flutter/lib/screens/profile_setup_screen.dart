import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  final AppState state;
  const ProfileSetupScreen({super.key, required this.state});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const interests = ["Fitness", "Nature", "Learning", "Creativity", "Kindness", "Mindfulness"];
  bool loading = false;
  String? error;

  Future<void> _finish() async {
    setState(() { loading = true; error = null; });
    try {
      await widget.state.api.updateMe({
        "username": widget.state.username,
        "name": widget.state.name,
        "bio": widget.state.bio,
        "interest": widget.state.interest,
      });
      await widget.state.refreshMe();
      await widget.state.refreshFollowing();
      await widget.state.refreshMyPosts();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => MainShell(state: widget.state)), (route) => false);
    } catch (e) {
      setState(() => error = "Couldn't save your profile. Check the backend is running.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StingTopBar(title: "Set up your profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: T.line, width: 2),
              ),
              child: const Text("Add\nphoto", textAlign: TextAlign.center, style: TextStyle(color: T.muted, fontSize: 11)),
            ),
            const SizedBox(height: 22),
            LabeledField(label: "Display name", hint: "Your name", onChanged: (v) => widget.state.name = v),
            LabeledField(label: "Bio", hint: "Two lines about you", onChanged: (v) => widget.state.bio = v),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("WHAT DRAWS YOU IN?", style: TextStyle(fontSize: 11, color: T.muted, letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((tag) {
                final selected = widget.state.interest == tag;
                return ChoiceChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) => setState(() => widget.state.interest = tag),
                  backgroundColor: Colors.transparent,
                  selectedColor: T.flash.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: selected ? T.flash : T.muted, fontSize: 12),
                  shape: StadiumBorder(side: BorderSide(color: selected ? T.flash : T.line)),
                );
              }).toList(),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: T.coral, fontSize: 12)),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : _finish,
              child: loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14120A)))
                  : const Text("Enter Sting"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
