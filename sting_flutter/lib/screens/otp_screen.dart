import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'username_screen.dart';

class OtpScreen extends StatefulWidget {
  final AppState state;
  const OtpScreen({super.key, required this.state});
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
    } catch (e) {
      setState(() => error = "Couldn't reach the server.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.state.email.isNotEmpty ? widget.state.email : widget.state.phone;
    return Scaffold(
      appBar: const StingTopBar(title: "Verify it's you"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(color: T.muted, fontSize: 13, height: 1.5),
                children: [
                  const TextSpan(text: "We sent a 4-digit code to "),
                  TextSpan(text: contact.isNotEmpty ? contact : "your device", style: const TextStyle(color: T.text)),
                  const TextSpan(text: ". Check the backend server console \u2014 the code is logged there since real SMS/email isn't wired up yet."),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: TextField(
                      controller: controllers[i],
                      focusNode: focusNodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(counterText: ""),
                      onChanged: (v) {
                        setState(() {});
                        if (v.isNotEmpty && i < 3) {
                          FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: const TextStyle(color: T.coral, fontSize: 12)),
              ),
            TextButton(
              onPressed: seconds == 0 ? _startTimer : null,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              child: Text(
                seconds == 0 ? "Resend code" : "Resend code in ${seconds}s",
                style: TextStyle(color: seconds == 0 ? T.flash : T.muted, fontSize: 13),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: complete && !loading ? _verify : null,
              child: loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14120A)))
                  : const Text("Verify"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
