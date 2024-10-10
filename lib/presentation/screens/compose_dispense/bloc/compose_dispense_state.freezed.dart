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
  SubmitState get submitState =>
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
      Address? source,
      String? destination,
      String? asset,
      String quantity,
      String? composeDispenseError});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
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
      Address? source,
      String? destination,
      String? asset,
      String quantity,
      String? composeDispenseError});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
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
    return 'ComposeDispenseState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, source: $source, destination: $destination, asset: $asset, quantity: $quantity, composeDispenseError: $composeDispenseError)';
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
