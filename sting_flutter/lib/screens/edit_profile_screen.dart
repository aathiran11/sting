import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  final AppState state;
  const EditProfileScreen({super.key, required this.state});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtl;
  late TextEditingController userCtl;
  late TextEditingController bioCtl;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    nameCtl = TextEditingController(text: widget.state.name);
    userCtl = TextEditingController(text: widget.state.username);
    bioCtl = TextEditingController(text: widget.state.bio);
  }

  Future<void> _save() async {
    setState(() { saving = true; error = null; });
    try {
      await widget.state.api.updateMe({
        "username": userCtl.text,
        "name": nameCtl.text,
        "bio": bioCtl.text,
      });
      widget.state.name = nameCtl.text;
      widget.state.username = userCtl.text;
      widget.state.bio = bioCtl.text;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated")));
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = "Couldn't save. That username might already be taken.");
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StingTopBar(title: "Edit profile"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            LabeledField(label: "Display name", controller: nameCtl, onChanged: (_) {}),
            LabeledField(label: "Username", controller: userCtl, onChanged: (_) {}),
            LabeledField(label: "Bio", controller: bioCtl, onChanged: (_) {}),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(error!, style: const TextStyle(color: T.coral, fontSize: 12)),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14120A)))
                  : const Text("Save changes"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
