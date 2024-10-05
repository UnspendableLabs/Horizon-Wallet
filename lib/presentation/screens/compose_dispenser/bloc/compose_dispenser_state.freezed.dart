// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_dispenser_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeDispenserState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState =>
      throw _privateConstructorUsedError; // Dispenser-specific properties
  String? get assetName => throw _privateConstructorUsedError;
  String? get openAddress => throw _privateConstructorUsedError;
  String get giveQuantity => throw _privateConstructorUsedError;
  String get escrowQuantity => throw _privateConstructorUsedError;
  String get mainchainrate => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeDispenserStateCopyWith<ComposeDispenserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeDispenserStateCopyWith<$Res> {
  factory $ComposeDispenserStateCopyWith(ComposeDispenserState value,
          $Res Function(ComposeDispenserState) then) =
      _$ComposeDispenserStateCopyWithImpl<$Res, ComposeDispenserState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      String? assetName,
      String? openAddress,
      String giveQuantity,
      String escrowQuantity,
      String mainchainrate,
      int status});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
}

/// @nodoc
class _$ComposeDispenserStateCopyWithImpl<$Res,
        $Val extends ComposeDispenserState>
    implements $ComposeDispenserStateCopyWith<$Res> {
  _$ComposeDispenserStateCopyWithImpl(this._value, this._then);

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
    Object? assetName = freezed,
    Object? openAddress = freezed,
    Object? giveQuantity = null,
    Object? escrowQuantity = null,
    Object? mainchainrate = null,
    Object? status = null,
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
      assetName: freezed == assetName
          ? _value.assetName
          : assetName // ignore: cast_nullable_to_non_nullable
              as String?,
      openAddress: freezed == openAddress
          ? _value.openAddress
          : openAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      giveQuantity: null == giveQuantity
          ? _value.giveQuantity
          : giveQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      escrowQuantity: null == escrowQuantity
          ? _value.escrowQuantity
          : escrowQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      mainchainrate: null == mainchainrate
          ? _value.mainchainrate
          : mainchainrate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ComposeDispenserStateImplCopyWith<$Res>
    implements $ComposeDispenserStateCopyWith<$Res> {
  factory _$$ComposeDispenserStateImplCopyWith(
          _$ComposeDispenserStateImpl value,
          $Res Function(_$ComposeDispenserStateImpl) then) =
      __$$ComposeDispenserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      String? assetName,
      String? openAddress,
      String giveQuantity,
      String escrowQuantity,
      String mainchainrate,
      int status});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
}

/// @nodoc
class __$$ComposeDispenserStateImplCopyWithImpl<$Res>
    extends _$ComposeDispenserStateCopyWithImpl<$Res,
        _$ComposeDispenserStateImpl>
    implements _$$ComposeDispenserStateImplCopyWith<$Res> {
  __$$ComposeDispenserStateImplCopyWithImpl(_$ComposeDispenserStateImpl _value,
      $Res Function(_$ComposeDispenserStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? assetName = freezed,
    Object? openAddress = freezed,
    Object? giveQuantity = null,
    Object? escrowQuantity = null,
    Object? mainchainrate = null,
    Object? status = null,
  }) {
    return _then(_$ComposeDispenserStateImpl(
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
      assetName: freezed == assetName
          ? _value.assetName
          : assetName // ignore: cast_nullable_to_non_nullable
              as String?,
      openAddress: freezed == openAddress
          ? _value.openAddress
          : openAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      giveQuantity: null == giveQuantity
          ? _value.giveQuantity
          : giveQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      escrowQuantity: null == escrowQuantity
          ? _value.escrowQuantity
          : escrowQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      mainchainrate: null == mainchainrate
          ? _value.mainchainrate
          : mainchainrate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ComposeDispenserStateImpl extends _ComposeDispenserState {
  const _$ComposeDispenserStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      this.assetName,
      this.openAddress,
      required this.giveQuantity,
      required this.escrowQuantity,
      required this.mainchainrate,
      required this.status})
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
// Dispenser-specific properties
  @override
  final String? assetName;
  @override
  final String? openAddress;
  @override
  final String giveQuantity;
  @override
  final String escrowQuantity;
  @override
  final String mainchainrate;
  @override
  final int status;

  @override
  String toString() {
    return 'ComposeDispenserState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, assetName: $assetName, openAddress: $openAddress, giveQuantity: $giveQuantity, escrowQuantity: $escrowQuantity, mainchainrate: $mainchainrate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeDispenserStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState) &&
            (identical(other.assetName, assetName) ||
                other.assetName == assetName) &&
            (identical(other.openAddress, openAddress) ||
                other.openAddress == openAddress) &&
            (identical(other.giveQuantity, giveQuantity) ||
                other.giveQuantity == giveQuantity) &&
            (identical(other.escrowQuantity, escrowQuantity) ||
                other.escrowQuantity == escrowQuantity) &&
            (identical(other.mainchainrate, mainchainrate) ||
                other.mainchainrate == mainchainrate) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      feeState,
      balancesState,
      feeOption,
      submitState,
      assetName,
      openAddress,
      giveQuantity,
      escrowQuantity,
      mainchainrate,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeDispenserStateImplCopyWith<_$ComposeDispenserStateImpl>
      get copyWith => __$$ComposeDispenserStateImplCopyWithImpl<
          _$ComposeDispenserStateImpl>(this, _$identity);
}

abstract class _ComposeDispenserState extends ComposeDispenserState {
  const factory _ComposeDispenserState(
      {required final FeeState feeState,
      required final BalancesState balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState,
      final String? assetName,
      final String? openAddress,
      required final String giveQuantity,
      required final String escrowQuantity,
      required final String mainchainrate,
      required final int status}) = _$ComposeDispenserStateImpl;
  const _ComposeDispenserState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override // Dispenser-specific properties
  String? get assetName;
  @override
  String? get openAddress;
  @override
  String get giveQuantity;
  @override
  String get escrowQuantity;
  @override
  String get mainchainrate;
  @override
  int get status;
  @override
  @JsonKey(ignore: true)
  _$$ComposeDispenserStateImplCopyWith<_$ComposeDispenserStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
