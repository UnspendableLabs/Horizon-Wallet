import "package:horizon/domain/repositories/account_settings_repository.dart";

import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  final CacheProvider _cacheProvider;
  final int _defaultGapLimit = 20;

  AccountSettingsRepositoryImpl({required CacheProvider cacheProvider})
      : _cacheProvider = cacheProvider;

  @override
  getGapLimit(String accountUuid) {
    return _cacheProvider.getInt("$accountUuid:gap-limit") ?? _defaultGapLimit;
  }
}
