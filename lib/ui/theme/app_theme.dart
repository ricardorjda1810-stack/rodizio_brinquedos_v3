import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: UiTokens.primary,
      onPrimary: UiTokens.surface,
      primaryContainer: UiTokens.primarySoft,
      onPrimaryContainer: UiTokens.textPrimary,
      secondary: UiTokens.primaryStrong,
      onSecondary: UiTokens.surface,
      secondaryContainer: UiTokens.secondarySoft,
      onSecondaryContainer: UiTokens.textPrimary,
      tertiary: UiTokens.warning,
      onTertiary: UiTokens.surface,
      tertiaryContainer: Color(0xFFF7EFD9),
      onTertiaryContainer: UiTokens.textPrimary,
      error: UiTokens.danger,
      onError: UiTokens.surface,
      errorContainer: Color(0xFFF8EBE8),
      onErrorContainer: UiTokens.danger,
      surface: UiTokens.surface,
      onSurface: UiTokens.textPrimary,
      surfaceContainerHighest: Color(0xFFF1F2EC),
      onSurfaceVariant: UiTokens.textSecondary,
      outline: UiTokens.border,
      outlineVariant: UiTokens.border,
      shadow: UiTokens.shadow,
      scrim: Color(0x66303A33),
      inverseSurface: UiTokens.textPrimary,
      onInverseSurface: UiTokens.surface,
      inversePrimary: UiTokens.primarySoft,
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
        centerTitle: false,
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
        thickness: 0.8,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.bodySmall,
        helperStyle: textTheme.bodySmall,
        hintStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: UiTokens.danger),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: const BorderSide(color: UiTokens.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusInput),
          borderSide: const BorderSide(color: UiTokens.primaryStrong, width: 1.2),
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
        actionTextColor: UiTokens.primarySoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: UiTokens.primaryStrong,
          foregroundColor: UiTokens.surface,
          disabledBackgroundColor: UiTokens.border,
          disabledForegroundColor: UiTokens.textSecondary,
          textStyle: UiTokens.textButton,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.l,
            vertical: 16,
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
            vertical: 16,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return UiTokens.primarySoft;
            }
            return UiTokens.surface;
          }),
          foregroundColor: WidgetStateProperty.all(UiTokens.textPrimary),
          side: WidgetStateProperty.all(
            const BorderSide(color: UiTokens.border),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiTokens.radiusMd),
            ),
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
            vertical: 16,
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
          backgroundColor: UiTokens.surface,
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
        backgroundColor: Colors.transparent,
        selectedItemColor: UiTokens.primaryStrong,
        unselectedItemColor: UiTokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
        fontWeight: FontWeight.w700,
        color: UiTokens.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w700,
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
