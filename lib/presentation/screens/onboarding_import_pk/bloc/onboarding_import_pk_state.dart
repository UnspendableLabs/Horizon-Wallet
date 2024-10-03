import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/common/constants.dart';

part 'onboarding_import_pk_state.freezed.dart';


@freezed
class OnboardingImportPKState with _$OnboardingImportPKState {
  const factory OnboardingImportPKState({
    String? pkError,
    @Default("") String pk,
    @Default(ImportFormat.horizon) importFormat,
    @Default(KeyType.privateKey) KeyType keyType,
    @Default(ImportStateNotAsked) importState,
  }) = _OnboardingImportPKState;
}

abstract class ImportState {}

class ImportStateNotAsked extends ImportState {}

class ImportStatePKCollected extends ImportState {}

class ImportStateLoading extends ImportState {}

class ImportStateSuccess extends ImportState {}

class ImportStateError extends ImportState {
  final String message;
  ImportStateError({required this.message});
}
