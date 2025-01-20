import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/imported_address.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';

import 'package:pub_semver/pub_semver.dart';

part 'shell_state.freezed.dart';

@freezed
class ShellState with _$ShellState {
  const factory ShellState.initial() = _Initial;
  const factory ShellState.loading() = _Loading;
  const factory ShellState.error(String error) = _Error;
  const factory ShellState.onboarding(Onboarding onboarding) = _Onboarding;
  const factory ShellState.success(ShellStateSuccess succcess) = _Success;
  const factory ShellState.loggedOut() = _LoggedOut;
}

@freezed
class ShellStateSuccess with _$ShellStateSuccess {
  // Private constructor
  const factory ShellStateSuccess._({
    required bool redirect,
    required Wallet wallet,
    required List<Account> accounts,
    required String? currentAccountUuid,
    required List<Address> addresses,
    required Address? currentAddress,
    List<ImportedAddress>? importedAddresses,
    ImportedAddress? currentImportedAddress,
  }) = _ShellStateSuccess;

  // Factory for account/address state
  factory ShellStateSuccess.withAccount({
    required bool redirect,
    required Wallet wallet,
    required List<Account> accounts,
    required String currentAccountUuid,
    required List<Address> addresses,
    required Address currentAddress,
    List<ImportedAddress>? importedAddresses,
  }) {
    return ShellStateSuccess._(
      redirect: redirect,
      wallet: wallet,
      accounts: accounts,
      currentAccountUuid: currentAccountUuid,
      addresses: addresses,
      currentAddress: currentAddress,
      importedAddresses: importedAddresses,
      currentImportedAddress: null,
    );
  }

  // Factory for imported address state
  factory ShellStateSuccess.withImportedAddress({
    required Version current,
    required Version latest,
    required bool shouldShowUpgradeWarning,
    required bool redirect,
    required Wallet wallet,
    required List<Account> accounts,
    required List<Address> addresses,
    required List<ImportedAddress> importedAddresses,
    required ImportedAddress currentImportedAddress,
  }) {
    return ShellStateSuccess._(
      redirect: redirect,
      wallet: wallet,
      accounts: accounts,
      currentAccountUuid: null,
      addresses: addresses,
      currentAddress: null,
      importedAddresses: importedAddresses,
      currentImportedAddress: currentImportedAddress,
    );
  }
}

@freezed
class Onboarding with _$Onboarding {
  const factory Onboarding.initial() = _OnboardingInitial;
  const factory Onboarding.create() = _Create;
  const factory Onboarding.import() = _Import;
  const factory Onboarding.importPK() = _ImportPK;
}
