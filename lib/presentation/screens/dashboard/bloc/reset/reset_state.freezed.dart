// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reset_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ResetState {
  dynamic get resetState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ResetStateCopyWith<ResetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetStateCopyWith<$Res> {
  factory $ResetStateCopyWith(
          ResetState value, $Res Function(ResetState) then) =
      _$ResetStateCopyWithImpl<$Res, ResetState>;
  @useResult
  $Res call({dynamic resetState});
}

/// @nodoc
class _$ResetStateCopyWithImpl<$Res, $Val extends ResetState>
    implements $ResetStateCopyWith<$Res> {
  _$ResetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resetState = freezed,
  }) {
    return _then(_value.copyWith(
      resetState: freezed == resetState
          ? _value.resetState
          : resetState // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResetStateImplCopyWith<$Res>
    implements $ResetStateCopyWith<$Res> {
  factory _$$ResetStateImplCopyWith(
          _$ResetStateImpl value, $Res Function(_$ResetStateImpl) then) =
      __$$ResetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic resetState});
}

/// @nodoc
class __$$ResetStateImplCopyWithImpl<$Res>
    extends _$ResetStateCopyWithImpl<$Res, _$ResetStateImpl>
    implements _$$ResetStateImplCopyWith<$Res> {
  __$$ResetStateImplCopyWithImpl(
      _$ResetStateImpl _value, $Res Function(_$ResetStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resetState = freezed,
  }) {
    return _then(_$ResetStateImpl(
      resetState: freezed == resetState ? _value.resetState! : resetState,
    ));
  }
}

/// @nodoc

class _$ResetStateImpl implements _ResetState {
  const _$ResetStateImpl({this.resetState = In});

  @override
  @JsonKey()
  final dynamic resetState;

  @override
  String toString() {
    return 'ResetState(resetState: $resetState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetStateImpl &&
            const DeepCollectionEquality()
                .equals(other.resetState, resetState));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(resetState));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetStateImplCopyWith<_$ResetStateImpl> get copyWith =>
      __$$ResetStateImplCopyWithImpl<_$ResetStateImpl>(this, _$identity);
}

abstract class _ResetState implements ResetState {
  const factory _ResetState({final dynamic resetState}) = _$ResetStateImpl;

  @override
  dynamic get resetState;
  @override
  @JsonKey(ignore: true)
  _$$ResetStateImplCopyWith<_$ResetStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
