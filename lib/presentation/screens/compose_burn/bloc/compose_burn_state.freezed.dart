// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_burn_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeBurnState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeBurnStateCopyWith<ComposeBurnState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeBurnStateCopyWith<$Res> {
  factory $ComposeBurnStateCopyWith(
          ComposeBurnState value, $Res Function(ComposeBurnState) then) =
      _$ComposeBurnStateCopyWithImpl<$Res, ComposeBurnState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
}

/// @nodoc
class _$ComposeBurnStateCopyWithImpl<$Res, $Val extends ComposeBurnState>
    implements $ComposeBurnStateCopyWith<$Res> {
  _$ComposeBurnStateCopyWithImpl(this._value, this._then);

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
abstract class _$$ComposeBurnStateImplCopyWith<$Res>
    implements $ComposeBurnStateCopyWith<$Res> {
  factory _$$ComposeBurnStateImplCopyWith(_$ComposeBurnStateImpl value,
          $Res Function(_$ComposeBurnStateImpl) then) =
      __$$ComposeBurnStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
}

/// @nodoc
class __$$ComposeBurnStateImplCopyWithImpl<$Res>
    extends _$ComposeBurnStateCopyWithImpl<$Res, _$ComposeBurnStateImpl>
    implements _$$ComposeBurnStateImplCopyWith<$Res> {
  __$$ComposeBurnStateImplCopyWithImpl(_$ComposeBurnStateImpl _value,
      $Res Function(_$ComposeBurnStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
  }) {
    return _then(_$ComposeBurnStateImpl(
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
    ));
  }
}

/// @nodoc

class _$ComposeBurnStateImpl extends _ComposeBurnState {
  const _$ComposeBurnStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState})
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
  String toString() {
    return 'ComposeBurnState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeBurnStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, feeState, balancesState, feeOption, submitState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeBurnStateImplCopyWith<_$ComposeBurnStateImpl> get copyWith =>
      __$$ComposeBurnStateImplCopyWithImpl<_$ComposeBurnStateImpl>(
          this, _$identity);
}

abstract class _ComposeBurnState extends ComposeBurnState {
  const factory _ComposeBurnState(
      {required final FeeState feeState,
      required final BalancesState balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState}) = _$ComposeBurnStateImpl;
  const _ComposeBurnState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override
  @JsonKey(ignore: true)
  _$$ComposeBurnStateImplCopyWith<_$ComposeBurnStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
