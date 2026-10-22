import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class T {
  // Deep Midnight Obsidian & Royal Violet (Dribbble Palette)
  static const bg = Color(0xFF080414);
  static const surface = Color(0xFF130B24);
  static const surface2 = Color(0xFF1B1133);
  static const surfaceGlass = Color(0xCC150D2B);
  static const line = Color(0xFF281947);
  static const lineHighlight = Color(0x40A855F7);

  // Vibrant Neon & Electric Accents
  static const violet = Color(0xFFA855F7);
  static const violetGlow = Color(0xFFC084FC);
  static const primary = Color(0xFFA855F7);
  static const flash = Color(0xFFA855F7); // Primary brand neon
  static const coral = Color(0xFFFF2E63); // Glowing center crimson/coral
  static const cyan = Color(0xFF00F0FF);  // Electric cyan aura
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFFFB703);

  // High-Contrast Modern Typography
  static const text = Color(0xFFFFFFFF);
  static const muted = Color(0xFFA59EC4);
  static const mutedDark = Color(0xFF6E648D);
}

ThemeData stingTheme() {
  final base = GoogleFonts.plusJakartaSansTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  ).apply(bodyColor: T.text, displayColor: T.text);

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: T.bg,
    primaryColor: T.violet,
    textTheme: base,
    colorScheme: const ColorScheme.dark(
      primary: T.violet,
      secondary: T.coral,
      surface: T.surface,
      surfaceContainerHighest: T.surface2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: T.surface2.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: T.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: T.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: T.violet, width: 1.5),
      ),
      labelStyle: const TextStyle(color: T.muted, fontSize: 13),
      hintStyle: const TextStyle(color: T.mutedDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: T.violet,
        foregroundColor: Colors.white,
        disabledBackgroundColor: T.line,
        disabledForegroundColor: T.muted,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 6,
        shadowColor: T.violet.withValues(alpha: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: T.text,
        side: const BorderSide(color: T.line),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}
