// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_import_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingImportState {
  String get mnemonic => throw _privateConstructorUsedError;
  String? get mnemonicError => throw _privateConstructorUsedError;
  WalletType get walletType => throw _privateConstructorUsedError;
  dynamic get currentStep => throw _privateConstructorUsedError;
  dynamic get importState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OnboardingImportStateCopyWith<OnboardingImportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingImportStateCopyWith<$Res> {
  factory $OnboardingImportStateCopyWith(OnboardingImportState value,
          $Res Function(OnboardingImportState) then) =
      _$OnboardingImportStateCopyWithImpl<$Res, OnboardingImportState>;
  @useResult
  $Res call(
      {String mnemonic,
      String? mnemonicError,
      WalletType walletType,
      dynamic currentStep,
      dynamic importState});
}

/// @nodoc
class _$OnboardingImportStateCopyWithImpl<$Res,
        $Val extends OnboardingImportState>
    implements $OnboardingImportStateCopyWith<$Res> {
  _$OnboardingImportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mnemonic = null,
    Object? mnemonicError = freezed,
    Object? walletType = null,
    Object? currentStep = freezed,
    Object? importState = freezed,
  }) {
    return _then(_value.copyWith(
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      mnemonicError: freezed == mnemonicError
          ? _value.mnemonicError
          : mnemonicError // ignore: cast_nullable_to_non_nullable
              as String?,
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as WalletType,
      currentStep: freezed == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as dynamic,
      importState: freezed == importState
          ? _value.importState
          : importState // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingImportStateImplCopyWith<$Res>
    implements $OnboardingImportStateCopyWith<$Res> {
  factory _$$OnboardingImportStateImplCopyWith(
          _$OnboardingImportStateImpl value,
          $Res Function(_$OnboardingImportStateImpl) then) =
      __$$OnboardingImportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mnemonic,
      String? mnemonicError,
      WalletType walletType,
      dynamic currentStep,
      dynamic importState});
}

/// @nodoc
class __$$OnboardingImportStateImplCopyWithImpl<$Res>
    extends _$OnboardingImportStateCopyWithImpl<$Res,
        _$OnboardingImportStateImpl>
    implements _$$OnboardingImportStateImplCopyWith<$Res> {
  __$$OnboardingImportStateImplCopyWithImpl(_$OnboardingImportStateImpl _value,
      $Res Function(_$OnboardingImportStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mnemonic = null,
    Object? mnemonicError = freezed,
    Object? walletType = null,
    Object? currentStep = freezed,
    Object? importState = freezed,
  }) {
    return _then(_$OnboardingImportStateImpl(
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      mnemonicError: freezed == mnemonicError
          ? _value.mnemonicError
          : mnemonicError // ignore: cast_nullable_to_non_nullable
              as String?,
      walletType: null == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as WalletType,
      currentStep: freezed == currentStep ? _value.currentStep! : currentStep,
      importState: freezed == importState ? _value.importState! : importState,
    ));
  }
}

/// @nodoc

class _$OnboardingImportStateImpl implements _OnboardingImportState {
  const _$OnboardingImportStateImpl(
      {this.mnemonic = "",
      this.mnemonicError,
      this.walletType = WalletType.horizon,
      this.currentStep = OnboardingImportStep.chooseFormat,
      this.importState = ImportStateNotAsked});

  @override
  @JsonKey()
  final String mnemonic;
  @override
  final String? mnemonicError;
  @override
  @JsonKey()
  final WalletType walletType;
  @override
  @JsonKey()
  final dynamic currentStep;
  @override
  @JsonKey()
  final dynamic importState;

  @override
  String toString() {
    return 'OnboardingImportState(mnemonic: $mnemonic, mnemonicError: $mnemonicError, walletType: $walletType, currentStep: $currentStep, importState: $importState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingImportStateImpl &&
            (identical(other.mnemonic, mnemonic) ||
                other.mnemonic == mnemonic) &&
            (identical(other.mnemonicError, mnemonicError) ||
                other.mnemonicError == mnemonicError) &&
            (identical(other.walletType, walletType) ||
                other.walletType == walletType) &&
            const DeepCollectionEquality()
                .equals(other.currentStep, currentStep) &&
            const DeepCollectionEquality()
                .equals(other.importState, importState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      mnemonic,
      mnemonicError,
      walletType,
      const DeepCollectionEquality().hash(currentStep),
      const DeepCollectionEquality().hash(importState));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingImportStateImplCopyWith<_$OnboardingImportStateImpl>
      get copyWith => __$$OnboardingImportStateImplCopyWithImpl<
          _$OnboardingImportStateImpl>(this, _$identity);
}

abstract class _OnboardingImportState implements OnboardingImportState {
  const factory _OnboardingImportState(
      {final String mnemonic,
      final String? mnemonicError,
      final WalletType walletType,
      final dynamic currentStep,
      final dynamic importState}) = _$OnboardingImportStateImpl;

  @override
  String get mnemonic;
  @override
  String? get mnemonicError;
  @override
  WalletType get walletType;
  @override
  dynamic get currentStep;
  @override
  dynamic get importState;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingImportStateImplCopyWith<_$OnboardingImportStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
