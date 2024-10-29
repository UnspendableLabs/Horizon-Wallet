import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/imported_address.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';

part 'shell_state.freezed.dart';

@freezed
class ShellState with _$ShellState {
  const factory ShellState.initial() = _Initial;
  const factory ShellState.loading() = _Loading;
  const factory ShellState.error(String error) = _Error;
  const factory ShellState.onboarding(Onboarding onboarding) = _Onboarding;
  const factory ShellState.success(ShellStateSuccess succcess) = _Success;
}

@freezed
class ShellStateSuccess with _$ShellStateSuccess {
  const factory ShellStateSuccess({
    required bool redirect,
    required Wallet wallet,
    required List<Account> accounts,
    required String? currentAccountUuid,
    required List<Address> addresses,
    required Address? currentAddress,
    List<ImportedAddress>? importedAddresses,
    ImportedAddress? currentImportedAddress,
  }) = _ShellStateSuccess;
}

@freezed
class Onboarding with _$Onboarding {
  const factory Onboarding.initial() = _OnboardingInitial;
  const factory Onboarding.create() = _Create;
  const factory Onboarding.import() = _Import;
  const factory Onboarding.importPK() = _ImportPK;
}
