import 'package:chrome_extension/runtime.dart';
import 'package:chrome_extension/tabs.dart';
import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class PlatformServiceWeb implements PlatformService {
  Config config;

  PlatformServiceWeb({required this.config});

  @override
  void openInNewTab() {
    if (config.isWebExtension) {
      chrome.tabs.create(CreateProperties(
        url: chrome.runtime.getURL('index.html'),
      ));
    }
  }
}

PlatformService createPlatformServiceImpl({required Config config}) =>
    PlatformServiceWeb(config: config);
