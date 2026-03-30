import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: UiTokens.primary,
      onPrimary: UiTokens.surface,
      primaryContainer: Color(0xFFEAF3FC),
      onPrimaryContainer: UiTokens.textPrimary,
      secondary: UiTokens.textSecondary,
      onSecondary: UiTokens.surface,
      secondaryContainer: Color(0xFFEDE7DC),
      onSecondaryContainer: UiTokens.textPrimary,
      tertiary: UiTokens.primary,
      onTertiary: UiTokens.surface,
      tertiaryContainer: Color(0xFFEAF3FC),
      onTertiaryContainer: UiTokens.textPrimary,
      error: UiTokens.danger,
      onError: UiTokens.surface,
      errorContainer: Color(0xFFF9E3E1),
      onErrorContainer: UiTokens.danger,
      surface: UiTokens.surface,
      onSurface: UiTokens.textPrimary,
      surfaceContainerHighest: Color(0xFFF3EFE7),
      onSurfaceVariant: UiTokens.textSecondary,
      outline: UiTokens.border,
      outlineVariant: UiTokens.border,
      shadow: Color(0x1A1E2630),
      scrim: Color(0x661E2630),
      inverseSurface: UiTokens.textPrimary,
      onInverseSurface: UiTokens.surface,
      inversePrimary: Color(0xFF9BC0EB),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: UiTokens.bg,
      cardColor: UiTokens.surface,
      dividerColor: UiTokens.border,
      disabledColor: UiTokens.textSecondary.withValues(alpha: 0.38),
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: UiTokens.bg,
        foregroundColor: UiTokens.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: UiTokens.appBarTitle,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: UiTokens.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: UiTokens.surface,
        elevation: 0,
        shadowColor: scheme.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
          side: const BorderSide(color: UiTokens.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: UiTokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: UiTokens.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.bodySmall,
        helperStyle: textTheme.bodySmall,
        hintStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: UiTokens.danger),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: const BorderSide(color: UiTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: const BorderSide(color: UiTokens.primary),
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
        backgroundColor: UiTokens.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: UiTokens.surface),
        actionTextColor: UiTokens.primary,
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: UiTokens.primary,
          foregroundColor: UiTokens.surface,
          disabledBackgroundColor: UiTokens.border,
          disabledForegroundColor: UiTokens.textSecondary,
          textStyle: UiTokens.textButton,
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
          backgroundColor: UiTokens.surface,
          foregroundColor: UiTokens.textPrimary,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
            side: const BorderSide(color: UiTokens.border),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.l,
            vertical: UiTokens.m,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: UiTokens.textPrimary,
          textStyle: UiTokens.textButton,
          side: const BorderSide(color: UiTokens.border),
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
          textStyle: UiTokens.textButton,
          foregroundColor: UiTokens.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.m,
            vertical: UiTokens.s,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: UiTokens.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: UiTokens.primary,
        foregroundColor: UiTokens.surface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return UiTokens.primary;
          }
          return UiTokens.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return UiTokens.primary.withValues(alpha: 0.35);
          }
          return UiTokens.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return UiTokens.primary;
          }
          return UiTokens.surface;
        }),
        side: const BorderSide(color: UiTokens.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: UiTokens.textSecondary,
        textColor: UiTokens.textPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: UiTokens.surface,
        selectedItemColor: UiTokens.primary,
        unselectedItemColor: UiTokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 6,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: UiTokens.primary,
      brightness: Brightness.dark,
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: base.colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
          side: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: base.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: BorderSide(color: base.colorScheme.primary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: UiTokens.textButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.l,
            vertical: UiTokens.m,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: UiTokens.textButton,
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
          textStyle: UiTokens.textButton,
          foregroundColor: base.colorScheme.primary,
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
        backgroundColor: base.colorScheme.surface,
        selectedItemColor: base.colorScheme.primary,
        unselectedItemColor: base.colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 6,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(
        fontSize: UiTokens.appBarTitle,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: UiTokens.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: UiTokens.cardTitle,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: UiTokens.textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: UiTokens.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: UiTokens.body,
        height: 16 / 15,
        fontWeight: FontWeight.w400,
        color: UiTokens.textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: UiTokens.body,
        height: 16 / 15,
        fontWeight: FontWeight.w400,
        color: UiTokens.textPrimary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: UiTokens.secondary,
        height: 14 / 13,
        fontWeight: FontWeight.w400,
        color: UiTokens.textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 16 / 14,
        fontWeight: FontWeight.w600,
        color: UiTokens.textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: UiTokens.textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: UiTokens.textSecondary,
      ),
    );
  }
}
