import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/common.dart';
import 'forgot_password_screen.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  final AppState state;
  const LoginScreen({super.key, required this.state});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String identifier = "";
  String password = "";
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    setState(() { loading = true; error = null; });
    try {
      await widget.state.api.login(emailOrUsername: identifier, password: password);
      await widget.state.refreshMe();
      await widget.state.refreshFollowing();
      await widget.state.refreshMyPosts();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => MainShell(state: widget.state)), (route) => false);
    } on ApiException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = "Couldn't reach the server. Check the backend is running.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const StingTopBar(title: "Log In"),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xB3150D2B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: T.violet.withValues(alpha: 0.28)),
                ),
                child: Column(
                  children: [
                    LabeledField(
                      label: "Email or username",
                      hint: "you@example.com",
                      onChanged: (v) => setState(() => identifier = v),
                    ),
                    const SizedBox(height: 6),
                    LabeledField(
                      label: "Password",
                      hint: "Password",
                      obscure: true,
                      onChanged: (v) => setState(() => password = v),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                        child: const Text("Forgot password?", style: TextStyle(fontSize: 12, color: T.violetGlow, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error!, style: const TextStyle(color: T.coral, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [T.violet, Color(0xFF9333EA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: T.violet.withValues(alpha: 0.45),
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
                  onPressed: identifier.isNotEmpty && password.isNotEmpty && !loading ? _submit : null,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Log In", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
