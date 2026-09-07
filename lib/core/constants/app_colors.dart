import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors — same across both themes
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFFEAE9FF);

  static const Color accent = Color(0xFF00C896);
  static const Color accentLight = Color(0xFFE6F9F5);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ---- Light theme surface colors ----
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E); // kept for backward-compat (unused directly by theme now)

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF636366);
  static const Color textHint = Color(0xFFAEAEB2);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFF2F2F7);

  // ---- Dark theme surface colors ----
  static const Color backgroundDark = Color(0xFF121214);
  static const Color surfaceDarkMode = Color(0xFF1C1C1E);
  static const Color surfaceElevatedDark = Color(0xFF242426);

  static const Color textPrimaryDark = Color(0xFFF2F2F7);
  static const Color textSecondaryDark = Color(0xFFA1A1A6);
  static const Color textHintDark = Color(0xFF6E6E73);

  static const Color borderDark = Color(0xFF3A3A3C);
  static const Color dividerDark = Color(0xFF2C2C2E);
}