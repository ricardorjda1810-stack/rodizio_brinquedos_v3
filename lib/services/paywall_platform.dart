import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

bool get isPaywallEnabledForCurrentPlatform {
  if (kIsWeb) return false;
  return Platform.isIOS || Platform.isAndroid;
}
