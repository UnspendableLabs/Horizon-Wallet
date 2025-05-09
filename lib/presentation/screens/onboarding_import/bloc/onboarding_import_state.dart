import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/common/constants.dart';

part 'onboarding_import_state.freezed.dart';

/// Enum to represent the current step in the import flow
enum OnboardingImportStep { inputSeed, inputPassword }

@freezed
class OnboardingImportState with _$OnboardingImportState {
  const factory OnboardingImportState({
    @Default("") String mnemonic,
    String? mnemonicError,
    WalletType? walletType,
    @Default(OnboardingImportStep.inputSeed) currentStep,
    @Default(ImportState.initial()) importState,
  }) = _OnboardingImportState;
}

@freezed
class ImportState with _$ImportState {
  const factory ImportState.initial() = ImportStateNotAsked;
  const factory ImportState.loading() = ImportStateLoading;
  const factory ImportState.success() = ImportStateSuccess;
  const factory ImportState.error({required String message}) = ImportStateError;
}
