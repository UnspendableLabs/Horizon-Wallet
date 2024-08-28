// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_create_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingCreateState {
  String? get password => throw _privateConstructorUsedError;
  String? get passwordError => throw _privateConstructorUsedError;
  MnemonicErrorState? get mnemonicError => throw _privateConstructorUsedError;
  dynamic get mnemonicState => throw _privateConstructorUsedError;
  dynamic get createState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OnboardingCreateStateCopyWith<OnboardingCreateState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingCreateStateCopyWith<$Res> {
  factory $OnboardingCreateStateCopyWith(OnboardingCreateState value,
          $Res Function(OnboardingCreateState) then) =
      _$OnboardingCreateStateCopyWithImpl<$Res, OnboardingCreateState>;
  @useResult
  $Res call(
      {String? password,
      String? passwordError,
      MnemonicErrorState? mnemonicError,
      dynamic mnemonicState,
      dynamic createState});
}

/// @nodoc
class _$OnboardingCreateStateCopyWithImpl<$Res,
        $Val extends OnboardingCreateState>
    implements $OnboardingCreateStateCopyWith<$Res> {
  _$OnboardingCreateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = freezed,
    Object? passwordError = freezed,
    Object? mnemonicError = freezed,
    Object? mnemonicState = freezed,
    Object? createState = freezed,
  }) {
    return _then(_value.copyWith(
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordError: freezed == passwordError
          ? _value.passwordError
          : passwordError // ignore: cast_nullable_to_non_nullable
              as String?,
      mnemonicError: freezed == mnemonicError
          ? _value.mnemonicError
          : mnemonicError // ignore: cast_nullable_to_non_nullable
              as MnemonicErrorState?,
      mnemonicState: freezed == mnemonicState
          ? _value.mnemonicState
          : mnemonicState // ignore: cast_nullable_to_non_nullable
              as dynamic,
      createState: freezed == createState
          ? _value.createState
          : createState // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingCreateStateImplCopyWith<$Res>
    implements $OnboardingCreateStateCopyWith<$Res> {
  factory _$$OnboardingCreateStateImplCopyWith(
          _$OnboardingCreateStateImpl value,
          $Res Function(_$OnboardingCreateStateImpl) then) =
      __$$OnboardingCreateStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? password,
      String? passwordError,
      MnemonicErrorState? mnemonicError,
      dynamic mnemonicState,
      dynamic createState});
}

/// @nodoc
class __$$OnboardingCreateStateImplCopyWithImpl<$Res>
    extends _$OnboardingCreateStateCopyWithImpl<$Res,
        _$OnboardingCreateStateImpl>
    implements _$$OnboardingCreateStateImplCopyWith<$Res> {
  __$$OnboardingCreateStateImplCopyWithImpl(_$OnboardingCreateStateImpl _value,
      $Res Function(_$OnboardingCreateStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = freezed,
    Object? passwordError = freezed,
    Object? mnemonicError = freezed,
    Object? mnemonicState = freezed,
    Object? createState = freezed,
  }) {
    return _then(_$OnboardingCreateStateImpl(
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordError: freezed == passwordError
          ? _value.passwordError
          : passwordError // ignore: cast_nullable_to_non_nullable
              as String?,
      mnemonicError: freezed == mnemonicError
          ? _value.mnemonicError
          : mnemonicError // ignore: cast_nullable_to_non_nullable
              as MnemonicErrorState?,
      mnemonicState:
          freezed == mnemonicState ? _value.mnemonicState! : mnemonicState,
      createState: freezed == createState ? _value.createState! : createState,
    ));
  }
}

/// @nodoc

class _$OnboardingCreateStateImpl implements _OnboardingCreateState {
  const _$OnboardingCreateStateImpl(
      {this.password,
      this.passwordError,
      this.mnemonicError = null,
      this.mnemonicState = GenerateMnemonicStateNotAsked,
      this.createState = CreateStateNotAsked});

  @override
  final String? password;
  @override
  final String? passwordError;
  @override
  @JsonKey()
  final MnemonicErrorState? mnemonicError;
  @override
  @JsonKey()
  final dynamic mnemonicState;
  @override
  @JsonKey()
  final dynamic createState;

  @override
  String toString() {
    return 'OnboardingCreateState(password: $password, passwordError: $passwordError, mnemonicError: $mnemonicError, mnemonicState: $mnemonicState, createState: $createState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingCreateStateImpl &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.passwordError, passwordError) ||
                other.passwordError == passwordError) &&
            (identical(other.mnemonicError, mnemonicError) ||
                other.mnemonicError == mnemonicError) &&
            const DeepCollectionEquality()
                .equals(other.mnemonicState, mnemonicState) &&
            const DeepCollectionEquality()
                .equals(other.createState, createState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      password,
      passwordError,
      mnemonicError,
      const DeepCollectionEquality().hash(mnemonicState),
      const DeepCollectionEquality().hash(createState));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingCreateStateImplCopyWith<_$OnboardingCreateStateImpl>
      get copyWith => __$$OnboardingCreateStateImplCopyWithImpl<
          _$OnboardingCreateStateImpl>(this, _$identity);
}

abstract class _OnboardingCreateState implements OnboardingCreateState {
  const factory _OnboardingCreateState(
      {final String? password,
      final String? passwordError,
      final MnemonicErrorState? mnemonicError,
      final dynamic mnemonicState,
      final dynamic createState}) = _$OnboardingCreateStateImpl;

  @override
  String? get password;
  @override
  String? get passwordError;
  @override
  MnemonicErrorState? get mnemonicError;
  @override
  dynamic get mnemonicState;
  @override
  dynamic get createState;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingCreateStateImplCopyWith<_$OnboardingCreateStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
