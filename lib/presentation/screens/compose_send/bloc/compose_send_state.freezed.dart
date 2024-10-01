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
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState =>
      throw _privateConstructorUsedError; // Specific properties
  MaxValueState get maxValue => throw _privateConstructorUsedError;
  bool get sendMax => throw _privateConstructorUsedError;
  Address? get source => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  String? get asset => throw _privateConstructorUsedError;
  String get quantity => throw _privateConstructorUsedError;
  String? get composeSendError => throw _privateConstructorUsedError;

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
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      MaxValueState maxValue,
      bool sendMax,
      Address? source,
      String? destination,
      String? asset,
      String quantity,
      String? composeSendError});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
  $MaxValueStateCopyWith<$Res> get maxValue;
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
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? maxValue = null,
    Object? sendMax = null,
    Object? source = freezed,
    Object? destination = freezed,
    Object? asset = freezed,
    Object? quantity = null,
    Object? composeSendError = freezed,
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
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as MaxValueState,
      sendMax: null == sendMax
          ? _value.sendMax
          : sendMax // ignore: cast_nullable_to_non_nullable
              as bool,
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
      composeSendError: freezed == composeSendError
          ? _value.composeSendError
          : composeSendError // ignore: cast_nullable_to_non_nullable
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
  $MaxValueStateCopyWith<$Res> get maxValue {
    return $MaxValueStateCopyWith<$Res>(_value.maxValue, (value) {
      return _then(_value.copyWith(maxValue: value) as $Val);
    });
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
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      MaxValueState maxValue,
      bool sendMax,
      Address? source,
      String? destination,
      String? asset,
      String quantity,
      String? composeSendError});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
  @override
  $MaxValueStateCopyWith<$Res> get maxValue;
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
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? maxValue = null,
    Object? sendMax = null,
    Object? source = freezed,
    Object? destination = freezed,
    Object? asset = freezed,
    Object? quantity = null,
    Object? composeSendError = freezed,
  }) {
    return _then(_$ComposeSendStateImpl(
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
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as MaxValueState,
      sendMax: null == sendMax
          ? _value.sendMax
          : sendMax // ignore: cast_nullable_to_non_nullable
              as bool,
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
      composeSendError: freezed == composeSendError
          ? _value.composeSendError
          : composeSendError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ComposeSendStateImpl extends _ComposeSendState {
  const _$ComposeSendStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      required this.maxValue,
      required this.sendMax,
      this.source,
      this.destination,
      this.asset,
      required this.quantity,
      this.composeSendError})
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
  final MaxValueState maxValue;
  @override
  final bool sendMax;
  @override
  final Address? source;
  @override
  final String? destination;
  @override
  final String? asset;
  @override
  final String quantity;
  @override
  final String? composeSendError;

  @override
  String toString() {
    return 'ComposeSendState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, maxValue: $maxValue, sendMax: $sendMax, source: $source, destination: $destination, asset: $asset, quantity: $quantity, composeSendError: $composeSendError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeSendStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState) &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.sendMax, sendMax) || other.sendMax == sendMax) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.asset, asset) || other.asset == asset) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.composeSendError, composeSendError) ||
                other.composeSendError == composeSendError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      feeState,
      balancesState,
      feeOption,
      submitState,
      maxValue,
      sendMax,
      source,
      destination,
      asset,
      quantity,
      composeSendError);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeSendStateImplCopyWith<_$ComposeSendStateImpl> get copyWith =>
      __$$ComposeSendStateImplCopyWithImpl<_$ComposeSendStateImpl>(
          this, _$identity);
}

abstract class _ComposeSendState extends ComposeSendState {
  const factory _ComposeSendState(
      {required final FeeState feeState,
      required final BalancesState balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState,
      required final MaxValueState maxValue,
      required final bool sendMax,
      final Address? source,
      final String? destination,
      final String? asset,
      required final String quantity,
      final String? composeSendError}) = _$ComposeSendStateImpl;
  const _ComposeSendState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override // Specific properties
  MaxValueState get maxValue;
  @override
  bool get sendMax;
  @override
  Address? get source;
  @override
  String? get destination;
  @override
  String? get asset;
  @override
  String get quantity;
  @override
  String? get composeSendError;
  @override
  @JsonKey(ignore: true)
  _$$ComposeSendStateImplCopyWith<_$ComposeSendStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
