import 'package:flutter/material.dart';
import 'game_colors.dart';

class GameTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFFBF6EE),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: GameColors.pastelOrange,
        surface: GameColors.backgroundCard,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get themeData => theme;

  static TextStyle titleLarge = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: GameColors.textDarkBrown,
    letterSpacing: 0.5,
  );

  static TextStyle levelHeader = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: GameColors.textMediumBrown,
  );

  static TextStyle scoreText = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: GameColors.textDarkBrown,
  );

  static TextStyle buttonText = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
