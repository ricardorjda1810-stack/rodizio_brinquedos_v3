import 'package:flutter/foundation.dart';

// Temporary test bypass controlled by dart-define. Do not enable for App Store builds.
const bool kBypassPaywall = bool.fromEnvironment('BYPASS_PAYWALL');

void debugLogPaywallBypassIfEnabled() {
  assert(() {
    if (kBypassPaywall) {
      debugPrint('BYPASS_PAYWALL ativo: Premium liberado para teste');
    }
    return true;
  }());
}
