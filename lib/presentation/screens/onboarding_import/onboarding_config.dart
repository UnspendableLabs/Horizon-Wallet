// In a new file like test_config.dart
import 'package:flutter/foundation.dart';

class OnboardingConfig {
  static bool freewalletImportBip39 = false;

  // Only allow modification in test mode
  static void setIsFreewalletImportBip39(bool value) {
    assert(() {
      freewalletImportBip39 = value;
      return true;
    }());
  }

  // Getter that's safe to use in production
  static bool get isFreewalletImportBip39 {
    if (kDebugMode) {
      return freewalletImportBip39;
    }
    return false; // Default production value
  }
}
