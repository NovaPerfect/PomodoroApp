import 'package:flutter/material.dart';

class AppColors {
  static const background   = Color(0xFF1A1025); // тёмно-фиолетовый фон
  static const surface      = Color(0xFF2A1F3D); // карточки
  static const accent       = Color(0xFFE8A0BF); // розовый — главный акцент
  static const accent2      = Color(0xFFC084FC); // фиолетовый
  static const accent3      = Color(0xFFFB923C); // оранжевый (таймер работает)
  static const textPrimary  = Color(0xFFF0E6FF);
  static const textMuted    = Color(0xFF9D8FBB);
  static const success      = Color(0xFF86EFAC); // зелёный (выполнено)
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'ZenKakuGothicNew',  // см. pubspec ниже
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.accent,
      secondary: AppColors.accent2,
      surface:   AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}