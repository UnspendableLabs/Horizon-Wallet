import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  bool get requirePasswordForCryptoOperations =>
      Settings.getValue<bool>(
          SettingsKeys.requiredPasswordForCryptoOperations.toString()) ??
      false;

  @override
  int get inactivityTimeout =>
      Settings.getValue<int>(SettingsKeys.inactivityTimeout.toString()) ?? 5;

  @override
  int get lostFocusTimeout =>
      Settings.getValue<int>(SettingsKeys.lostFocusTimeout.toString()) ?? 1;

  @override
  String? get walletConfigID =>
      Settings.getValue<String>(SettingsKeys.walletConfigID.toString());
  //
  // @override
  // Network get network => Option.fromNullable(
  //         Settings.getValue<String>((SettingsKeys.network.toString())))
  //     .flatMap(
  //       NetworkX.fromString,
  //     )
  //     .getOrElse(() => Network.mainnet);

  // basePath and network need to be kepts in a sync...

  // @override
  // BasePath get basePath => Option.fromNullable(
  //         Settings.getValue<String>((SettingsKeys.basePath.toString())))
  //     .map(BasePath.deserialize)
  //     .getOrThrow("invariant: basePath is not set");
  //
  // @override
  // Future<void> setNetwork(Network value) =>
  //     Settings.setValue(SettingsKeys.network.toString(), value.name);
  //
  // @override
  // Future<void> setBasePath(BasePath value) =>
  //     Settings.setValue(SettingsKeys.basePath.toString(), value.serialize());

  @override
  Future<void> setWalletConfigID(String value) =>
      Settings.setValue(SettingsKeys.walletConfigID.toString(), value);
}
