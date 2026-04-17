import 'package:flutter/material.dart';

class UiTokens {
  UiTokens._();

  // Canonical spacing tokens
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 40;

  // Backwards-compatible aliases
  static const double xs = spacingXs;
  static const double s = spacingSm;
  static const double m = spacingMd;
  static const double l = spacingLg;
  static const double xl = spacingXl;
  static const double xxl = spacing2xl;

  // Radius tokens
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusCard = 22;
  static const double radiusPhoto = 18;

  // Backwards-compatible aliases
  static const double radiusButton = radiusMd;
  static const double radiusInput = radiusMd;

  // Icon size
  static const double icon = 22;

  // Typography scale aliases kept for existing theme usage
  static const double appBarTitle = 20;
  static const double cardTitle = 20;
  static const double body = 15;
  static const double secondary = 13;

  // RDB 2.1 canonical color tokens
  static const Color primary = Color(0xFF7AA68A);
  static const Color primaryStrong = Color(0xFF5B8B6A);
  static const Color primarySoft = Color(0xFFE9F3EB);
  static const Color secondarySoft = Color(0xFFF3F0E7);
  static const Color bg = Color(0xFFF7F6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2F3A33);
  static const Color textSecondary = Color(0xFF758178);
  static const Color border = Color(0xFFE6E7DE);
  static const Color success = Color(0xFF6E9B7C);
  static const Color warning = Color(0xFFD2A65A);
  static const Color danger = Color(0xFFC77C73);
  static const Color shadow = Color(0x140C1A12);

  // Backwards-compatible aliases
  static const Color card = surface;
  static const Color text = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color active = primary;
  static const Color playfulSoft = primarySoft;

  // Figma text styles
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
