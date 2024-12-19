import 'package:chrome_extension/runtime.dart';
import 'package:chrome_extension/tabs.dart';
import 'package:horizon/domain/services/platform_service.dart';

class PlatformServiceExtensionImpl implements PlatformService {
  @override
  void openInNewTab() {
    chrome.tabs.create(CreateProperties(
      url: chrome.runtime.getURL('index.html'),
    ));
  }
}
