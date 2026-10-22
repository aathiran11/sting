import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = "";
  bool loading = false;

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      await ApiClient().forgotPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("If that email exists, a reset code was sent. Check the backend console.")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't reach the server.")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid = RegExp(r"\S+@\S+\.\S+").hasMatch(email);
    return Scaffold(
      appBar: const StingTopBar(title: "Reset password"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Enter your email and we'll send a reset link.", style: TextStyle(color: T.muted, fontSize: 13, height: 1.5)),
            ),
            const SizedBox(height: 16),
            LabeledField(label: "Email", hint: "you@example.com", onChanged: (v) => setState(() => email = v)),
            const Spacer(),
            ElevatedButton(
              onPressed: valid && !loading ? _submit : null,
              child: loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14120A)))
                  : const Text("Send reset link"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
