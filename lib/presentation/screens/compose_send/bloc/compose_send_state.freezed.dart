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
  dynamic get addressesState => throw _privateConstructorUsedError;
  dynamic get balancesState => throw _privateConstructorUsedError;
  dynamic get submitState => throw _privateConstructorUsedError;

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
  $Res call(
      {dynamic addressesState, dynamic balancesState, dynamic submitState});
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
    Object? addressesState = freezed,
    Object? balancesState = freezed,
    Object? submitState = freezed,
  }) {
    return _then(_value.copyWith(
      addressesState: freezed == addressesState
          ? _value.addressesState
          : addressesState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      balancesState: freezed == balancesState
          ? _value.balancesState
          : balancesState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      submitState: freezed == submitState
          ? _value.submitState
          : submitState // ignore: cast_nullable_to_non_nullable
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
  $Res call(
      {dynamic addressesState, dynamic balancesState, dynamic submitState});
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
    Object? addressesState = freezed,
    Object? balancesState = freezed,
    Object? submitState = freezed,
  }) {
    return _then(_$ComposeSendStateImpl(
      addressesState:
          freezed == addressesState ? _value.addressesState! : addressesState,
      balancesState:
          freezed == balancesState ? _value.balancesState! : balancesState,
      submitState: freezed == submitState ? _value.submitState! : submitState,
    ));
  }
}

/// @nodoc

class _$ComposeSendStateImpl implements _ComposeSendState {
  const _$ComposeSendStateImpl(
      {this.addressesState = const AddressesState.initial(),
      this.balancesState = const BalancesState.initial(),
      this.submitState = const SubmitState.initial()});

  @override
  @JsonKey()
  final dynamic addressesState;
  @override
  @JsonKey()
  final dynamic balancesState;
  @override
  @JsonKey()
  final dynamic submitState;

  @override
  String toString() {
    return 'ComposeSendState(addressesState: $addressesState, balancesState: $balancesState, submitState: $submitState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeSendStateImpl &&
            const DeepCollectionEquality()
                .equals(other.addressesState, addressesState) &&
            const DeepCollectionEquality()
                .equals(other.balancesState, balancesState) &&
            const DeepCollectionEquality()
                .equals(other.submitState, submitState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(addressesState),
      const DeepCollectionEquality().hash(balancesState),
      const DeepCollectionEquality().hash(submitState));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeSendStateImplCopyWith<_$ComposeSendStateImpl> get copyWith =>
      __$$ComposeSendStateImplCopyWithImpl<_$ComposeSendStateImpl>(
          this, _$identity);
}

abstract class _ComposeSendState implements ComposeSendState {
  const factory _ComposeSendState(
      {final dynamic addressesState,
      final dynamic balancesState,
      final dynamic submitState}) = _$ComposeSendStateImpl;

  @override
  dynamic get addressesState;
  @override
  dynamic get balancesState;
  @override
  dynamic get submitState;
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
mixin _$AddressesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(dynamic AddressStateSuccessUnconfirmed)
        confirmation,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressConfirmation value) confirmation,
    required TResult Function(_AddressError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressConfirmation value)? confirmation,
    TResult? Function(_AddressError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressConfirmation value)? confirmation,
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
    required TResult Function(dynamic AddressStateSuccessUnconfirmed)
        confirmation,
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
    TResult? Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    TResult Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    required TResult Function(_AddressConfirmation value) confirmation,
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
    TResult? Function(_AddressConfirmation value)? confirmation,
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
    TResult Function(_AddressConfirmation value)? confirmation,
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
    required TResult Function(dynamic AddressStateSuccessUnconfirmed)
        confirmation,
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
    TResult? Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    TResult Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    required TResult Function(_AddressConfirmation value) confirmation,
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
    TResult? Function(_AddressConfirmation value)? confirmation,
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
    TResult Function(_AddressConfirmation value)? confirmation,
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
    required TResult Function(dynamic AddressStateSuccessUnconfirmed)
        confirmation,
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
    TResult? Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    TResult Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    required TResult Function(_AddressConfirmation value) confirmation,
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
    TResult? Function(_AddressConfirmation value)? confirmation,
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
    TResult Function(_AddressConfirmation value)? confirmation,
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
abstract class _$$AddressConfirmationImplCopyWith<$Res> {
  factory _$$AddressConfirmationImplCopyWith(_$AddressConfirmationImpl value,
          $Res Function(_$AddressConfirmationImpl) then) =
      __$$AddressConfirmationImplCopyWithImpl<$Res>;
  @useResult
  $Res call({dynamic AddressStateSuccessUnconfirmed});
}

/// @nodoc
class __$$AddressConfirmationImplCopyWithImpl<$Res>
    extends _$AddressesStateCopyWithImpl<$Res, _$AddressConfirmationImpl>
    implements _$$AddressConfirmationImplCopyWith<$Res> {
  __$$AddressConfirmationImplCopyWithImpl(_$AddressConfirmationImpl _value,
      $Res Function(_$AddressConfirmationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? AddressStateSuccessUnconfirmed = freezed,
  }) {
    return _then(_$AddressConfirmationImpl(
      freezed == AddressStateSuccessUnconfirmed
          ? _value.AddressStateSuccessUnconfirmed!
          : AddressStateSuccessUnconfirmed,
    ));
  }
}

/// @nodoc

class _$AddressConfirmationImpl implements _AddressConfirmation {
  const _$AddressConfirmationImpl(this.AddressStateSuccessUnconfirmed);

