// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_send_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeSendState {
  dynamic get balancesState => throw _privateConstructorUsedError;
  dynamic get submitState => throw _privateConstructorUsedError;
  dynamic get feeState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeSendStateCopyWith<ComposeSendState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeSendStateCopyWith<$Res> {
  factory $ComposeSendStateCopyWith(
          ComposeSendState value, $Res Function(ComposeSendState) then) =
      _$ComposeSendStateCopyWithImpl<$Res, ComposeSendState>;
  @useResult
  $Res call({dynamic balancesState, dynamic submitState, dynamic feeState});
}

/// @nodoc
class _$ComposeSendStateCopyWithImpl<$Res, $Val extends ComposeSendState>
    implements $ComposeSendStateCopyWith<$Res> {
  _$ComposeSendStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balancesState = freezed,
    Object? submitState = freezed,
    Object? feeState = freezed,
  }) {
    return _then(_value.copyWith(
      balancesState: freezed == balancesState
          ? _value.balancesState
          : balancesState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      submitState: freezed == submitState
          ? _value.submitState
          : submitState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      feeState: freezed == feeState
          ? _value.feeState
          : feeState // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComposeSendStateImplCopyWith<$Res>
    implements $ComposeSendStateCopyWith<$Res> {
  factory _$$ComposeSendStateImplCopyWith(_$ComposeSendStateImpl value,
          $Res Function(_$ComposeSendStateImpl) then) =
      __$$ComposeSendStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic balancesState, dynamic submitState, dynamic feeState});
}

/// @nodoc
class __$$ComposeSendStateImplCopyWithImpl<$Res>
    extends _$ComposeSendStateCopyWithImpl<$Res, _$ComposeSendStateImpl>
    implements _$$ComposeSendStateImplCopyWith<$Res> {
  __$$ComposeSendStateImplCopyWithImpl(_$ComposeSendStateImpl _value,
      $Res Function(_$ComposeSendStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balancesState = freezed,
    Object? submitState = freezed,
    Object? feeState = freezed,
  }) {
    return _then(_$ComposeSendStateImpl(
      balancesState:
          freezed == balancesState ? _value.balancesState! : balancesState,
      submitState: freezed == submitState ? _value.submitState! : submitState,
      feeState: freezed == feeState ? _value.feeState! : feeState,
    ));
  }
}

/// @nodoc

class _$ComposeSendStateImpl implements _ComposeSendState {
  const _$ComposeSendStateImpl(
      {this.balancesState = const BalancesState.initial(),
      this.submitState = const SubmitState.initial(),
      this.feeState = const FeeState.initial()});

  @override
  @JsonKey()
  final dynamic balancesState;
  @override
  @JsonKey()
  final dynamic submitState;
  @override
  @JsonKey()
  final dynamic feeState;

  @override
  String toString() {
    return 'ComposeSendState(balancesState: $balancesState, submitState: $submitState, feeState: $feeState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeSendStateImpl &&
            const DeepCollectionEquality()
                .equals(other.balancesState, balancesState) &&
            const DeepCollectionEquality()
                .equals(other.submitState, submitState) &&
            const DeepCollectionEquality().equals(other.feeState, feeState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(balancesState),
      const DeepCollectionEquality().hash(submitState),
      const DeepCollectionEquality().hash(feeState));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeSendStateImplCopyWith<_$ComposeSendStateImpl> get copyWith =>
      __$$ComposeSendStateImplCopyWithImpl<_$ComposeSendStateImpl>(
          this, _$identity);
}

abstract class _ComposeSendState implements ComposeSendState {
  const factory _ComposeSendState(
      {final dynamic balancesState,
      final dynamic submitState,
      final dynamic feeState}) = _$ComposeSendStateImpl;

  @override
  dynamic get balancesState;
  @override
  dynamic get submitState;
  @override
  dynamic get feeState;
  @override
  @JsonKey(ignore: true)
  _$$ComposeSendStateImplCopyWith<_$ComposeSendStateImpl> get copyWith =>
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
mixin _$SubmitState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitStateCopyWith<$Res> {
  factory $SubmitStateCopyWith(
          SubmitState value, $Res Function(SubmitState) then) =
      _$SubmitStateCopyWithImpl<$Res, SubmitState>;
}

/// @nodoc
class _$SubmitStateCopyWithImpl<$Res, $Val extends SubmitState>
    implements $SubmitStateCopyWith<$Res> {
  _$SubmitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SubmitInitialImplCopyWith<$Res> {
  factory _$$SubmitInitialImplCopyWith(
          _$SubmitInitialImpl value, $Res Function(_$SubmitInitialImpl) then) =
      __$$SubmitInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubmitInitialImplCopyWithImpl<$Res>
    extends _$SubmitStateCopyWithImpl<$Res, _$SubmitInitialImpl>
    implements _$$SubmitInitialImplCopyWith<$Res> {
  __$$SubmitInitialImplCopyWithImpl(
      _$SubmitInitialImpl _value, $Res Function(_$SubmitInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SubmitInitialImpl implements _SubmitInitial {
  const _$SubmitInitialImpl();

  @override
  String toString() {
    return 'SubmitState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SubmitInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
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
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _SubmitInitial implements SubmitState {
  const factory _SubmitInitial() = _$SubmitInitialImpl;
}

/// @nodoc
abstract class _$$SubmitLoadingImplCopyWith<$Res> {
  factory _$$SubmitLoadingImplCopyWith(
          _$SubmitLoadingImpl value, $Res Function(_$SubmitLoadingImpl) then) =
      __$$SubmitLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubmitLoadingImplCopyWithImpl<$Res>
    extends _$SubmitStateCopyWithImpl<$Res, _$SubmitLoadingImpl>
    implements _$$SubmitLoadingImplCopyWith<$Res> {
  __$$SubmitLoadingImplCopyWithImpl(
      _$SubmitLoadingImpl _value, $Res Function(_$SubmitLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SubmitLoadingImpl implements _SubmitLoading {
  const _$SubmitLoadingImpl();

  @override
  String toString() {
    return 'SubmitState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SubmitLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
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
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _SubmitLoading implements SubmitState {
  const factory _SubmitLoading() = _$SubmitLoadingImpl;
}

/// @nodoc
abstract class _$$SubmitComposingImplCopyWith<$Res> {
  factory _$$SubmitComposingImplCopyWith(_$SubmitComposingImpl value,
          $Res Function(_$SubmitComposingImpl) then) =
      __$$SubmitComposingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SubmitStateComposingSend submitStateComposingSend});
}

/// @nodoc
class __$$SubmitComposingImplCopyWithImpl<$Res>
    extends _$SubmitStateCopyWithImpl<$Res, _$SubmitComposingImpl>
    implements _$$SubmitComposingImplCopyWith<$Res> {
  __$$SubmitComposingImplCopyWithImpl(
      _$SubmitComposingImpl _value, $Res Function(_$SubmitComposingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? submitStateComposingSend = null,
  }) {
    return _then(_$SubmitComposingImpl(
      null == submitStateComposingSend
          ? _value.submitStateComposingSend
          : submitStateComposingSend // ignore: cast_nullable_to_non_nullable
              as SubmitStateComposingSend,
    ));
  }
}

/// @nodoc

class _$SubmitComposingImpl implements _SubmitComposing {
  const _$SubmitComposingImpl(this.submitStateComposingSend);

  @override
  final SubmitStateComposingSend submitStateComposingSend;

  @override
  String toString() {
    return 'SubmitState.composing(submitStateComposingSend: $submitStateComposingSend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitComposingImpl &&
            (identical(
                    other.submitStateComposingSend, submitStateComposingSend) ||
                other.submitStateComposingSend == submitStateComposingSend));
  }

  @override
  int get hashCode => Object.hash(runtimeType, submitStateComposingSend);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitComposingImplCopyWith<_$SubmitComposingImpl> get copyWith =>
      __$$SubmitComposingImplCopyWithImpl<_$SubmitComposingImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) {
    return composing(submitStateComposingSend);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) {
    return composing?.call(submitStateComposingSend);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (composing != null) {
      return composing(submitStateComposingSend);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) {
    return composing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) {
    return composing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) {
    if (composing != null) {
      return composing(this);
    }
    return orElse();
  }
}

abstract class _SubmitComposing implements SubmitState {
  const factory _SubmitComposing(
          final SubmitStateComposingSend submitStateComposingSend) =
      _$SubmitComposingImpl;

  SubmitStateComposingSend get submitStateComposingSend;
  @JsonKey(ignore: true)
  _$$SubmitComposingImplCopyWith<_$SubmitComposingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubmitFinalizingImplCopyWith<$Res> {
  factory _$$SubmitFinalizingImplCopyWith(_$SubmitFinalizingImpl value,
          $Res Function(_$SubmitFinalizingImpl) then) =
      __$$SubmitFinalizingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SubmitStateFinalizing submitStateFinalizing});
}

/// @nodoc
class __$$SubmitFinalizingImplCopyWithImpl<$Res>
    extends _$SubmitStateCopyWithImpl<$Res, _$SubmitFinalizingImpl>
    implements _$$SubmitFinalizingImplCopyWith<$Res> {
  __$$SubmitFinalizingImplCopyWithImpl(_$SubmitFinalizingImpl _value,
      $Res Function(_$SubmitFinalizingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? submitStateFinalizing = null,
  }) {
    return _then(_$SubmitFinalizingImpl(
      null == submitStateFinalizing
          ? _value.submitStateFinalizing
          : submitStateFinalizing // ignore: cast_nullable_to_non_nullable
              as SubmitStateFinalizing,
    ));
  }
}

/// @nodoc

class _$SubmitFinalizingImpl implements _SubmitFinalizing {
  const _$SubmitFinalizingImpl(this.submitStateFinalizing);

  @override
  final SubmitStateFinalizing submitStateFinalizing;

  @override
  String toString() {
    return 'SubmitState.finalizing(submitStateFinalizing: $submitStateFinalizing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitFinalizingImpl &&
            (identical(other.submitStateFinalizing, submitStateFinalizing) ||
                other.submitStateFinalizing == submitStateFinalizing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, submitStateFinalizing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitFinalizingImplCopyWith<_$SubmitFinalizingImpl> get copyWith =>
      __$$SubmitFinalizingImplCopyWithImpl<_$SubmitFinalizingImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) {
    return finalizing(submitStateFinalizing);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) {
    return finalizing?.call(submitStateFinalizing);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (finalizing != null) {
      return finalizing(submitStateFinalizing);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) {
    return finalizing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) {
    return finalizing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) {
    if (finalizing != null) {
      return finalizing(this);
    }
    return orElse();
  }
}

abstract class _SubmitFinalizing implements SubmitState {
  const factory _SubmitFinalizing(
          final SubmitStateFinalizing submitStateFinalizing) =
      _$SubmitFinalizingImpl;

  SubmitStateFinalizing get submitStateFinalizing;
  @JsonKey(ignore: true)
  _$$SubmitFinalizingImplCopyWith<_$SubmitFinalizingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubmitSuccessImplCopyWith<$Res> {
  factory _$$SubmitSuccessImplCopyWith(
          _$SubmitSuccessImpl value, $Res Function(_$SubmitSuccessImpl) then) =
      __$$SubmitSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String transactionHex, String sourceAddress});
}

/// @nodoc
class __$$SubmitSuccessImplCopyWithImpl<$Res>
    extends _$SubmitStateCopyWithImpl<$Res, _$SubmitSuccessImpl>
    implements _$$SubmitSuccessImplCopyWith<$Res> {
  __$$SubmitSuccessImplCopyWithImpl(
      _$SubmitSuccessImpl _value, $Res Function(_$SubmitSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionHex = null,
    Object? sourceAddress = null,
  }) {
    return _then(_$SubmitSuccessImpl(
      null == transactionHex
          ? _value.transactionHex
          : transactionHex // ignore: cast_nullable_to_non_nullable
              as String,
      null == sourceAddress
          ? _value.sourceAddress
          : sourceAddress // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SubmitSuccessImpl implements _SubmitSuccess {
  const _$SubmitSuccessImpl(this.transactionHex, this.sourceAddress);

  @override
  final String transactionHex;
  @override
  final String sourceAddress;

  @override
  String toString() {
    return 'SubmitState.success(transactionHex: $transactionHex, sourceAddress: $sourceAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitSuccessImpl &&
            (identical(other.transactionHex, transactionHex) ||
                other.transactionHex == transactionHex) &&
            (identical(other.sourceAddress, sourceAddress) ||
                other.sourceAddress == sourceAddress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, transactionHex, sourceAddress);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitSuccessImplCopyWith<_$SubmitSuccessImpl> get copyWith =>
      __$$SubmitSuccessImplCopyWithImpl<_$SubmitSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) {
    return success(transactionHex, sourceAddress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(transactionHex, sourceAddress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(transactionHex, sourceAddress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _SubmitSuccess implements SubmitState {
  const factory _SubmitSuccess(
          final String transactionHex, final String sourceAddress) =
      _$SubmitSuccessImpl;

  String get transactionHex;
  String get sourceAddress;
  @JsonKey(ignore: true)
  _$$SubmitSuccessImplCopyWith<_$SubmitSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubmitErrorImplCopyWith<$Res> {
  factory _$$SubmitErrorImplCopyWith(
          _$SubmitErrorImpl value, $Res Function(_$SubmitErrorImpl) then) =
      __$$SubmitErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$SubmitErrorImplCopyWithImpl<$Res>
    extends _$SubmitStateCopyWithImpl<$Res, _$SubmitErrorImpl>
    implements _$$SubmitErrorImplCopyWith<$Res> {
  __$$SubmitErrorImplCopyWithImpl(
      _$SubmitErrorImpl _value, $Res Function(_$SubmitErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$SubmitErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SubmitErrorImpl implements _SubmitError {
  const _$SubmitErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'SubmitState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitErrorImplCopyWith<_$SubmitErrorImpl> get copyWith =>
      __$$SubmitErrorImplCopyWithImpl<_$SubmitErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SubmitStateComposingSend submitStateComposingSend)
        composing,
    required TResult Function(SubmitStateFinalizing submitStateFinalizing)
        finalizing,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult? Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SubmitStateComposingSend submitStateComposingSend)?
        composing,
    TResult Function(SubmitStateFinalizing submitStateFinalizing)? finalizing,
    TResult Function(String transactionHex, String sourceAddress)? success,
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
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitComposing value) composing,
    required TResult Function(_SubmitFinalizing value) finalizing,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitComposing value)? composing,
    TResult? Function(_SubmitFinalizing value)? finalizing,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
    TResult Function(_SubmitComposing value)? composing,
    TResult Function(_SubmitFinalizing value)? finalizing,
    TResult Function(_SubmitSuccess value)? success,
    TResult Function(_SubmitError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _SubmitError implements SubmitState {
  const factory _SubmitError(final String error) = _$SubmitErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$SubmitErrorImplCopyWith<_$SubmitErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
