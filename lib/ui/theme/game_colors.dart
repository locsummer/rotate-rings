import 'package:flutter/material.dart';

class GameColors {
  // Backgrounds
  static const Color background = Color(0xFFFBF6ED);
  static const Color backgroundCard = Color(0xFFFFFDF9);
  static const Color bannerYellow = Color(0xFFFFE885);
  static const Color bannerWood = Color(0xFF875225);

  // Candy / Pastel Rings Palette
  static const Color pastelOrange = Color(0xFFFF9233);
  static const Color pastelSkyBlue = Color(0xFF34A9F4);
  static const Color pastelRoyalBlue = Color(0xFF3B72DE);
  static const Color pastelPurple = Color(0xFF9E4FE8);
  static const Color pastelRed = Color(0xFFE84545);
  static const Color pastelGreen = Color(0xFF78C826);
  static const Color pastelForestGreen = Color(0xFF2EA868);
  static const Color pastelYellow = Color(0xFFFBB829);
  static const Color pastelPink = Color(0xFFFF6584);

  // Joints & Pins
  static const Color jointNavy = Color(0xFF4A5568);
  static const Color jointGold = Color(0xFFE0A838);

  // Text & UI Accents
  static const Color textDarkBrown = Color(0xFF5A3921);
  static const Color textMediumBrown = Color(0xFF8E6E53);
  static const Color pillBg = Color(0xFFF1E4D3);
  static const Color starGold = Color(0xFFFFBE1A);
  static const Color acornBrown = Color(0xFFC07028);

  // Shadows
  static BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF7C5028).withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static BoxShadow buttonShadow = BoxShadow(
    color: const Color(0xFF7C5028).withOpacity(0.18),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}
