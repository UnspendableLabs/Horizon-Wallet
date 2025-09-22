// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_base_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeeState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is FeeState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FeeState()';
  }
}

/// @nodoc
class $FeeStateCopyWith<$Res> {
  $FeeStateCopyWith(FeeState _, $Res Function(FeeState) __);
}

/// @nodoc

class _FeeInitial implements FeeState {
  const _FeeInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _FeeInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FeeState.initial()';
  }
}

/// @nodoc

class _FeeLoading implements FeeState {
  const _FeeLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _FeeLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FeeState.loading()';
  }
}

/// @nodoc

class _FeeSuccess implements FeeState {
  const _FeeSuccess(this.feeEstimates);

  final FeeEstimates feeEstimates;

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FeeSuccessCopyWith<_FeeSuccess> get copyWith =>
      __$FeeSuccessCopyWithImpl<_FeeSuccess>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FeeSuccess &&
            (identical(other.feeEstimates, feeEstimates) ||
                other.feeEstimates == feeEstimates));
  }

  @override
  int get hashCode => Object.hash(runtimeType, feeEstimates);

  @override
  String toString() {
    return 'FeeState.success(feeEstimates: $feeEstimates)';
  }
}

/// @nodoc
abstract mixin class _$FeeSuccessCopyWith<$Res>
    implements $FeeStateCopyWith<$Res> {
  factory _$FeeSuccessCopyWith(
          _FeeSuccess value, $Res Function(_FeeSuccess) _then) =
      __$FeeSuccessCopyWithImpl;
  @useResult
  $Res call({FeeEstimates feeEstimates});
}

/// @nodoc
class __$FeeSuccessCopyWithImpl<$Res> implements _$FeeSuccessCopyWith<$Res> {
  __$FeeSuccessCopyWithImpl(this._self, this._then);

  final _FeeSuccess _self;
  final $Res Function(_FeeSuccess) _then;

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? feeEstimates = null,
  }) {
    return _then(_FeeSuccess(
      null == feeEstimates
          ? _self.feeEstimates
          : feeEstimates // ignore: cast_nullable_to_non_nullable
              as FeeEstimates,
    ));
  }
}

/// @nodoc

class _FeeError implements FeeState {
  const _FeeError(this.error);

  final String error;

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FeeErrorCopyWith<_FeeError> get copyWith =>
      __$FeeErrorCopyWithImpl<_FeeError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FeeError &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'FeeState.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class _$FeeErrorCopyWith<$Res>
    implements $FeeStateCopyWith<$Res> {
  factory _$FeeErrorCopyWith(_FeeError value, $Res Function(_FeeError) _then) =
      __$FeeErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$FeeErrorCopyWithImpl<$Res> implements _$FeeErrorCopyWith<$Res> {
  __$FeeErrorCopyWithImpl(this._self, this._then);

  final _FeeError _self;
  final $Res Function(_FeeError) _then;

  /// Create a copy of FeeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(_FeeError(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$BalancesState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is BalancesState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'BalancesState()';
  }
}

/// @nodoc
class $BalancesStateCopyWith<$Res> {
  $BalancesStateCopyWith(BalancesState _, $Res Function(BalancesState) __);
}

/// @nodoc

class _BalancesInitial implements BalancesState {
  const _BalancesInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _BalancesInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'BalancesState.initial()';
  }
}

/// @nodoc

class _BalancesLoading implements BalancesState {
  const _BalancesLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _BalancesLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'BalancesState.loading()';
  }
}

/// @nodoc

class _BalancesSuccess implements BalancesState {
  const _BalancesSuccess(final List<Balance> balances) : _balances = balances;

  final List<Balance> _balances;
  List<Balance> get balances {
    if (_balances is EqualUnmodifiableListView) return _balances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_balances);
  }

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BalancesSuccessCopyWith<_BalancesSuccess> get copyWith =>
      __$BalancesSuccessCopyWithImpl<_BalancesSuccess>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BalancesSuccess &&
            const DeepCollectionEquality().equals(other._balances, _balances));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_balances));

  @override
  String toString() {
    return 'BalancesState.success(balances: $balances)';
  }
}

/// @nodoc
abstract mixin class _$BalancesSuccessCopyWith<$Res>
    implements $BalancesStateCopyWith<$Res> {
  factory _$BalancesSuccessCopyWith(
          _BalancesSuccess value, $Res Function(_BalancesSuccess) _then) =
      __$BalancesSuccessCopyWithImpl;
  @useResult
  $Res call({List<Balance> balances});
}

/// @nodoc
class __$BalancesSuccessCopyWithImpl<$Res>
    implements _$BalancesSuccessCopyWith<$Res> {
  __$BalancesSuccessCopyWithImpl(this._self, this._then);

  final _BalancesSuccess _self;
  final $Res Function(_BalancesSuccess) _then;

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? balances = null,
  }) {
    return _then(_BalancesSuccess(
      null == balances
          ? _self._balances
          : balances // ignore: cast_nullable_to_non_nullable
              as List<Balance>,
    ));
  }
}

/// @nodoc

class _BalancesError implements BalancesState {
  const _BalancesError(this.error);

  final String error;

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BalancesErrorCopyWith<_BalancesError> get copyWith =>
      __$BalancesErrorCopyWithImpl<_BalancesError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BalancesError &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'BalancesState.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class _$BalancesErrorCopyWith<$Res>
    implements $BalancesStateCopyWith<$Res> {
  factory _$BalancesErrorCopyWith(
          _BalancesError value, $Res Function(_BalancesError) _then) =
      __$BalancesErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$BalancesErrorCopyWithImpl<$Res>
    implements _$BalancesErrorCopyWith<$Res> {
  __$BalancesErrorCopyWithImpl(this._self, this._then);

  final _BalancesError _self;
  final $Res Function(_BalancesError) _then;

  /// Create a copy of BalancesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(_BalancesError(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