  @override
  final dynamic AddressStateSuccessUnconfirmed;

  @override
  String toString() {
    return 'AddressesState.confirmation(AddressStateSuccessUnconfirmed: $AddressStateSuccessUnconfirmed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressConfirmationImpl &&
            const DeepCollectionEquality().equals(
                other.AddressStateSuccessUnconfirmed,
                AddressStateSuccessUnconfirmed));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(AddressStateSuccessUnconfirmed));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressConfirmationImplCopyWith<_$AddressConfirmationImpl> get copyWith =>
      __$$AddressConfirmationImplCopyWithImpl<_$AddressConfirmationImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Address> addresses) success,
    required TResult Function(dynamic AddressStateSuccessUnconfirmed)
        confirmation,
    required TResult Function(String error) error,
  }) {
    return confirmation(AddressStateSuccessUnconfirmed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Address> addresses)? success,
    TResult? Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
    TResult? Function(String error)? error,
  }) {
    return confirmation?.call(AddressStateSuccessUnconfirmed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Address> addresses)? success,
    TResult Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (confirmation != null) {
      return confirmation(AddressStateSuccessUnconfirmed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AddressInitial value) initial,
    required TResult Function(_AddressLoading value) loading,
    required TResult Function(_AddressSuccess value) success,
    required TResult Function(_AddressConfirmation value) confirmation,
    required TResult Function(_AddressError value) error,
  }) {
    return confirmation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddressInitial value)? initial,
    TResult? Function(_AddressLoading value)? loading,
    TResult? Function(_AddressSuccess value)? success,
    TResult? Function(_AddressConfirmation value)? confirmation,
    TResult? Function(_AddressError value)? error,
  }) {
    return confirmation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddressInitial value)? initial,
    TResult Function(_AddressLoading value)? loading,
    TResult Function(_AddressSuccess value)? success,
    TResult Function(_AddressConfirmation value)? confirmation,
    TResult Function(_AddressError value)? error,
    required TResult orElse(),
  }) {
    if (confirmation != null) {
      return confirmation(this);
    }
    return orElse();
  }
}

abstract class _AddressConfirmation implements AddressesState {
  const factory _AddressConfirmation(
      final dynamic AddressStateSuccessUnconfirmed) = _$AddressConfirmationImpl;

  dynamic get AddressStateSuccessUnconfirmed;
  @JsonKey(ignore: true)
  _$$AddressConfirmationImplCopyWith<_$AddressConfirmationImpl> get copyWith =>
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
    required TResult Function(dynamic AddressStateSuccessUnconfirmed)
        confirmation,
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
    TResult? Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    TResult Function(dynamic AddressStateSuccessUnconfirmed)? confirmation,
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
    required TResult Function(_AddressConfirmation value) confirmation,
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
    TResult? Function(_AddressConfirmation value)? confirmation,
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
    TResult Function(_AddressConfirmation value)? confirmation,
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
mixin _$SubmitState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String transactionHex, String sourceAddress)
        success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String transactionHex, String sourceAddress)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String transactionHex, String sourceAddress)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubmitInitial value) initial,
    required TResult Function(_SubmitLoading value) loading,
    required TResult Function(_SubmitSuccess value) success,
    required TResult Function(_SubmitError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubmitInitial value)? initial,
    TResult? Function(_SubmitLoading value)? loading,
    TResult? Function(_SubmitSuccess value)? success,
    TResult? Function(_SubmitError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubmitInitial value)? initial,
    TResult Function(_SubmitLoading value)? loading,
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
