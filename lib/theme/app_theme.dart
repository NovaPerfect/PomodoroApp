import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Палитра на основе фонового рисунка (уютная аниме-комната)
class AppColors {
  // Фоны
  static const background  = Color(0xFFF5F0E8); // кремовые стены
  static const surface     = Color(0xFFFFFCF6); // белые карточки (тёплый белый)
  static const surfaceAlt  = Color(0xFFEDE8DF); // чуть темнее — вторичные карточки

  // Акценты
  static const accent      = Color(0xFF8C9E86); // шалфейно-зелёный (одеяло)
  static const accent2     = Color(0xFFC89B6E); // янтарный/тёплый (мебель, волосы)
  static const accent3     = Color(0xFF6B8CAE); // пыльно-голубой (книги, небо)

  // Текст
  static const textPrimary = Color(0xFF3A2D22); // тёмно-коричневый (контуры рисунка)
  static const textMuted   = Color(0xFF9A8874); // тёплый серо-коричневый

  // Вспомогательные
  static const success     = Color(0xFF8C9E86); // шалфей
  static const divider     = Color(0xFFD8D0C4); // граница между блоками
  static const shadow      = Color(0xFF3A2D22); // тени (тёплые, не чёрные)
}

// Мягкая тень для заголовков
const _softShadow = [
  Shadow(
    color: Color(0x22000000),
    offset: Offset(1, 1.5),
    blurRadius: 4,
  ),
];

// Fredoka не имеет кириллицы — Comfortaa подхватывает русские символы
const _fredokaFallback = ['Comfortaa'];

// Хелперы для точечного использования шрифтов в виджетах
class AppFonts {
  /// Fredoka — заголовки, кнопки, акценты. Кириллица → Comfortaa fallback.
  static TextStyle fredoka({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.3,
    bool withShadow = false,
    double? height,
  }) =>
      TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        shadows: withShadow ? _softShadow : null,
      );

  /// Nunito — основной текст, описания, лейблы. Полная кириллица.
  static TextStyle nunito({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.2,
    double height = 1.5,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      TextStyle(
        fontFamily: 'Nunito',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
      );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.accent,
      secondary: AppColors.accent2,
      surface:   AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      // ── Заголовки (Fredoka + Nunito fallback для кириллицы) ──────
      headlineLarge: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
        shadows: _softShadow,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.4,
        shadows: _softShadow,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),

      // ── Заголовки карточек (Fredoka + fallback) ──────────────────
      titleLarge: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
      ),

      // ── Основной текст (Nunito — полная кириллица) ───────────────
      bodyLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
        height: 1.4,
      ),

      // ── Лейблы (Nunito) ──────────────────────────────────────────
      labelLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    dividerColor: AppColors.divider,
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        fontFamily: 'Nunito',
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.accent),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fredokaFallback,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.divider,
      thumbColor: AppColors.accent,
      trackHeight: 2,
    ),
  );

  // Оставляем для совместимости
  static ThemeData get dark => light;
}
