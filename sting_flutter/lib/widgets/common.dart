import 'package:flutter/material.dart';
import '../theme.dart';

class StingTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const StingTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Navigator.canPop(context)
          ? Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0x331E1238),
                  shape: BoxShape.circle,
                  border: Border.all(color: T.line),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class LabeledField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final TextEditingController? controller;

  const LabeledField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.initialValue,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: T.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              fillColor: const Color(0x66180E33),
            ),
          ),
        ],
      ),
    );
  }
}
