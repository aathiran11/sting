import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/common.dart';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  final AppState state;
  const SignUpScreen({super.key, required this.state});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String method = "email";
  bool loading = false;
  String? error;

  bool get valid => method == "email"
      ? RegExp(r"\S+@\S+\.\S+").hasMatch(widget.state.email) && widget.state.password.length >= 6
      : widget.state.phone.length >= 10 && widget.state.password.length >= 6;

  Future<void> _submit() async {
    setState(() { loading = true; error = null; });
    try {
      await widget.state.api.register(
        email: method == "email" ? widget.state.email : null,
        phone: method == "phone" ? widget.state.phone : null,
        password: widget.state.password,
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(state: widget.state)));
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
        appBar: const StingTopBar(title: "Create Account"),
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
                    Row(
                      children: ["email", "phone"].map((m) {
                        final selected = method == m;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: m == "email" ? 8 : 0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: selected ? T.violet : T.line),
                                backgroundColor: selected ? T.violet.withValues(alpha: 0.18) : Colors.transparent,
                                foregroundColor: selected ? Colors.white : T.muted,
                                minimumSize: const Size.fromHeight(42),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => setState(() => method = m),
                              child: Text(
                                m[0].toUpperCase() + m.substring(1),
                                style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (method == "email")
                      LabeledField(
                        label: "Email",
                        hint: "you@example.com",
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (v) => setState(() => widget.state.email = v),
                      )
                    else
                      LabeledField(
                        label: "Phone number",
                        hint: "+91 98765 43210",
                        keyboardType: TextInputType.phone,
                        onChanged: (v) => setState(() => widget.state.phone = v),
                      ),
                    const SizedBox(height: 6),
                    LabeledField(
                      label: "Password",
                      hint: "At least 6 characters",
                      obscure: true,
                      onChanged: (v) => setState(() => widget.state.password = v),
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
                  onPressed: valid && !loading ? _submit : null,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Send Verification Code", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
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
