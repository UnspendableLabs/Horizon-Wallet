// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SendState {
  TransactionState<dynamic> get transactionState =>
      throw _privateConstructorUsedError; // Add send-specific properties here
  String? get destinationAddress => throw _privateConstructorUsedError;
  String? get amount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SendStateCopyWith<SendState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendStateCopyWith<$Res> {
  factory $SendStateCopyWith(SendState value, $Res Function(SendState) then) =
      _$SendStateCopyWithImpl<$Res, SendState>;
  @useResult
  $Res call(
      {TransactionState<dynamic> transactionState,
      String? destinationAddress,
      String? amount});

  $TransactionStateCopyWith<dynamic, $Res> get transactionState;
}

/// @nodoc
class _$SendStateCopyWithImpl<$Res, $Val extends SendState>
    implements $SendStateCopyWith<$Res> {
  _$SendStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionState = null,
    Object? destinationAddress = freezed,
    Object? amount = freezed,
  }) {
    return _then(_value.copyWith(
      transactionState: null == transactionState
          ? _value.transactionState
          : transactionState // ignore: cast_nullable_to_non_nullable
              as TransactionState<dynamic>,
      destinationAddress: freezed == destinationAddress
          ? _value.destinationAddress
          : destinationAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TransactionStateCopyWith<dynamic, $Res> get transactionState {
    return $TransactionStateCopyWith<dynamic, $Res>(_value.transactionState,
        (value) {
      return _then(_value.copyWith(transactionState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SendStateImplCopyWith<$Res>
    implements $SendStateCopyWith<$Res> {
  factory _$$SendStateImplCopyWith(
          _$SendStateImpl value, $Res Function(_$SendStateImpl) then) =
      __$$SendStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TransactionState<dynamic> transactionState,
      String? destinationAddress,
      String? amount});

  @override
  $TransactionStateCopyWith<dynamic, $Res> get transactionState;
}

/// @nodoc
class __$$SendStateImplCopyWithImpl<$Res>
    extends _$SendStateCopyWithImpl<$Res, _$SendStateImpl>
    implements _$$SendStateImplCopyWith<$Res> {
  __$$SendStateImplCopyWithImpl(
      _$SendStateImpl _value, $Res Function(_$SendStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionState = null,
    Object? destinationAddress = freezed,
    Object? amount = freezed,
  }) {
    return _then(_$SendStateImpl(
      transactionState: null == transactionState
          ? _value.transactionState
          : transactionState // ignore: cast_nullable_to_non_nullable
              as TransactionState<dynamic>,
      destinationAddress: freezed == destinationAddress
          ? _value.destinationAddress
          : destinationAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SendStateImpl extends _SendState {
  const _$SendStateImpl(
      {required this.transactionState, this.destinationAddress, this.amount})
      : super._();

  @override
  final TransactionState<dynamic> transactionState;
// Add send-specific properties here
  @override
  final String? destinationAddress;
  @override
  final String? amount;

  @override
  String toString() {
    return 'SendState(transactionState: $transactionState, destinationAddress: $destinationAddress, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendStateImpl &&
            (identical(other.transactionState, transactionState) ||
                other.transactionState == transactionState) &&
            (identical(other.destinationAddress, destinationAddress) ||
                other.destinationAddress == destinationAddress) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, transactionState, destinationAddress, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SendStateImplCopyWith<_$SendStateImpl> get copyWith =>
      __$$SendStateImplCopyWithImpl<_$SendStateImpl>(this, _$identity);
}

abstract class _SendState extends SendState {
  const factory _SendState(
      {required final TransactionState<dynamic> transactionState,
      final String? destinationAddress,
      final String? amount}) = _$SendStateImpl;
  const _SendState._() : super._();

  @override
  TransactionState<dynamic> get transactionState;
  @override // Add send-specific properties here
  String? get destinationAddress;
  @override
  String? get amount;
  @override
  @JsonKey(ignore: true)
  _$$SendStateImplCopyWith<_$SendStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
