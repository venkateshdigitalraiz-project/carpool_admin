import 'package:flutter/material.dart';

/// BlaBlaCar signature styling and automotive color palette.
class AppColors {
  AppColors._();

  // BlaBlaCar Primary Colors
  static const Color primary = Color(0xFF00AFF5); // BlaBlaCar vibrant electric blue
  static const Color primaryDark = Color(0xFF0088CC);
  static const Color primaryLight = Color(0xFF38C5FF);
  static const Color primaryNavy = Color(0xFF054752); // BlaBlaCar deep navy teal

  // Brand Accents & Alerts
  static const Color accentCoral = Color(0xFFFF5B4F); // Seats alert / notifications
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color success = Color(0xFF00A86B); // Verified badge / confirmed
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF9FBFC);
  static const Color card = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE5ECF0);
  static const Color borderLight = Color(0xFFEFF3F6);
  static const Color divider = Color(0xFFE9F0F4);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF054752); // Deep navy for high contrast
  static const Color textSecondary = Color(0xFF708C91); // Cool slate for secondary info
  static const Color textTertiary = Color(0xFF9EACB0);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Input & Chips
  static const Color inputFill = Color(0xFFF6F8FA);
  static const Color inputBorder = Color(0xFFDCE4E8);
  static const Color chipBackground = Color(0xFFE8F6FD);

  // Admin Theme Accents
  static const Color adminDark = Color(0xFF0B192C);
  static const Color adminCardDark = Color(0xFF1E2E44);
  static const Color adminGold = Color(0xFFFFB800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00AFF5), Color(0xFF0088CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF054752), Color(0xFF08323B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF00AFF5), Color(0xFF054752)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
