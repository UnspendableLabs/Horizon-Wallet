// chrome_runtime.dart
import 'dart:js_util' as js_util;

typedef MessageCallback = void Function(
    dynamic message, dynamic sender, Function sendResponse);

class ChromeRuntime {
  final dynamic _chromeRuntime;

  ChromeRuntime._(this._chromeRuntime);

  static ChromeRuntime get instance {
    final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
    if (chrome == null) {
      throw Exception('chrome API is not available.');
    }
    final runtime = js_util.getProperty(chrome, 'runtime');
    if (runtime == null) {
      throw Exception('chrome.runtime API is not available.');
    }
    print("dis my runtime");
    return ChromeRuntime._(runtime);
  }

  void onMessage(MessageCallback callback) {
    final onMessage = js_util.getProperty(_chromeRuntime, 'onMessage');
    print("me rejistered");
    js_util.callMethod(onMessage, 'addListener', [
      js_util.allowInterop((message, sender, sendResponse) {
        callback(message, sender, sendResponse);
      })
    ]);
  }
}
