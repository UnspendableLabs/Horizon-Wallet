import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/imported_address.dart';

import 'package:horizon/domain/entities/wallet.dart';
// import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/account_v2.dart';
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

extension SessionStateAddressesX on SessionState {
  List<Address> get addresses => successOrThrow().addresses;
  List<ImportedAddress> get importedAddresses =>
      successOrThrow().importedAddresses ?? [];
  List<String> get allAddresses => [
        ...addresses.map((e) => e.address),
        ...importedAddresses.map((e) => e.address)
      ];
}

@freezed
class SessionStateSuccess with _$SessionStateSuccess {
  // Private constructor

  @override
  String toString() {
    return 'SessionStateSuccess(redirect: $redirect, decryptionKey: <REDACTED>, accounts: $accounts, addresses: $addresses, importedAddresses: $importedAddresses)';
  }

  const factory SessionStateSuccess({
    required AccountV2? currentAccount,
    required bool redirect,
    // required Wallet wallet,
    required String decryptionKey,
    required List<AccountV2> accounts,
    required List<Address> addresses,
    List<ImportedAddress>? importedAddresses,
  }) = _SessionStateSuccess;
}

@freezed
class Onboarding with _$Onboarding {
  const factory Onboarding.initial() = _OnboardingInitial;
  const factory Onboarding.create() = _Create;
  const factory Onboarding.import() = _Import;
  const factory Onboarding.importPK() = _ImportPK;
}
