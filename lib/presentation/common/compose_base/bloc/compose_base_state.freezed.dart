// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_base_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeErrorImplCopyWith<_$FeeErrorImpl> get copyWith =>
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
    required TResult Function(_BalancesInitial value) initial,
    required TResult Function(_BalancesLoading value) loading,
    required TResult Function(_BalancesSuccess value) success,
    required TResult Function(_BalancesError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalancesInitial value)? initial,
    TResult? Function(_BalancesLoading value)? loading,
    TResult? Function(_BalancesSuccess value)? success,
    TResult? Function(_BalancesError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalancesInitial value)? initial,
    TResult Function(_BalancesLoading value)? loading,
    TResult Function(_BalancesSuccess value)? success,
    TResult Function(_BalancesError value)? error,
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

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BalancesInitialImplCopyWith<$Res> {
  factory _$$BalancesInitialImplCopyWith(_$BalancesInitialImpl value,
          $Res Function(_$BalancesInitialImpl) then) =
      __$$BalancesInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BalancesInitialImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalancesInitialImpl>
    implements _$$BalancesInitialImplCopyWith<$Res> {
  __$$BalancesInitialImplCopyWithImpl(
      _$BalancesInitialImpl _value, $Res Function(_$BalancesInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BalancesInitialImpl implements _BalancesInitial {
  const _$BalancesInitialImpl();

  @override
  String toString() {
    return 'BalancesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BalancesInitialImpl);
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
    required TResult Function(_BalancesInitial value) initial,
    required TResult Function(_BalancesLoading value) loading,
    required TResult Function(_BalancesSuccess value) success,
    required TResult Function(_BalancesError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalancesInitial value)? initial,
    TResult? Function(_BalancesLoading value)? loading,
    TResult? Function(_BalancesSuccess value)? success,
    TResult? Function(_BalancesError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalancesInitial value)? initial,
    TResult Function(_BalancesLoading value)? loading,
    TResult Function(_BalancesSuccess value)? success,
    TResult Function(_BalancesError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _BalancesInitial implements BalancesState {
  const factory _BalancesInitial() = _$BalancesInitialImpl;
}

/// @nodoc
abstract class _$$BalancesLoadingImplCopyWith<$Res> {
  factory _$$BalancesLoadingImplCopyWith(_$BalancesLoadingImpl value,
          $Res Function(_$BalancesLoadingImpl) then) =
      __$$BalancesLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BalancesLoadingImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalancesLoadingImpl>
    implements _$$BalancesLoadingImplCopyWith<$Res> {
  __$$BalancesLoadingImplCopyWithImpl(
      _$BalancesLoadingImpl _value, $Res Function(_$BalancesLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BalancesLoadingImpl implements _BalancesLoading {
  const _$BalancesLoadingImpl();

  @override
  String toString() {
    return 'BalancesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BalancesLoadingImpl);
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
    required TResult Function(_BalancesInitial value) initial,
    required TResult Function(_BalancesLoading value) loading,
    required TResult Function(_BalancesSuccess value) success,
    required TResult Function(_BalancesError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalancesInitial value)? initial,
    TResult? Function(_BalancesLoading value)? loading,
    TResult? Function(_BalancesSuccess value)? success,
    TResult? Function(_BalancesError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalancesInitial value)? initial,
    TResult Function(_BalancesLoading value)? loading,
    TResult Function(_BalancesSuccess value)? success,
    TResult Function(_BalancesError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _BalancesLoading implements BalancesState {
  const factory _BalancesLoading() = _$BalancesLoadingImpl;
}

/// @nodoc
abstract class _$$BalancesSuccessImplCopyWith<$Res> {
  factory _$$BalancesSuccessImplCopyWith(_$BalancesSuccessImpl value,
          $Res Function(_$BalancesSuccessImpl) then) =
      __$$BalancesSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Balance> balances});
}

/// @nodoc
class __$$BalancesSuccessImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalancesSuccessImpl>
    implements _$$BalancesSuccessImplCopyWith<$Res> {
  __$$BalancesSuccessImplCopyWithImpl(
      _$BalancesSuccessImpl _value, $Res Function(_$BalancesSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balances = null,
  }) {
    return _then(_$BalancesSuccessImpl(
      null == balances
          ? _value._balances
          : balances // ignore: cast_nullable_to_non_nullable
              as List<Balance>,
    ));
  }
}

/// @nodoc

class _$BalancesSuccessImpl implements _BalancesSuccess {
  const _$BalancesSuccessImpl(final List<Balance> balances)
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
            other is _$BalancesSuccessImpl &&
            const DeepCollectionEquality().equals(other._balances, _balances));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_balances));

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalancesSuccessImplCopyWith<_$BalancesSuccessImpl> get copyWith =>
      __$$BalancesSuccessImplCopyWithImpl<_$BalancesSuccessImpl>(
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
    required TResult Function(_BalancesInitial value) initial,
    required TResult Function(_BalancesLoading value) loading,
    required TResult Function(_BalancesSuccess value) success,
    required TResult Function(_BalancesError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalancesInitial value)? initial,
    TResult? Function(_BalancesLoading value)? loading,
    TResult? Function(_BalancesSuccess value)? success,
    TResult? Function(_BalancesError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalancesInitial value)? initial,
    TResult Function(_BalancesLoading value)? loading,
    TResult Function(_BalancesSuccess value)? success,
    TResult Function(_BalancesError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _BalancesSuccess implements BalancesState {
  const factory _BalancesSuccess(final List<Balance> balances) =
      _$BalancesSuccessImpl;

  List<Balance> get balances;

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalancesSuccessImplCopyWith<_$BalancesSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BalancesErrorImplCopyWith<$Res> {
  factory _$$BalancesErrorImplCopyWith(
          _$BalancesErrorImpl value, $Res Function(_$BalancesErrorImpl) then) =
      __$$BalancesErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$BalancesErrorImplCopyWithImpl<$Res>
    extends _$BalancesStateCopyWithImpl<$Res, _$BalancesErrorImpl>
    implements _$$BalancesErrorImplCopyWith<$Res> {
  __$$BalancesErrorImplCopyWithImpl(
      _$BalancesErrorImpl _value, $Res Function(_$BalancesErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$BalancesErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BalancesErrorImpl implements _BalancesError {
  const _$BalancesErrorImpl(this.error);

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
            other is _$BalancesErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalancesErrorImplCopyWith<_$BalancesErrorImpl> get copyWith =>
      __$$BalancesErrorImplCopyWithImpl<_$BalancesErrorImpl>(this, _$identity);

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
    required TResult Function(_BalancesInitial value) initial,
    required TResult Function(_BalancesLoading value) loading,
    required TResult Function(_BalancesSuccess value) success,
    required TResult Function(_BalancesError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BalancesInitial value)? initial,
    TResult? Function(_BalancesLoading value)? loading,
    TResult? Function(_BalancesSuccess value)? success,
    TResult? Function(_BalancesError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BalancesInitial value)? initial,
    TResult Function(_BalancesLoading value)? loading,
    TResult Function(_BalancesSuccess value)? success,
    TResult Function(_BalancesError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _BalancesError implements BalancesState {
  const factory _BalancesError(final String error) = _$BalancesErrorImpl;

  String get error;

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalancesErrorImplCopyWith<_$BalancesErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
