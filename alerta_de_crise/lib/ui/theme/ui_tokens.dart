import 'package:flutter/material.dart';

import '../../domain/models/risk_state.dart';

final class UiTokens {
  const UiTokens._();

  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const primary = Color(0xFF4F46E5);
  static const secondary = Color(0xFF14B8A6);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const text = Color(0xFF0F172A);
  static const textSoft = Color(0xFF475569);
  static const textFaint = Color(0xFF64748B);

  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  static const double radiusCard = 20;
  static const double radiusButton = 16;
  static const double radiusPill = 999;

  static Color riskColor(String state) {
    return switch (state) {
      'normal' => success,
      'atencao' => warning,
      'alerta' => danger,
      _ => textFaint,
    };
  }

  static String riskLabel(String state) {
    for (final riskState in RiskState.values) {
      if (riskState.key == state) {
        return riskState.label;
      }
    }

    return 'Indefinido';
  }
}
