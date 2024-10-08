// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_issuance_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeIssuanceState {
  dynamic get feeState => throw _privateConstructorUsedError;
  dynamic get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeIssuanceStateCopyWith<ComposeIssuanceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeIssuanceStateCopyWith<$Res> {
  factory $ComposeIssuanceStateCopyWith(ComposeIssuanceState value,
          $Res Function(ComposeIssuanceState) then) =
      _$ComposeIssuanceStateCopyWithImpl<$Res, ComposeIssuanceState>;
  @useResult
  $Res call(
      {dynamic feeState,
      dynamic balancesState,
      FeeOption feeOption,
      SubmitState submitState});
}

/// @nodoc
class _$ComposeIssuanceStateCopyWithImpl<$Res,
        $Val extends ComposeIssuanceState>
    implements $ComposeIssuanceStateCopyWith<$Res> {
  _$ComposeIssuanceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = freezed,
    Object? balancesState = freezed,
    Object? feeOption = null,
    Object? submitState = null,
  }) {
    return _then(_value.copyWith(
      feeState: freezed == feeState
          ? _value.feeState
          : feeState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      balancesState: freezed == balancesState
          ? _value.balancesState
          : balancesState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      feeOption: null == feeOption
          ? _value.feeOption
          : feeOption // ignore: cast_nullable_to_non_nullable
              as FeeOption,
      submitState: null == submitState
          ? _value.submitState
          : submitState // ignore: cast_nullable_to_non_nullable
              as SubmitState,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComposeIssuanceStateImplCopyWith<$Res>
    implements $ComposeIssuanceStateCopyWith<$Res> {
  factory _$$ComposeIssuanceStateImplCopyWith(_$ComposeIssuanceStateImpl value,
          $Res Function(_$ComposeIssuanceStateImpl) then) =
      __$$ComposeIssuanceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic feeState,
      dynamic balancesState,
      FeeOption feeOption,
      SubmitState submitState});
}

/// @nodoc
class __$$ComposeIssuanceStateImplCopyWithImpl<$Res>
    extends _$ComposeIssuanceStateCopyWithImpl<$Res, _$ComposeIssuanceStateImpl>
    implements _$$ComposeIssuanceStateImplCopyWith<$Res> {
  __$$ComposeIssuanceStateImplCopyWithImpl(_$ComposeIssuanceStateImpl _value,
      $Res Function(_$ComposeIssuanceStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = freezed,
    Object? balancesState = freezed,
    Object? feeOption = null,
    Object? submitState = null,
  }) {
    return _then(_$ComposeIssuanceStateImpl(
      feeState: freezed == feeState ? _value.feeState! : feeState,
      balancesState:
          freezed == balancesState ? _value.balancesState! : balancesState,
      feeOption: null == feeOption
          ? _value.feeOption
          : feeOption // ignore: cast_nullable_to_non_nullable
              as FeeOption,
      submitState: null == submitState
          ? _value.submitState
          : submitState // ignore: cast_nullable_to_non_nullable
              as SubmitState,
    ));
  }
}

/// @nodoc

class _$ComposeIssuanceStateImpl implements _ComposeIssuanceState {
  const _$ComposeIssuanceStateImpl(
      {this.feeState = const FeeState.initial(),
      this.balancesState = const BalancesState.initial(),
      required this.feeOption,
      required this.submitState});

  @override
  @JsonKey()
  final dynamic feeState;
  @override
  @JsonKey()
  final dynamic balancesState;
  @override
  final FeeOption feeOption;
  @override
  final SubmitState submitState;

  @override
  String toString() {
    return 'ComposeIssuanceState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeIssuanceStateImpl &&
            const DeepCollectionEquality().equals(other.feeState, feeState) &&
            const DeepCollectionEquality()
                .equals(other.balancesState, balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(feeState),
      const DeepCollectionEquality().hash(balancesState),
      feeOption,
      submitState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeIssuanceStateImplCopyWith<_$ComposeIssuanceStateImpl>
      get copyWith =>
          __$$ComposeIssuanceStateImplCopyWithImpl<_$ComposeIssuanceStateImpl>(
              this, _$identity);
}

abstract class _ComposeIssuanceState implements ComposeIssuanceState {
  const factory _ComposeIssuanceState(
      {final dynamic feeState,
      final dynamic balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState}) = _$ComposeIssuanceStateImpl;

  @override
  dynamic get feeState;
  @override
  dynamic get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override
  @JsonKey(ignore: true)
  _$$ComposeIssuanceStateImplCopyWith<_$ComposeIssuanceStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FeeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(FeeEstimates feeEstimates) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(FeeEstimates feeEstimates)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(FeeEstimates feeEstimates)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FeeInitial value) initial,
    required TResult Function(_FeeLoading value) loading,
    required TResult Function(_FeeSuccess value) success,
    required TResult Function(_FeeError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FeeInitial value)? initial,
    TResult? Function(_FeeLoading value)? loading,
    TResult? Function(_FeeSuccess value)? success,
    TResult? Function(_FeeError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FeeInitial value)? initial,
    TResult Function(_FeeLoading value)? loading,
    TResult Function(_FeeSuccess value)? success,
    TResult Function(_FeeError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeStateCopyWith<$Res> {
  factory $FeeStateCopyWith(FeeState value, $Res Function(FeeState) then) =
      _$FeeStateCopyWithImpl<$Res, FeeState>;
}

/// @nodoc
class _$FeeStateCopyWithImpl<$Res, $Val extends FeeState>
    implements $FeeStateCopyWith<$Res> {
  _$FeeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$FeeInitialImplCopyWith<$Res> {
  factory _$$FeeInitialImplCopyWith(
          _$FeeInitialImpl value, $Res Function(_$FeeInitialImpl) then) =
      __$$FeeInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FeeInitialImplCopyWithImpl<$Res>
    extends _$FeeStateCopyWithImpl<$Res, _$FeeInitialImpl>
    implements _$$FeeInitialImplCopyWith<$Res> {
  __$$FeeInitialImplCopyWithImpl(
      _$FeeInitialImpl _value, $Res Function(_$FeeInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$FeeInitialImpl implements _FeeInitial {
  const _$FeeInitialImpl();

  @override
  String toString() {
    return 'FeeState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FeeInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(FeeEstimates feeEstimates) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(FeeEstimates feeEstimates)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(FeeEstimates feeEstimates)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_FeeInitial value) initial,
    required TResult Function(_FeeLoading value) loading,
    required TResult Function(_FeeSuccess value) success,
    required TResult Function(_FeeError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FeeInitial value)? initial,
    TResult? Function(_FeeLoading value)? loading,
    TResult? Function(_FeeSuccess value)? success,
    TResult? Function(_FeeError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FeeInitial value)? initial,
    TResult Function(_FeeLoading value)? loading,
    TResult Function(_FeeSuccess value)? success,
    TResult Function(_FeeError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _FeeInitial implements FeeState {
  const factory _FeeInitial() = _$FeeInitialImpl;
}

/// @nodoc
abstract class _$$FeeLoadingImplCopyWith<$Res> {
  factory _$$FeeLoadingImplCopyWith(
          _$FeeLoadingImpl value, $Res Function(_$FeeLoadingImpl) then) =
      __$$FeeLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FeeLoadingImplCopyWithImpl<$Res>
    extends _$FeeStateCopyWithImpl<$Res, _$FeeLoadingImpl>
    implements _$$FeeLoadingImplCopyWith<$Res> {
  __$$FeeLoadingImplCopyWithImpl(
      _$FeeLoadingImpl _value, $Res Function(_$FeeLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$FeeLoadingImpl implements _FeeLoading {
  const _$FeeLoadingImpl();

  @override
  String toString() {
    return 'FeeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FeeLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(FeeEstimates feeEstimates) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(FeeEstimates feeEstimates)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(FeeEstimates feeEstimates)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_FeeInitial value) initial,
    required TResult Function(_FeeLoading value) loading,
    required TResult Function(_FeeSuccess value) success,
    required TResult Function(_FeeError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FeeInitial value)? initial,
    TResult? Function(_FeeLoading value)? loading,
    TResult? Function(_FeeSuccess value)? success,
    TResult? Function(_FeeError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FeeInitial value)? initial,
    TResult Function(_FeeLoading value)? loading,
    TResult Function(_FeeSuccess value)? success,
    TResult Function(_FeeError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _FeeLoading implements FeeState {
  const factory _FeeLoading() = _$FeeLoadingImpl;
}

/// @nodoc
abstract class _$$FeeSuccessImplCopyWith<$Res> {
  factory _$$FeeSuccessImplCopyWith(
          _$FeeSuccessImpl value, $Res Function(_$FeeSuccessImpl) then) =
      __$$FeeSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FeeEstimates feeEstimates});
}

/// @nodoc
class __$$FeeSuccessImplCopyWithImpl<$Res>
    extends _$FeeStateCopyWithImpl<$Res, _$FeeSuccessImpl>
    implements _$$FeeSuccessImplCopyWith<$Res> {
  __$$FeeSuccessImplCopyWithImpl(
      _$FeeSuccessImpl _value, $Res Function(_$FeeSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeEstimates = null,
  }) {
    return _then(_$FeeSuccessImpl(
      null == feeEstimates
          ? _value.feeEstimates
          : feeEstimates // ignore: cast_nullable_to_non_nullable
              as FeeEstimates,
    ));
  }
}

/// @nodoc

class _$FeeSuccessImpl implements _FeeSuccess {
  const _$FeeSuccessImpl(this.feeEstimates);

  @override
  final FeeEstimates feeEstimates;

  @override
  String toString() {
    return 'FeeState.success(feeEstimates: $feeEstimates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeSuccessImpl &&
            (identical(other.feeEstimates, feeEstimates) ||
                other.feeEstimates == feeEstimates));
  }

  @override
  int get hashCode => Object.hash(runtimeType, feeEstimates);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeSuccessImplCopyWith<_$FeeSuccessImpl> get copyWith =>
      __$$FeeSuccessImplCopyWithImpl<_$FeeSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(FeeEstimates feeEstimates) success,
    required TResult Function(String error) error,
  }) {
    return success(feeEstimates);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(FeeEstimates feeEstimates)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(feeEstimates);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(FeeEstimates feeEstimates)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(feeEstimates);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FeeInitial value) initial,
    required TResult Function(_FeeLoading value) loading,
    required TResult Function(_FeeSuccess value) success,
    required TResult Function(_FeeError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FeeInitial value)? initial,
    TResult? Function(_FeeLoading value)? loading,
    TResult? Function(_FeeSuccess value)? success,
    TResult? Function(_FeeError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FeeInitial value)? initial,
    TResult Function(_FeeLoading value)? loading,
    TResult Function(_FeeSuccess value)? success,
    TResult Function(_FeeError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _FeeSuccess implements FeeState {
  const factory _FeeSuccess(final FeeEstimates feeEstimates) = _$FeeSuccessImpl;

  FeeEstimates get feeEstimates;
  @JsonKey(ignore: true)
  _$$FeeSuccessImplCopyWith<_$FeeSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeeErrorImplCopyWith<$Res> {
  factory _$$FeeErrorImplCopyWith(
          _$FeeErrorImpl value, $Res Function(_$FeeErrorImpl) then) =
      __$$FeeErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$FeeErrorImplCopyWithImpl<$Res>
    extends _$FeeStateCopyWithImpl<$Res, _$FeeErrorImpl>
    implements _$$FeeErrorImplCopyWith<$Res> {
  __$$FeeErrorImplCopyWithImpl(
      _$FeeErrorImpl _value, $Res Function(_$FeeErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$FeeErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FeeErrorImpl implements _FeeError {
  const _$FeeErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'FeeState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeErrorImplCopyWith<_$FeeErrorImpl> get copyWith =>
      __$$FeeErrorImplCopyWithImpl<_$FeeErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(FeeEstimates feeEstimates) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(FeeEstimates feeEstimates)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(FeeEstimates feeEstimates)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FeeInitial value) initial,
    required TResult Function(_FeeLoading value) loading,
    required TResult Function(_FeeSuccess value) success,
    required TResult Function(_FeeError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FeeInitial value)? initial,
    TResult? Function(_FeeLoading value)? loading,
    TResult? Function(_FeeSuccess value)? success,
    TResult? Function(_FeeError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FeeInitial value)? initial,
    TResult Function(_FeeLoading value)? loading,
    TResult Function(_FeeSuccess value)? success,
    TResult Function(_FeeError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _FeeError implements FeeState {
  const factory _FeeError(final String error) = _$FeeErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$FeeErrorImplCopyWith<_$FeeErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AddressesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressesStateCopyWith<$Res> {
  factory $AddressesStateCopyWith(
          AddressesState value, $Res Function(AddressesState) then) =
      _$AddressesStateCopyWithImpl<$Res, AddressesState>;
}

/// @nodoc
class _$AddressesStateCopyWithImpl<$Res, $Val extends AddressesState>
    implements $AddressesStateCopyWith<$Res> {
  _$AddressesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AddressInitialImplCopyWith<$Res> {
  factory _$$AddressInitialImplCopyWith(_$AddressInitialImpl value,
          $Res Function(_$AddressInitialImpl) then) =
      __$$AddressInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AddressInitialImplCopyWithImpl<$Res>
    extends _$AddressesStateCopyWithImpl<$Res, _$AddressInitialImpl>
    implements _$$AddressInitialImplCopyWith<$Res> {
  __$$AddressInitialImplCopyWithImpl(
      _$AddressInitialImpl _value, $Res Function(_$AddressInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AddressInitialImpl implements _AddressInitial {
  const _$AddressInitialImpl();

  @override
  String toString() {
    return 'AddressesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AddressInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _AddressInitial implements AddressesState {
  const factory _AddressInitial() = _$AddressInitialImpl;
}

/// @nodoc
abstract class _$$AddressLoadingImplCopyWith<$Res> {
  factory _$$AddressLoadingImplCopyWith(_$AddressLoadingImpl value,
          $Res Function(_$AddressLoadingImpl) then) =
      __$$AddressLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AddressLoadingImplCopyWithImpl<$Res>
    extends _$AddressesStateCopyWithImpl<$Res, _$AddressLoadingImpl>
    implements _$$AddressLoadingImplCopyWith<$Res> {
  __$$AddressLoadingImplCopyWithImpl(
      _$AddressLoadingImpl _value, $Res Function(_$AddressLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AddressLoadingImpl implements _AddressLoading {
  const _$AddressLoadingImpl();

  @override
  String toString() {
    return 'AddressesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AddressLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _AddressLoading implements AddressesState {
  const factory _AddressLoading() = _$AddressLoadingImpl;
}

/// @nodoc
abstract class _$$AddressSuccessImplCopyWith<$Res> {
  factory _$$AddressSuccessImplCopyWith(_$AddressSuccessImpl value,
          $Res Function(_$AddressSuccessImpl) then) =
      __$$AddressSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Address> addresses});
}

/// @nodoc
class __$$AddressSuccessImplCopyWithImpl<$Res>
    extends _$AddressesStateCopyWithImpl<$Res, _$AddressSuccessImpl>
    implements _$$AddressSuccessImplCopyWith<$Res> {
  __$$AddressSuccessImplCopyWithImpl(
      _$AddressSuccessImpl _value, $Res Function(_$AddressSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addresses = null,
  }) {
    return _then(_$AddressSuccessImpl(
      null == addresses
          ? _value._addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as List<Address>,
    ));
  }
}

/// @nodoc

class _$AddressSuccessImpl implements _AddressSuccess {
  const _$AddressSuccessImpl(final List<Address> addresses)
      : _addresses = addresses;

  final List<Address> _addresses;
  @override
  List<Address> get addresses {
    if (_addresses is EqualUnmodifiableListView) return _addresses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addresses);
  }

  @override
  String toString() {
    return 'AddressesState.success(addresses: $addresses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressSuccessImpl &&
            const DeepCollectionEquality()
                .equals(other._addresses, _addresses));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_addresses));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressSuccessImplCopyWith<_$AddressSuccessImpl> get copyWith =>
      __$$AddressSuccessImplCopyWithImpl<_$AddressSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(String error) error,
  }) {
    return success(addresses);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(addresses);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(addresses);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _AddressSuccess implements AddressesState {
  const factory _AddressSuccess(final List<Address> addresses) =
      _$AddressSuccessImpl;

  List<Address> get addresses;
  @JsonKey(ignore: true)
  _$$AddressSuccessImplCopyWith<_$AddressSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AddressErrorImplCopyWith<$Res> {
  factory _$$AddressErrorImplCopyWith(
          _$AddressErrorImpl value, $Res Function(_$AddressErrorImpl) then) =
      __$$AddressErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$AddressErrorImplCopyWithImpl<$Res>
    extends _$AddressesStateCopyWithImpl<$Res, _$AddressErrorImpl>
    implements _$$AddressErrorImplCopyWith<$Res> {
  __$$AddressErrorImplCopyWithImpl(
      _$AddressErrorImpl _value, $Res Function(_$AddressErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$AddressErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AddressErrorImpl implements _AddressError {
  const _$AddressErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'AddressesState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressErrorImplCopyWith<_$AddressErrorImpl> get copyWith =>
      __$$AddressErrorImplCopyWithImpl<_$AddressErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _AddressError implements AddressesState {
  const factory _AddressError(final String error) = _$AddressErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$AddressErrorImplCopyWith<_$AddressErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BalancesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Balance> balances) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Balance> balances)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Balance> balances)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_BalanceInital value) initial,
    required TResult Function(_BalanceLoading value) loading,
    required TResult Function(_BalanceSuccess value) success,
    required TResult Function(_BalanceError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalanceInital value)? initial,
    TResult? Function(_BalanceLoading value)? loading,
    TResult? Function(_BalanceSuccess value)? success,
    TResult? Function(_BalanceError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalanceInital value)? initial,
    TResult Function(_BalanceLoading value)? loading,
    TResult Function(_BalanceSuccess value)? success,
    TResult Function(_BalanceError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalancesStateCopyWith<$Res> {
  factory $BalancesStateCopyWith(
          BalancesState value, $Res Function(BalancesState) then) =
      _$BalancesStateCopyWithImpl<$Res, BalancesState>;
}

/// @nodoc
class _$BalancesStateCopyWithImpl<$Res, $Val extends BalancesState>
    implements $BalancesStateCopyWith<$Res> {
  _$BalancesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$BalanceInitalImplCopyWith<$Res> {
  factory _$$BalanceInitalImplCopyWith(
          _$BalanceInitalImpl value, $Res Function(_$BalanceInitalImpl) then) =
      __$$BalanceInitalImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BalanceInitalImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalanceInitalImpl>
    implements _$$BalanceInitalImplCopyWith<$Res> {
  __$$BalanceInitalImplCopyWithImpl(
      _$BalanceInitalImpl _value, $Res Function(_$BalanceInitalImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$BalanceInitalImpl implements _BalanceInital {
  const _$BalanceInitalImpl();

  @override
  String toString() {
    return 'BalancesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BalanceInitalImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Balance> balances) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Balance> balances)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Balance> balances)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_BalanceInital value) initial,
    required TResult Function(_BalanceLoading value) loading,
    required TResult Function(_BalanceSuccess value) success,
    required TResult Function(_BalanceError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalanceInital value)? initial,
    TResult? Function(_BalanceLoading value)? loading,
    TResult? Function(_BalanceSuccess value)? success,
    TResult? Function(_BalanceError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalanceInital value)? initial,
    TResult Function(_BalanceLoading value)? loading,
    TResult Function(_BalanceSuccess value)? success,
    TResult Function(_BalanceError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _BalanceInital implements BalancesState {
  const factory _BalanceInital() = _$BalanceInitalImpl;
}

/// @nodoc
abstract class _$$BalanceLoadingImplCopyWith<$Res> {
  factory _$$BalanceLoadingImplCopyWith(_$BalanceLoadingImpl value,
          $Res Function(_$BalanceLoadingImpl) then) =
      __$$BalanceLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BalanceLoadingImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalanceLoadingImpl>
    implements _$$BalanceLoadingImplCopyWith<$Res> {
  __$$BalanceLoadingImplCopyWithImpl(
      _$BalanceLoadingImpl _value, $Res Function(_$BalanceLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$BalanceLoadingImpl implements _BalanceLoading {
  const _$BalanceLoadingImpl();

  @override
  String toString() {
    return 'BalancesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BalanceLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Balance> balances) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Balance> balances)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Balance> balances)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_BalanceInital value) initial,
    required TResult Function(_BalanceLoading value) loading,
    required TResult Function(_BalanceSuccess value) success,
    required TResult Function(_BalanceError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalanceInital value)? initial,
    TResult? Function(_BalanceLoading value)? loading,
    TResult? Function(_BalanceSuccess value)? success,
    TResult? Function(_BalanceError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalanceInital value)? initial,
    TResult Function(_BalanceLoading value)? loading,
    TResult Function(_BalanceSuccess value)? success,
    TResult Function(_BalanceError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _BalanceLoading implements BalancesState {
  const factory _BalanceLoading() = _$BalanceLoadingImpl;
}

/// @nodoc
abstract class _$$BalanceSuccessImplCopyWith<$Res> {
  factory _$$BalanceSuccessImplCopyWith(_$BalanceSuccessImpl value,
          $Res Function(_$BalanceSuccessImpl) then) =
      __$$BalanceSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Balance> balances});
}

/// @nodoc
class __$$BalanceSuccessImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalanceSuccessImpl>
    implements _$$BalanceSuccessImplCopyWith<$Res> {
  __$$BalanceSuccessImplCopyWithImpl(
      _$BalanceSuccessImpl _value, $Res Function(_$BalanceSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balances = null,
  }) {
    return _then(_$BalanceSuccessImpl(
      null == balances
          ? _value._balances
          : balances // ignore: cast_nullable_to_non_nullable
              as List<Balance>,
    ));
  }
}

/// @nodoc

class _$BalanceSuccessImpl implements _BalanceSuccess {
  const _$BalanceSuccessImpl(final List<Balance> balances)
      : _balances = balances;

  final List<Balance> _balances;
  @override
  List<Balance> get balances {
    if (_balances is EqualUnmodifiableListView) return _balances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_balances);
  }

  @override
  String toString() {
    return 'BalancesState.success(balances: $balances)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceSuccessImpl &&
            const DeepCollectionEquality().equals(other._balances, _balances));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_balances));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceSuccessImplCopyWith<_$BalanceSuccessImpl> get copyWith =>
      __$$BalanceSuccessImplCopyWithImpl<_$BalanceSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Balance> balances) success,
    required TResult Function(String error) error,
  }) {
    return success(balances);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Balance> balances)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(balances);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Balance> balances)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(balances);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_BalanceInital value) initial,
    required TResult Function(_BalanceLoading value) loading,
    required TResult Function(_BalanceSuccess value) success,
    required TResult Function(_BalanceError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalanceInital value)? initial,
    TResult? Function(_BalanceLoading value)? loading,
    TResult? Function(_BalanceSuccess value)? success,
    TResult? Function(_BalanceError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalanceInital value)? initial,
    TResult Function(_BalanceLoading value)? loading,
    TResult Function(_BalanceSuccess value)? success,
    TResult Function(_BalanceError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _BalanceSuccess implements BalancesState {
  const factory _BalanceSuccess(final List<Balance> balances) =
      _$BalanceSuccessImpl;

  List<Balance> get balances;
  @JsonKey(ignore: true)
  _$$BalanceSuccessImplCopyWith<_$BalanceSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BalanceErrorImplCopyWith<$Res> {
  factory _$$BalanceErrorImplCopyWith(
          _$BalanceErrorImpl value, $Res Function(_$BalanceErrorImpl) then) =
      __$$BalanceErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$BalanceErrorImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalanceErrorImpl>
    implements _$$BalanceErrorImplCopyWith<$Res> {
  __$$BalanceErrorImplCopyWithImpl(
      _$BalanceErrorImpl _value, $Res Function(_$BalanceErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$BalanceErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BalanceErrorImpl implements _BalanceError {
  const _$BalanceErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'BalancesState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceErrorImplCopyWith<_$BalanceErrorImpl> get copyWith =>
      __$$BalanceErrorImplCopyWithImpl<_$BalanceErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Balance> balances) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Balance> balances)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Balance> balances)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_BalanceInital value) initial,
    required TResult Function(_BalanceLoading value) loading,
    required TResult Function(_BalanceSuccess value) success,
    required TResult Function(_BalanceError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalanceInital value)? initial,
    TResult? Function(_BalanceLoading value)? loading,
    TResult? Function(_BalanceSuccess value)? success,
    TResult? Function(_BalanceError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalanceInital value)? initial,
    TResult Function(_BalanceLoading value)? loading,
    TResult Function(_BalanceSuccess value)? success,
    TResult Function(_BalanceError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _BalanceError implements BalancesState {
  const factory _BalanceError(final String error) = _$BalanceErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$BalanceErrorImplCopyWith<_$BalanceErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
