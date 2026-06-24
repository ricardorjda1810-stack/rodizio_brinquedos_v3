import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: UiTokens.actionOrange,
      onPrimary: UiTokens.surfaceLight,
      primaryContainer: UiTokens.actionOrangeSoft,
      onPrimaryContainer: UiTokens.textPrimary,
      secondary: UiTokens.primaryStrong,
      onSecondary: UiTokens.surfaceLight,
      secondaryContainer: UiTokens.surfaceSecondaryLight,
      onSecondaryContainer: UiTokens.textPrimary,
      tertiary: UiTokens.accent,
      onTertiary: UiTokens.surfaceLight,
      tertiaryContainer: Color(0xFFF3E5D2),
      onTertiaryContainer: UiTokens.textPrimary,
      error: UiTokens.danger,
      onError: UiTokens.surfaceLight,
      errorContainer: Color(0xFFF8EBE8),
      onErrorContainer: UiTokens.danger,
      surface: UiTokens.surfaceLight,
      onSurface: UiTokens.textPrimary,
      surfaceContainerHighest: UiTokens.surfaceSecondaryLight,
      onSurfaceVariant: UiTokens.textSecondary,
      outline: UiTokens.border,
      outlineVariant: UiTokens.border,
      shadow: UiTokens.shadow,
      scrim: Color(0x66303A36),
      inverseSurface: UiTokens.textPrimary,
      onInverseSurface: UiTokens.surfaceLight,
      inversePrimary: UiTokens.primaryDark,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: UiTokens.backgroundLight,
      cardColor: UiTokens.surfaceLight,
      dividerColor: UiTokens.border,
      disabledColor: UiTokens.textSecondary.withValues(alpha: 0.38),
      splashFactory: InkSparkle.splashFactory,
    );

    return _withSharedComponents(
      base: base,
      background: UiTokens.backgroundLight,
      surface: UiTokens.surfaceLight,
      surfaceSubtle: const Color(0xFFF1ECE5),
      textPrimary: UiTokens.textPrimary,
      textSecondary: UiTokens.textSecondary,
      border: UiTokens.border,
      shadow: UiTokens.shadow,
      primaryStrong: UiTokens.primaryStrong,
      actionColor: UiTokens.actionOrange,
      actionSoft: UiTokens.actionOrangeSoft,
      accent: UiTokens.actionOrange,
      isDark: false,
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: UiTokens.primaryDark,
      onPrimary: UiTokens.backgroundDark,
      primaryContainer: Color(0xFF2D4438),
      onPrimaryContainer: UiTokens.textPrimaryDark,
      secondary: UiTokens.primaryDark,
      onSecondary: UiTokens.backgroundDark,
      secondaryContainer: UiTokens.surfaceSecondaryDark,
      onSecondaryContainer: UiTokens.textPrimaryDark,
      tertiary: UiTokens.accentDark,
      onTertiary: UiTokens.backgroundDark,
      tertiaryContainer: Color(0xFF463723),
      onTertiaryContainer: UiTokens.textPrimaryDark,
      error: UiTokens.danger,
      onError: UiTokens.backgroundDark,
      errorContainer: Color(0xFF4B2928),
      onErrorContainer: UiTokens.textPrimaryDark,
      surface: UiTokens.surfaceDark,
      onSurface: UiTokens.textPrimaryDark,
      surfaceContainerHighest: UiTokens.surfaceSecondaryDark,
      onSurfaceVariant: UiTokens.textSecondaryDark,
      outline: UiTokens.borderDark,
      outlineVariant: UiTokens.borderDark,
      shadow: UiTokens.shadowDark,
      scrim: Color(0x99000000),
      inverseSurface: UiTokens.textPrimaryDark,
      onInverseSurface: UiTokens.backgroundDark,
      inversePrimary: UiTokens.primary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: UiTokens.backgroundDark,
      cardColor: UiTokens.surfaceDark,
      dividerColor: UiTokens.borderDark,
      disabledColor: UiTokens.textSecondaryDark.withValues(alpha: 0.38),
      splashFactory: InkSparkle.splashFactory,
    );

    return _withSharedComponents(
      base: base,
      background: UiTokens.backgroundDark,
      surface: UiTokens.surfaceDark,
      surfaceSubtle: UiTokens.surfaceSecondaryDark,
      textPrimary: UiTokens.textPrimaryDark,
      textSecondary: UiTokens.textSecondaryDark,
      border: UiTokens.borderDark,
      shadow: UiTokens.shadowDark,
      primaryStrong: UiTokens.primaryDark,
      actionColor: UiTokens.accentDark,
      actionSoft: const Color(0xFF463723),
      accent: UiTokens.accentDark,
      isDark: true,
    );
  }

  static ThemeData _withSharedComponents({
    required ThemeData base,
    required Color background,
    required Color surface,
    required Color surfaceSubtle,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color shadow,
    required Color primaryStrong,
    required Color actionColor,
    required Color actionSoft,
    required Color accent,
    required bool isDark,
  }) {
    final textTheme = _buildTextTheme(
      base.textTheme,
      textPrimary,
      textSecondary,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
          side: BorderSide(
            color: border.withValues(alpha: isDark ? 0.70 : 0.85),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 0.8,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: surfaceSubtle.withValues(alpha: isDark ? 0.72 : 0.62),
        labelStyle: textTheme.bodySmall,
        helperStyle: textTheme.bodySmall,
        hintStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: UiTokens.danger),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UiTokens.spacingMd,
          vertical: UiTokens.spacingMd,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: BorderSide(color: primaryStrong, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: const BorderSide(color: UiTokens.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: const BorderSide(color: UiTokens.danger),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? UiTokens.surfaceSecondaryDark : textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? textPrimary : surface,
        ),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: actionColor,
          foregroundColor: isDark ? UiTokens.backgroundDark : surface,
          disabledBackgroundColor: border,
          disabledForegroundColor: textSecondary,
          textStyle: UiTokens.textButton.copyWith(fontWeight: FontWeight.w800),
          elevation: 0,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.spacingLg,
            vertical: UiTokens.spacingMd,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: surface,
          foregroundColor: textPrimary,
          surfaceTintColor: Colors.transparent,
          shadowColor: shadow,
          textStyle: UiTokens.textButton,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
            side: BorderSide(color: border),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.spacingLg,
            vertical: UiTokens.spacingMd,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: actionColor,
          disabledForegroundColor: textSecondary,
          textStyle: UiTokens.textButton.copyWith(fontWeight: FontWeight.w800),
          minimumSize: const Size(0, 50),
          side:
              BorderSide(color: isDark ? border : UiTokens.actionOrangeBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.spacingLg,
            vertical: UiTokens.spacingMd,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: actionColor,
          disabledForegroundColor: textSecondary,
          textStyle: UiTokens.textButton.copyWith(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.spacingMd,
            vertical: UiTokens.spacingSm,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: textSecondary, size: UiTokens.icon),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: actionColor,
        foregroundColor: isDark ? UiTokens.backgroundDark : surface,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceSubtle.withValues(alpha: isDark ? 0.72 : 0.62),
        selectedColor: actionSoft,
        disabledColor: border.withValues(alpha: 0.62),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? textPrimary : UiTokens.actionOrangeDark,
          fontWeight: FontWeight.w800,
        ),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: actionColor,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: actionSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? actionColor : textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? actionColor : textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color textPrimary,
    Color textSecondary,
  ) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: UiTokens.appBarTitle,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: UiTokens.body,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: UiTokens.body,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: UiTokens.secondary,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 16 / 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    );
  }
}
