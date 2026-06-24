import 'package:flutter/material.dart';

class UiTokens {
  UiTokens._();

  // Canonical spacing tokens.
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 40;

  // Backwards-compatible spacing aliases.
  static const double xs = spacingXs;
  static const double s = spacingSm;
  static const double m = spacingMd;
  static const double l = spacingLg;
  static const double xl = spacingXl;
  static const double xxl = spacing2xl;

  // Radius tokens.
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusCard = 22;
  static const double radiusPhoto = 18;

  // Backwards-compatible radius aliases.
  static const double radiusButton = radiusMd;
  static const double radiusInput = radiusMd;

  // Elevation/shadow tokens.
  static const Offset shadowOffset = Offset(0, 10);
  static const double shadowBlur = 30;
  static const double shadowSpread = -16;

  // Icon size.
  static const double icon = 22;

  // Typography scale aliases kept for existing theme usage.
  static const double appBarTitle = 20;
  static const double cardTitle = 20;
  static const double body = 15;
  static const double secondary = 13;

  // RDB 2.1 visual foundation: warm, calm, premium Montessori palette.
  static const Color backgroundLight = Color(0xFFF7F4EF);
  static const Color backgroundDark = Color(0xFF111816);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C2622);
  static const Color surfaceSecondaryLight = Color(0xFFE8DED2);
  static const Color surfaceSecondaryDark = Color(0xFF25322D);
  static const Color sand = surfaceSecondaryLight;
  static const Color graphite = Color(0xFF2F3A36);
  static const Color primary = Color(0xFF7A9A8A);
  static const Color primaryDark = Color(0xFF8EAE9E);
  static const Color accent = Color(0xFFC79F6B);
  static const Color accentDark = Color(0xFFD4A76A);
  static const Color actionOrange = Color(0xFFF97316);
  static const Color actionOrangeDark = Color(0xFFC2410C);
  static const Color actionOrangeSoft = Color(0xFFFFF5E8);
  static const Color actionOrangeBorder = Color(0xFFFDDCBA);
  static const Color textPrimary = graphite;
  static const Color textPrimaryDark = Color(0xFFDDE7DE);
  static const Color textSecondary = Color(0xFF68756F);
  static const Color textSecondaryDark = Color(0xFFA6B5AB);
  static const Color border = Color(0xFFE1D8CC);
  static const Color borderDark = Color(0xFF314039);
  static const Color shadow = Color(0x140C1A12);
  static const Color shadowDark = Color(0x33000000);

  // Existing semantic colors retained and mapped to the calmer palette.
  static const Color primaryStrong = Color(0xFF5F806F);
  static const Color primarySoft = Color(0xFFEAF1EC);
  static const Color secondarySoft = surfaceSecondaryLight;
  static const Color success = Color(0xFF6E9B7C);
  static const Color warning = accent;
  static const Color danger = Color(0xFFC77C73);

  // Backwards-compatible color aliases.
  static const Color bg = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color card = surfaceLight;
  static const Color text = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color active = primary;
  static const Color playfulSoft = primarySoft;
  static const Color caramel = accent;

  // Shared soft shadows for hand-crafted surfaces outside CardTheme.
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: shadow,
      offset: shadowOffset,
      blurRadius: shadowBlur,
      spreadRadius: shadowSpread,
    ),
  ];

  static const List<BoxShadow> softShadowDark = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(0, 12),
      blurRadius: 34,
      spreadRadius: -18,
    ),
  ];

  // Figma text styles.
  static const TextStyle textTitle = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle textSectionTitle = TextStyle(
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle textBody = TextStyle(
    fontSize: 15,
    height: 16 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textCaption = TextStyle(
    fontSize: 13,
    height: 14 / 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textMicro = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle textButton = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w600,
  );
}
