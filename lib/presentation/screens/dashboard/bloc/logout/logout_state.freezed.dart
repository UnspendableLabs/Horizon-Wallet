// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LogoutState {
  dynamic get logoutState => throw _privateConstructorUsedError;
  bool get hasConfirmedUnderstanding => throw _privateConstructorUsedError;
  String get resetConfirmationText => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LogoutStateCopyWith<LogoutState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogoutStateCopyWith<$Res> {
  factory $LogoutStateCopyWith(
          LogoutState value, $Res Function(LogoutState) then) =
      _$LogoutStateCopyWithImpl<$Res, LogoutState>;
  @useResult
  $Res call(
      {dynamic logoutState,
      bool hasConfirmedUnderstanding,
      String resetConfirmationText});
}

/// @nodoc
class _$LogoutStateCopyWithImpl<$Res, $Val extends LogoutState>
    implements $LogoutStateCopyWith<$Res> {
  _$LogoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logoutState = freezed,
    Object? hasConfirmedUnderstanding = null,
    Object? resetConfirmationText = null,
  }) {
    return _then(_value.copyWith(
      logoutState: freezed == logoutState
          ? _value.logoutState
          : logoutState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      hasConfirmedUnderstanding: null == hasConfirmedUnderstanding
          ? _value.hasConfirmedUnderstanding
          : hasConfirmedUnderstanding // ignore: cast_nullable_to_non_nullable
              as bool,
      resetConfirmationText: null == resetConfirmationText
          ? _value.resetConfirmationText
          : resetConfirmationText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogoutStateImplCopyWith<$Res>
    implements $LogoutStateCopyWith<$Res> {
  factory _$$LogoutStateImplCopyWith(
          _$LogoutStateImpl value, $Res Function(_$LogoutStateImpl) then) =
      __$$LogoutStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic logoutState,
      bool hasConfirmedUnderstanding,
      String resetConfirmationText});
}

/// @nodoc
class __$$LogoutStateImplCopyWithImpl<$Res>
    extends _$LogoutStateCopyWithImpl<$Res, _$LogoutStateImpl>
    implements _$$LogoutStateImplCopyWith<$Res> {
  __$$LogoutStateImplCopyWithImpl(
      _$LogoutStateImpl _value, $Res Function(_$LogoutStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logoutState = freezed,
    Object? hasConfirmedUnderstanding = null,
    Object? resetConfirmationText = null,
  }) {
    return _then(_$LogoutStateImpl(
      logoutState: freezed == logoutState ? _value.logoutState! : logoutState,
      hasConfirmedUnderstanding: null == hasConfirmedUnderstanding
          ? _value.hasConfirmedUnderstanding
          : hasConfirmedUnderstanding // ignore: cast_nullable_to_non_nullable
              as bool,
      resetConfirmationText: null == resetConfirmationText
          ? _value.resetConfirmationText
          : resetConfirmationText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LogoutStateImpl implements _LogoutState {
  const _$LogoutStateImpl(
      {this.logoutState = LoggedIn,
      this.hasConfirmedUnderstanding = false,
      this.resetConfirmationText = ''});

  @override
  @JsonKey()
  final dynamic logoutState;
  @override
  @JsonKey()
  final bool hasConfirmedUnderstanding;
  @override
  @JsonKey()
  final String resetConfirmationText;

  @override
  String toString() {
    return 'LogoutState(logoutState: $logoutState, hasConfirmedUnderstanding: $hasConfirmedUnderstanding, resetConfirmationText: $resetConfirmationText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogoutStateImpl &&
            const DeepCollectionEquality()
                .equals(other.logoutState, logoutState) &&
            (identical(other.hasConfirmedUnderstanding,
                    hasConfirmedUnderstanding) ||
                other.hasConfirmedUnderstanding == hasConfirmedUnderstanding) &&
            (identical(other.resetConfirmationText, resetConfirmationText) ||
                other.resetConfirmationText == resetConfirmationText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(logoutState),
      hasConfirmedUnderstanding,
      resetConfirmationText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogoutStateImplCopyWith<_$LogoutStateImpl> get copyWith =>
      __$$LogoutStateImplCopyWithImpl<_$LogoutStateImpl>(this, _$identity);
}

abstract class _LogoutState implements LogoutState {
  const factory _LogoutState(
      {final dynamic logoutState,
      final bool hasConfirmedUnderstanding,
      final String resetConfirmationText}) = _$LogoutStateImpl;

  @override
  dynamic get logoutState;
  @override
  bool get hasConfirmedUnderstanding;
  @override
  String get resetConfirmationText;
  @override
  @JsonKey(ignore: true)
  _$$LogoutStateImplCopyWith<_$LogoutStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
