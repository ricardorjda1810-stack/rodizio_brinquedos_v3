// lib/ui/theme/ui_tokens.dart
import 'package:flutter/material.dart';

class UiTokens {
  UiTokens._();

  // -------------------------
  // Spacing (8px grid)
  // -------------------------
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  // -------------------------
  // Radius
  // -------------------------
  static const double radiusCard = 18;
  static const double radiusButton = 14;
  static const double radiusInput = 14;
  static const double radiusPhoto = 16;

  // -------------------------
  // Icon size
  // -------------------------
  static const double icon = 22;

  // -------------------------
  // Typography
  // -------------------------
  static const double appBarTitle = 20;
  static const double cardTitle = 18;
  static const double body = 14;
  static const double secondary = 13;

  // -------------------------
  // Colors (Design System v1)
  // -------------------------

  /// Fundo geral da aplicação
  static const Color bg = Color(0xFFFAFAFA);

  /// Cor padrão de cards
  static const Color card = Color(0xFFFFFFFF);

  /// Cor primária (azul acinzentado suave)
  static const Color primary = Color(0xFF4F6D7A);

  /// Cor da rodada ativa (verde suave)
  static const Color active = Color(0xFF5A8F7B);

  /// Texto principal
  static const Color text = Color(0xFF333333);

  /// Texto secundário
  static const Color textMuted = Color(0xFF666666);

  /// Cor lúdica suave (placeholder)
  static const Color playfulSoft = Color(0xFFE7F8FB);
}
