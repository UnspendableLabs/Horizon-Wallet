import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/imported_address.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';

import 'package:pub_semver/pub_semver.dart';

part 'session_state.freezed.dart';

@freezed
class SessionState with _$SessionState {
  const factory SessionState.initial() = _Initial;
  const factory SessionState.loading() = _Loading;
  const factory SessionState.error(String error) = _Error;
  const factory SessionState.onboarding(Onboarding onboarding) = _Onboarding;
  const factory SessionState.success(SessionStateSuccess succcess) = _Success;
  const factory SessionState.loggedOut() = _LoggedOut;
}

@freezed
class SessionStateSuccess with _$SessionStateSuccess {
  // Private constructor

  @override
  String toString() {
    return 'SessionStateSuccess(redirect: $redirect, wallet: $wallet, decryptionKey: <REDACTED>, accounts: $accounts, currentAccountUuid: $currentAccountUuid, addresses: $addresses, currentAddress: $currentAddress, importedAddresses: $importedAddresses, currentImportedAddress: $currentImportedAddress)';
  }

  const factory SessionStateSuccess({
    required bool redirect,
    required Wallet wallet,
    required String decryptionKey,
    required List<Account> accounts,
    required String? currentAccountUuid,
    required List<Address> addresses,
    required Address? currentAddress,
    List<ImportedAddress>? importedAddresses,
    ImportedAddress? currentImportedAddress,
  }) = _SessionStateSuccess;

  // Factory for account/address state
  factory SessionStateSuccess.withAccount({
    required bool redirect,
    required Wallet wallet,
    required String decryptionKey,
    required List<Account> accounts,
    required String currentAccountUuid,
    required List<Address> addresses,
    required Address currentAddress,
    List<ImportedAddress>? importedAddresses,
  }) {
    return SessionStateSuccess(
      redirect: redirect,
      wallet: wallet,
      decryptionKey: decryptionKey,
      accounts: accounts,
      currentAccountUuid: currentAccountUuid,
      addresses: addresses,
      currentAddress: currentAddress,
      importedAddresses: importedAddresses,
      currentImportedAddress: null,
    );
  }

  // Factory for imported address state
  factory SessionStateSuccess.withImportedAddress({
    required Version current,
    required Version latest,
    required bool shouldShowUpgradeWarning,
    required bool redirect,
    required Wallet wallet,
    required String decryptedSecretKey,
    required List<Account> accounts,
    required List<Address> addresses,
    required List<ImportedAddress> importedAddresses,
    required ImportedAddress currentImportedAddress,
  }) {
    return SessionStateSuccess(
      redirect: redirect,
      wallet: wallet,
      decryptionKey: decryptedSecretKey,
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
