import 'package:flutter/material.dart';

class UiTokens {
  UiTokens._();

  // Canonical spacing tokens
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Backwards-compatible aliases
  static const double xs = spacingXs;
  static const double s = spacingSm;
  static const double m = spacingMd;
  static const double l = spacingLg;
  static const double xl = spacingXl;

  // Radius tokens
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusCard = 12;
  static const double radiusPhoto = 12;

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

  // Figma color styles
  static const Color primary = Color(0xFF4F6D7A);
  static const Color bg = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF667085);
  static const Color border = Color(0xFFD9E2EC);

  // Backwards-compatible aliases
  static const Color card = surface;
  static const Color text = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color active = Color(0xFF5A8F7B);
  static const Color playfulSoft = Color(0xFFE7F8FB);

  // Figma text styles
  static const TextStyle textTitle = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
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

  static const TextStyle textButton = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w600,
  );
}
