import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class PlatformServiceNative implements PlatformService {
  @override
  void openInNewTab() {
    // No-op on native platforms: opening new browser tabs is not supported.
    print('[PlatformServiceNative] openInNewTab() called — no-op.');
  }
}

PlatformService createPlatformServiceImpl({required Config config}) =>
    PlatformServiceNative();
