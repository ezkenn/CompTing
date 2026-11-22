import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF263C7B);
  static const Color primaryDeep = Color(0xFF1E3A8A);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color accent = Color(0xFF00A980);

  // Neutral Surfaces & Text
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color success = Color(0xFF00A980);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSurface = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);
}
