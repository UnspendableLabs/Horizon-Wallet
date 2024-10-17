// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_dispense_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeDispenseState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState => throw _privateConstructorUsedError;
  DispensersState get dispensersState =>
      throw _privateConstructorUsedError; // Specific properties
  Address? get source => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  String? get asset => throw _privateConstructorUsedError;
  String get quantity => throw _privateConstructorUsedError;
  String? get composeDispenseError => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeDispenseStateCopyWith<ComposeDispenseState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeDispenseStateCopyWith<$Res> {
  factory $ComposeDispenseStateCopyWith(ComposeDispenseState value,
          $Res Function(ComposeDispenseState) then) =
      _$ComposeDispenseStateCopyWithImpl<$Res, ComposeDispenseState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      DispensersState dispensersState,
      Address? source,
      String? destination,
      String? asset,
      String quantity,
      String? composeDispenseError});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
  $DispensersStateCopyWith<$Res> get dispensersState;
}

/// @nodoc
class _$ComposeDispenseStateCopyWithImpl<$Res,
        $Val extends ComposeDispenseState>
    implements $ComposeDispenseStateCopyWith<$Res> {
  _$ComposeDispenseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? dispensersState = null,
    Object? source = freezed,
    Object? destination = freezed,
    Object? asset = freezed,
    Object? quantity = null,
    Object? composeDispenseError = freezed,
  }) {
    return _then(_value.copyWith(
      feeState: null == feeState
          ? _value.feeState
          : feeState // ignore: cast_nullable_to_non_nullable
              as FeeState,
      balancesState: null == balancesState
          ? _value.balancesState
          : balancesState // ignore: cast_nullable_to_non_nullable
              as BalancesState,
      feeOption: null == feeOption
          ? _value.feeOption
          : feeOption // ignore: cast_nullable_to_non_nullable
              as FeeOption,
      submitState: null == submitState
          ? _value.submitState
          : submitState // ignore: cast_nullable_to_non_nullable
              as SubmitState,
      dispensersState: null == dispensersState
          ? _value.dispensersState
          : dispensersState // ignore: cast_nullable_to_non_nullable
              as DispensersState,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as Address?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      composeDispenseError: freezed == composeDispenseError
          ? _value.composeDispenseError
          : composeDispenseError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FeeStateCopyWith<$Res> get feeState {
    return $FeeStateCopyWith<$Res>(_value.feeState, (value) {
      return _then(_value.copyWith(feeState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BalancesStateCopyWith<$Res> get balancesState {
    return $BalancesStateCopyWith<$Res>(_value.balancesState, (value) {
      return _then(_value.copyWith(balancesState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DispensersStateCopyWith<$Res> get dispensersState {
    return $DispensersStateCopyWith<$Res>(_value.dispensersState, (value) {
      return _then(_value.copyWith(dispensersState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComposeDispenseStateImplCopyWith<$Res>
    implements $ComposeDispenseStateCopyWith<$Res> {
  factory _$$ComposeDispenseStateImplCopyWith(_$ComposeDispenseStateImpl value,
          $Res Function(_$ComposeDispenseStateImpl) then) =
      __$$ComposeDispenseStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      DispensersState dispensersState,
      Address? source,
      String? destination,
      String? asset,
      String quantity,
      String? composeDispenseError});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
  @override
  $DispensersStateCopyWith<$Res> get dispensersState;
}

/// @nodoc
class __$$ComposeDispenseStateImplCopyWithImpl<$Res>
    extends _$ComposeDispenseStateCopyWithImpl<$Res, _$ComposeDispenseStateImpl>
    implements _$$ComposeDispenseStateImplCopyWith<$Res> {
  __$$ComposeDispenseStateImplCopyWithImpl(_$ComposeDispenseStateImpl _value,
      $Res Function(_$ComposeDispenseStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? dispensersState = null,
    Object? source = freezed,
    Object? destination = freezed,
    Object? asset = freezed,
    Object? quantity = null,
    Object? composeDispenseError = freezed,
  }) {
    return _then(_$ComposeDispenseStateImpl(
      feeState: null == feeState
          ? _value.feeState
          : feeState // ignore: cast_nullable_to_non_nullable
              as FeeState,
      balancesState: null == balancesState
          ? _value.balancesState
          : balancesState // ignore: cast_nullable_to_non_nullable
              as BalancesState,
      feeOption: null == feeOption
          ? _value.feeOption
          : feeOption // ignore: cast_nullable_to_non_nullable
              as FeeOption,
      submitState: null == submitState
          ? _value.submitState
          : submitState // ignore: cast_nullable_to_non_nullable
              as SubmitState,
      dispensersState: null == dispensersState
          ? _value.dispensersState
          : dispensersState // ignore: cast_nullable_to_non_nullable
              as DispensersState,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as Address?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      composeDispenseError: freezed == composeDispenseError
          ? _value.composeDispenseError
          : composeDispenseError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ComposeDispenseStateImpl extends _ComposeDispenseState {
  const _$ComposeDispenseStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      required this.dispensersState,
      this.source,
      this.destination,
      this.asset,
      required this.quantity,
      this.composeDispenseError})
      : super._();

// Inherited properties
  @override
  final FeeState feeState;
  @override
  final BalancesState balancesState;
  @override
  final FeeOption feeOption;
  @override
  final SubmitState submitState;
  @override
  final DispensersState dispensersState;
// Specific properties
  @override
  final Address? source;
  @override
  final String? destination;
  @override
  final String? asset;
  @override
  final String quantity;
  @override
  final String? composeDispenseError;

  @override
  String toString() {
    return 'ComposeDispenseState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, dispensersState: $dispensersState, source: $source, destination: $destination, asset: $asset, quantity: $quantity, composeDispenseError: $composeDispenseError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeDispenseStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState) &&
            (identical(other.dispensersState, dispensersState) ||
                other.dispensersState == dispensersState) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.asset, asset) || other.asset == asset) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.composeDispenseError, composeDispenseError) ||
                other.composeDispenseError == composeDispenseError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      feeState,
      balancesState,
      feeOption,
      submitState,
      dispensersState,
      source,
      destination,
      asset,
      quantity,
      composeDispenseError);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeDispenseStateImplCopyWith<_$ComposeDispenseStateImpl>
      get copyWith =>
          __$$ComposeDispenseStateImplCopyWithImpl<_$ComposeDispenseStateImpl>(
              this, _$identity);
}

abstract class _ComposeDispenseState extends ComposeDispenseState {
  const factory _ComposeDispenseState(
      {required final FeeState feeState,
      required final BalancesState balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState,
      required final DispensersState dispensersState,
      final Address? source,
      final String? destination,
      final String? asset,
      required final String quantity,
      final String? composeDispenseError}) = _$ComposeDispenseStateImpl;
  const _ComposeDispenseState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override
  DispensersState get dispensersState;
  @override // Specific properties
  Address? get source;
  @override
  String? get destination;
  @override
  String? get asset;
  @override
  String get quantity;
  @override
  String? get composeDispenseError;
  @override
  @JsonKey(ignore: true)
  _$$ComposeDispenseStateImplCopyWith<_$ComposeDispenseStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DispensersState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispensersInitial value) initial,
    required TResult Function(_DispensersLoading value) loading,
    required TResult Function(_DispensersSuccess value) success,
    required TResult Function(_DispensersError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispensersInitial value)? initial,
    TResult? Function(_DispensersLoading value)? loading,
    TResult? Function(_DispensersSuccess value)? success,
    TResult? Function(_DispensersError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispensersInitial value)? initial,
    TResult Function(_DispensersLoading value)? loading,
    TResult Function(_DispensersSuccess value)? success,
    TResult Function(_DispensersError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispensersStateCopyWith<$Res> {
  factory $DispensersStateCopyWith(
          DispensersState value, $Res Function(DispensersState) then) =
      _$DispensersStateCopyWithImpl<$Res, DispensersState>;
}

/// @nodoc
class _$DispensersStateCopyWithImpl<$Res, $Val extends DispensersState>
    implements $DispensersStateCopyWith<$Res> {
  _$DispensersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DispensersInitialImplCopyWith<$Res> {
  factory _$$DispensersInitialImplCopyWith(_$DispensersInitialImpl value,
          $Res Function(_$DispensersInitialImpl) then) =
      __$$DispensersInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispensersInitialImplCopyWithImpl<$Res>
    extends _$DispensersStateCopyWithImpl<$Res, _$DispensersInitialImpl>
    implements _$$DispensersInitialImplCopyWith<$Res> {
  __$$DispensersInitialImplCopyWithImpl(_$DispensersInitialImpl _value,
      $Res Function(_$DispensersInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispensersInitialImpl implements _DispensersInitial {
  const _$DispensersInitialImpl();

  @override
  String toString() {
    return 'DispensersState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DispensersInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
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
    required TResult Function(_DispensersInitial value) initial,
    required TResult Function(_DispensersLoading value) loading,
    required TResult Function(_DispensersSuccess value) success,
    required TResult Function(_DispensersError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispensersInitial value)? initial,
    TResult? Function(_DispensersLoading value)? loading,
    TResult? Function(_DispensersSuccess value)? success,
    TResult? Function(_DispensersError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispensersInitial value)? initial,
    TResult Function(_DispensersLoading value)? loading,
    TResult Function(_DispensersSuccess value)? success,
    TResult Function(_DispensersError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _DispensersInitial implements DispensersState {
  const factory _DispensersInitial() = _$DispensersInitialImpl;
}

/// @nodoc
abstract class _$$DispensersLoadingImplCopyWith<$Res> {
  factory _$$DispensersLoadingImplCopyWith(_$DispensersLoadingImpl value,
          $Res Function(_$DispensersLoadingImpl) then) =
      __$$DispensersLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispensersLoadingImplCopyWithImpl<$Res>
    extends _$DispensersStateCopyWithImpl<$Res, _$DispensersLoadingImpl>
    implements _$$DispensersLoadingImplCopyWith<$Res> {
  __$$DispensersLoadingImplCopyWithImpl(_$DispensersLoadingImpl _value,
      $Res Function(_$DispensersLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispensersLoadingImpl implements _DispensersLoading {
  const _$DispensersLoadingImpl();

  @override
  String toString() {
    return 'DispensersState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DispensersLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
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
    required TResult Function(_DispensersInitial value) initial,
    required TResult Function(_DispensersLoading value) loading,
    required TResult Function(_DispensersSuccess value) success,
    required TResult Function(_DispensersError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispensersInitial value)? initial,
    TResult? Function(_DispensersLoading value)? loading,
    TResult? Function(_DispensersSuccess value)? success,
    TResult? Function(_DispensersError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispensersInitial value)? initial,
    TResult Function(_DispensersLoading value)? loading,
    TResult Function(_DispensersSuccess value)? success,
    TResult Function(_DispensersError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _DispensersLoading implements DispensersState {
  const factory _DispensersLoading() = _$DispensersLoadingImpl;
}

/// @nodoc
abstract class _$$DispensersSuccessImplCopyWith<$Res> {
  factory _$$DispensersSuccessImplCopyWith(_$DispensersSuccessImpl value,
          $Res Function(_$DispensersSuccessImpl) then) =
      __$$DispensersSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Dispenser> dispensers});
}

/// @nodoc
class __$$DispensersSuccessImplCopyWithImpl<$Res>
    extends _$DispensersStateCopyWithImpl<$Res, _$DispensersSuccessImpl>
    implements _$$DispensersSuccessImplCopyWith<$Res> {
  __$$DispensersSuccessImplCopyWithImpl(_$DispensersSuccessImpl _value,
      $Res Function(_$DispensersSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dispensers = null,
  }) {
    return _then(_$DispensersSuccessImpl(
      null == dispensers
          ? _value._dispensers
          : dispensers // ignore: cast_nullable_to_non_nullable
              as List<Dispenser>,
    ));
  }
}

/// @nodoc

class _$DispensersSuccessImpl implements _DispensersSuccess {
  const _$DispensersSuccessImpl(final List<Dispenser> dispensers)
      : _dispensers = dispensers;

  final List<Dispenser> _dispensers;
  @override
  List<Dispenser> get dispensers {
    if (_dispensers is EqualUnmodifiableListView) return _dispensers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dispensers);
  }

  @override
  String toString() {
    return 'DispensersState.success(dispensers: $dispensers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispensersSuccessImpl &&
            const DeepCollectionEquality()
                .equals(other._dispensers, _dispensers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_dispensers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispensersSuccessImplCopyWith<_$DispensersSuccessImpl> get copyWith =>
      __$$DispensersSuccessImplCopyWithImpl<_$DispensersSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return success(dispensers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(dispensers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(dispensers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispensersInitial value) initial,
    required TResult Function(_DispensersLoading value) loading,
    required TResult Function(_DispensersSuccess value) success,
    required TResult Function(_DispensersError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispensersInitial value)? initial,
    TResult? Function(_DispensersLoading value)? loading,
    TResult? Function(_DispensersSuccess value)? success,
    TResult? Function(_DispensersError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispensersInitial value)? initial,
    TResult Function(_DispensersLoading value)? loading,
    TResult Function(_DispensersSuccess value)? success,
    TResult Function(_DispensersError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _DispensersSuccess implements DispensersState {
  const factory _DispensersSuccess(final List<Dispenser> dispensers) =
      _$DispensersSuccessImpl;

  List<Dispenser> get dispensers;
  @JsonKey(ignore: true)
  _$$DispensersSuccessImplCopyWith<_$DispensersSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DispensersErrorImplCopyWith<$Res> {
  factory _$$DispensersErrorImplCopyWith(_$DispensersErrorImpl value,
          $Res Function(_$DispensersErrorImpl) then) =
      __$$DispensersErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$DispensersErrorImplCopyWithImpl<$Res>
    extends _$DispensersStateCopyWithImpl<$Res, _$DispensersErrorImpl>
    implements _$$DispensersErrorImplCopyWith<$Res> {
  __$$DispensersErrorImplCopyWithImpl(
      _$DispensersErrorImpl _value, $Res Function(_$DispensersErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$DispensersErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DispensersErrorImpl implements _DispensersError {
  const _$DispensersErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'DispensersState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispensersErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispensersErrorImplCopyWith<_$DispensersErrorImpl> get copyWith =>
      __$$DispensersErrorImplCopyWithImpl<_$DispensersErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
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
    required TResult Function(_DispensersInitial value) initial,
    required TResult Function(_DispensersLoading value) loading,
    required TResult Function(_DispensersSuccess value) success,
    required TResult Function(_DispensersError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispensersInitial value)? initial,
    TResult? Function(_DispensersLoading value)? loading,
    TResult? Function(_DispensersSuccess value)? success,
    TResult? Function(_DispensersError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispensersInitial value)? initial,
    TResult Function(_DispensersLoading value)? loading,
    TResult Function(_DispensersSuccess value)? success,
    TResult Function(_DispensersError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _DispensersError implements DispensersState {
  const factory _DispensersError(final String error) = _$DispensersErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$DispensersErrorImplCopyWith<_$DispensersErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
