// In a new file like test_config.dart
import 'package:flutter/foundation.dart';

class TestConfig {
  static bool skipCounterwallet = false;

  // Only allow modification in test mode
  static void setTestValue(bool value) {
    assert(() {
      skipCounterwallet = value;
      return true;
    }());
  }

  // Getter that's safe to use in production
  static bool get isSkipCounterwallet {
    if (kDebugMode) {
      return skipCounterwallet;
    }
    return false; // Default production value
  }
}
