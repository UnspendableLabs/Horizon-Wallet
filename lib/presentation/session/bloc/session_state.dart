import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/imported_address.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';

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

extension SessionStateX on SessionState {
  /// Returns `true` if the current state is [SessionState.success].
  SessionStateSuccess successOrThrow() => maybeWhen(
      success: (s) => s,
      orElse: () =>
          throw Exception("SessionState.successOrThrow: expected success"));
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
}

@freezed
class Onboarding with _$Onboarding {
  const factory Onboarding.initial() = _OnboardingInitial;
  const factory Onboarding.create() = _Create;
  const factory Onboarding.import() = _Import;
  const factory Onboarding.importPK() = _ImportPK;
}
