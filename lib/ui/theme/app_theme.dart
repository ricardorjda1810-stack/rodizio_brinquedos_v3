// lib/ui/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

enum AppPalette {
  calmBlue,
  lightGreen,
  lavender,
  blushPink,
  sunsetOrange,
  softPeach,
  turquoiseBlue,
}

class AppTheme {
  AppTheme._();

  static const AppPalette palette = AppPalette.turquoiseBlue;

  static ThemeData light() {
    final seed = _seedColor(palette);

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontSize: UiTokens.appBarTitle,
          fontWeight: FontWeight.w600,
          color: UiTokens.text,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontSize: UiTokens.cardTitle,
          fontWeight: FontWeight.w600,
          color: UiTokens.text,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: UiTokens.body,
          fontWeight: FontWeight.w400,
          color: UiTokens.text,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: UiTokens.secondary,
          fontWeight: FontWeight.w400,
          color: UiTokens.textMuted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.l,
            vertical: UiTokens.m,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.l,
            vertical: UiTokens.m,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.m,
            vertical: UiTokens.s,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 6,
      ),
    );
  }

  static Color _seedColor(AppPalette p) {
    switch (p) {
      case AppPalette.calmBlue:
        return const Color(0xFF5B8DEF);
      case AppPalette.lightGreen:
        return const Color(0xFF7CB342);
      case AppPalette.lavender:
        return const Color(0xFF7C6EE6);
      case AppPalette.blushPink:
        return const Color(0xFFEF6C8F);
      case AppPalette.sunsetOrange:
        return const Color(0xFFEF6C00);
      case AppPalette.softPeach:
        return const Color(0xFFF4A261);
      case AppPalette.turquoiseBlue:
        return const Color(0xFF4A90E2);
    }
  }
}
