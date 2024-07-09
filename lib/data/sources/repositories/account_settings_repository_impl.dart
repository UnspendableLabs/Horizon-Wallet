import "package:horizon/domain/repositories/account_settings_repository.dart";

import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  final CacheProvider _cacheProvider;
  final int _defaultGapLimit = 10;

  AccountSettingsRepositoryImpl({required CacheProvider cacheProvider})
      : _cacheProvider = cacheProvider;

  @override
  getGapLimit(String accountUuid) {
    dynamic gapLimit = _cacheProvider.getInt("$accountUuid:gap-limit");

    if (gapLimit == null) {
      return _defaultGapLimit;
    }

    return gapLimit.toInt();
  }
}
