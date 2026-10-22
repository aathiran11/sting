import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/common.dart';
import 'username_screen.dart';

class OtpScreen extends StatefulWidget {
  final AppState state;
  final String? codeHint;

  const OtpScreen({super.key, required this.state, this.codeHint = "1234"});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controllers = List.generate(4, (_) => TextEditingController());
  final focusNodes = List.generate(4, (_) => FocusNode());
  int seconds = 30;
  Timer? timer;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Pre-populate if codeHint is provided
    if (widget.codeHint != null && widget.codeHint!.length == 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillCode(widget.codeHint!);
      });
    }
  }

  void _fillCode(String code) {
    if (code.length >= 4) {
      for (int i = 0; i < 4; i++) {
        controllers[i].text = code[i];
      }
      setState(() {});
    }
  }

  void _startTimer() {
    timer?.cancel();
    setState(() => seconds = 30);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get complete => controllers.every((c) => c.text.isNotEmpty);

  Future<void> _verify() async {
    setState(() { loading = true; error = null; });
    final contact = widget.state.email.isNotEmpty ? widget.state.email : widget.state.phone;
    final code = controllers.map((c) => c.text).join();
    try {
      await widget.state.api.verifyOtp(contact: contact, code: code);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => UsernameScreen(state: widget.state)));
    } on ApiException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      // Local/offline test fallback: allow 1234 or any 4 digit code to proceed
      if (code == "1234" || (widget.codeHint != null && code == widget.codeHint)) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => UsernameScreen(state: widget.state)));
      } else {
        setState(() => error = "Invalid code. Use test code: 1234");
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.state.email.isNotEmpty ? widget.state.email : widget.state.phone;
    final displayHint = widget.codeHint ?? "1234";

    return AtmosphericBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const StingTopBar(title: "Verify Account"),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xB3150D2B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: T.violet.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(color: T.muted, fontSize: 13, height: 1.4),
                        children: [
                          const TextSpan(text: "We sent a 4-digit verification code to "),
                          TextSpan(
                            text: contact.isNotEmpty ? contact : "your contact",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: "."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick test OTP hint pill
                    GestureDetector(
                      onTap: () => _fillCode(displayHint),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: T.violet.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: T.violet.withValues(alpha: 0.45)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.key_rounded, size: 16, color: T.violetGlow),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Your OTP is: $displayHint",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: T.violet,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Auto-Fill",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4 Digit Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) {
                  final isFocused = focusNodes[i].hasFocus;
                  final hasText = controllers[i].text.isNotEmpty;

                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0x99180E33),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: hasText || isFocused ? T.violet : T.line,
                        width: hasText || isFocused ? 2.0 : 1.2,
                      ),
                      boxShadow: hasText || isFocused
                          ? [
                              BoxShadow(
                                color: T.violet.withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controllers[i],
                      focusNode: focusNodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        setState(() {});
                        if (v.isNotEmpty && i < 3) {
                          FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                        }
                      },
                    ),
                  );
                }),
              ),

              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Center(
                    child: Text(
                      error!,
                      style: const TextStyle(color: T.coral, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: seconds == 0 ? _startTimer : null,
                  child: Text(
                    seconds == 0 ? "Resend code" : "Resend code in ${seconds}s",
                    style: TextStyle(
                      color: seconds == 0 ? T.violetGlow : T.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
                  onPressed: complete && !loading ? _verify : null,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Verify & Continue", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
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
