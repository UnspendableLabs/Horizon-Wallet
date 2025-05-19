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
  WalletType? get walletType => throw _privateConstructorUsedError;
  dynamic get currentStep => throw _privateConstructorUsedError;
  dynamic get importState => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingImportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      WalletType? walletType,
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

  /// Create a copy of OnboardingImportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mnemonic = null,
    Object? mnemonicError = freezed,
    Object? walletType = freezed,
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
      walletType: freezed == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as WalletType?,
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
      WalletType? walletType,
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

  /// Create a copy of OnboardingImportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mnemonic = null,
    Object? mnemonicError = freezed,
    Object? walletType = freezed,
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
      walletType: freezed == walletType
          ? _value.walletType
          : walletType // ignore: cast_nullable_to_non_nullable
              as WalletType?,
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
      this.walletType,
      this.currentStep = OnboardingImportStep.inputSeed,
      this.importState = const ImportState.initial()});

  @override
  @JsonKey()
  final String mnemonic;
  @override
  final String? mnemonicError;
  @override
  final WalletType? walletType;
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

  /// Create a copy of OnboardingImportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      final WalletType? walletType,
      final dynamic currentStep,
      final dynamic importState}) = _$OnboardingImportStateImpl;

  @override
  String get mnemonic;
  @override
  String? get mnemonicError;
  @override
  WalletType? get walletType;
  @override
  dynamic get currentStep;
  @override
  dynamic get importState;

  /// Create a copy of OnboardingImportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingImportStateImplCopyWith<_$OnboardingImportStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ImportState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImportStateNotAsked value) initial,
    required TResult Function(ImportStateLoading value) loading,
    required TResult Function(ImportStateSuccess value) success,
    required TResult Function(ImportStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImportStateNotAsked value)? initial,
    TResult? Function(ImportStateLoading value)? loading,
    TResult? Function(ImportStateSuccess value)? success,
    TResult? Function(ImportStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImportStateNotAsked value)? initial,
    TResult Function(ImportStateLoading value)? loading,
    TResult Function(ImportStateSuccess value)? success,
    TResult Function(ImportStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportStateCopyWith<$Res> {
  factory $ImportStateCopyWith(
          ImportState value, $Res Function(ImportState) then) =
      _$ImportStateCopyWithImpl<$Res, ImportState>;
}

/// @nodoc
class _$ImportStateCopyWithImpl<$Res, $Val extends ImportState>
    implements $ImportStateCopyWith<$Res> {
  _$ImportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ImportStateNotAskedImplCopyWith<$Res> {
  factory _$$ImportStateNotAskedImplCopyWith(_$ImportStateNotAskedImpl value,
          $Res Function(_$ImportStateNotAskedImpl) then) =
      __$$ImportStateNotAskedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ImportStateNotAskedImplCopyWithImpl<$Res>
    extends _$ImportStateCopyWithImpl<$Res, _$ImportStateNotAskedImpl>
    implements _$$ImportStateNotAskedImplCopyWith<$Res> {
  __$$ImportStateNotAskedImplCopyWithImpl(_$ImportStateNotAskedImpl _value,
      $Res Function(_$ImportStateNotAskedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ImportStateNotAskedImpl implements ImportStateNotAsked {
  const _$ImportStateNotAskedImpl();

  @override
  String toString() {
    return 'ImportState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportStateNotAskedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImportStateNotAsked value) initial,
    required TResult Function(ImportStateLoading value) loading,
    required TResult Function(ImportStateSuccess value) success,
    required TResult Function(ImportStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImportStateNotAsked value)? initial,
    TResult? Function(ImportStateLoading value)? loading,
    TResult? Function(ImportStateSuccess value)? success,
    TResult? Function(ImportStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImportStateNotAsked value)? initial,
    TResult Function(ImportStateLoading value)? loading,
    TResult Function(ImportStateSuccess value)? success,
    TResult Function(ImportStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class ImportStateNotAsked implements ImportState {
  const factory ImportStateNotAsked() = _$ImportStateNotAskedImpl;
}

/// @nodoc
abstract class _$$ImportStateLoadingImplCopyWith<$Res> {
  factory _$$ImportStateLoadingImplCopyWith(_$ImportStateLoadingImpl value,
          $Res Function(_$ImportStateLoadingImpl) then) =
      __$$ImportStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ImportStateLoadingImplCopyWithImpl<$Res>
    extends _$ImportStateCopyWithImpl<$Res, _$ImportStateLoadingImpl>
    implements _$$ImportStateLoadingImplCopyWith<$Res> {
  __$$ImportStateLoadingImplCopyWithImpl(_$ImportStateLoadingImpl _value,
      $Res Function(_$ImportStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ImportStateLoadingImpl implements ImportStateLoading {
  const _$ImportStateLoadingImpl();

  @override
  String toString() {
    return 'ImportState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ImportStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImportStateNotAsked value) initial,
    required TResult Function(ImportStateLoading value) loading,
    required TResult Function(ImportStateSuccess value) success,
    required TResult Function(ImportStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImportStateNotAsked value)? initial,
    TResult? Function(ImportStateLoading value)? loading,
    TResult? Function(ImportStateSuccess value)? success,
    TResult? Function(ImportStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImportStateNotAsked value)? initial,
    TResult Function(ImportStateLoading value)? loading,
    TResult Function(ImportStateSuccess value)? success,
    TResult Function(ImportStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class ImportStateLoading implements ImportState {
  const factory ImportStateLoading() = _$ImportStateLoadingImpl;
}

/// @nodoc
abstract class _$$ImportStateSuccessImplCopyWith<$Res> {
  factory _$$ImportStateSuccessImplCopyWith(_$ImportStateSuccessImpl value,
          $Res Function(_$ImportStateSuccessImpl) then) =
      __$$ImportStateSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ImportStateSuccessImplCopyWithImpl<$Res>
    extends _$ImportStateCopyWithImpl<$Res, _$ImportStateSuccessImpl>
    implements _$$ImportStateSuccessImplCopyWith<$Res> {
  __$$ImportStateSuccessImplCopyWithImpl(_$ImportStateSuccessImpl _value,
      $Res Function(_$ImportStateSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ImportStateSuccessImpl implements ImportStateSuccess {
  const _$ImportStateSuccessImpl();

  @override
  String toString() {
    return 'ImportState.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ImportStateSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    return success();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    return success?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImportStateNotAsked value) initial,
    required TResult Function(ImportStateLoading value) loading,
    required TResult Function(ImportStateSuccess value) success,
    required TResult Function(ImportStateError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImportStateNotAsked value)? initial,
    TResult? Function(ImportStateLoading value)? loading,
    TResult? Function(ImportStateSuccess value)? success,
    TResult? Function(ImportStateError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImportStateNotAsked value)? initial,
    TResult Function(ImportStateLoading value)? loading,
    TResult Function(ImportStateSuccess value)? success,
    TResult Function(ImportStateError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class ImportStateSuccess implements ImportState {
  const factory ImportStateSuccess() = _$ImportStateSuccessImpl;
}

/// @nodoc
abstract class _$$ImportStateErrorImplCopyWith<$Res> {
  factory _$$ImportStateErrorImplCopyWith(_$ImportStateErrorImpl value,
          $Res Function(_$ImportStateErrorImpl) then) =
      __$$ImportStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ImportStateErrorImplCopyWithImpl<$Res>
    extends _$ImportStateCopyWithImpl<$Res, _$ImportStateErrorImpl>
    implements _$$ImportStateErrorImplCopyWith<$Res> {
  __$$ImportStateErrorImplCopyWithImpl(_$ImportStateErrorImpl _value,
      $Res Function(_$ImportStateErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ImportStateErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ImportStateErrorImpl implements ImportStateError {
  const _$ImportStateErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'ImportState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportStateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportStateErrorImplCopyWith<_$ImportStateErrorImpl> get copyWith =>
      __$$ImportStateErrorImplCopyWithImpl<_$ImportStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ImportStateNotAsked value) initial,
    required TResult Function(ImportStateLoading value) loading,
    required TResult Function(ImportStateSuccess value) success,
    required TResult Function(ImportStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ImportStateNotAsked value)? initial,
    TResult? Function(ImportStateLoading value)? loading,
    TResult? Function(ImportStateSuccess value)? success,
    TResult? Function(ImportStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ImportStateNotAsked value)? initial,
    TResult Function(ImportStateLoading value)? loading,
    TResult Function(ImportStateSuccess value)? success,
    TResult Function(ImportStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ImportStateError implements ImportState {
  const factory ImportStateError({required final String message}) =
      _$ImportStateErrorImpl;

  String get message;

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportStateErrorImplCopyWith<_$ImportStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
