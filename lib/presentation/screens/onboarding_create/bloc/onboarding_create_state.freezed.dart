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
  MnemonicErrorState? get mnemonicError => throw _privateConstructorUsedError;
  dynamic get mnemonicState => throw _privateConstructorUsedError;
  dynamic get createState => throw _privateConstructorUsedError;
  OnboardingCreateStep get currentStep => throw _privateConstructorUsedError;

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
      {MnemonicErrorState? mnemonicError,
      dynamic mnemonicState,
      dynamic createState,
      OnboardingCreateStep currentStep});
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
    Object? mnemonicError = freezed,
    Object? mnemonicState = freezed,
    Object? createState = freezed,
    Object? currentStep = null,
  }) {
    return _then(_value.copyWith(
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
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as OnboardingCreateStep,
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
      {MnemonicErrorState? mnemonicError,
      dynamic mnemonicState,
      dynamic createState,
      OnboardingCreateStep currentStep});
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
    Object? mnemonicError = freezed,
    Object? mnemonicState = freezed,
    Object? createState = freezed,
    Object? currentStep = null,
  }) {
    return _then(_$OnboardingCreateStateImpl(
      mnemonicError: freezed == mnemonicError
          ? _value.mnemonicError
          : mnemonicError // ignore: cast_nullable_to_non_nullable
              as MnemonicErrorState?,
      mnemonicState:
          freezed == mnemonicState ? _value.mnemonicState! : mnemonicState,
      createState: freezed == createState ? _value.createState! : createState,
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as OnboardingCreateStep,
    ));
  }
}

/// @nodoc

class _$OnboardingCreateStateImpl implements _OnboardingCreateState {
  const _$OnboardingCreateStateImpl(
      {this.mnemonicError = null,
      this.mnemonicState = MnemonicGeneratedStateNotAsked,
      this.createState = CreateStateNotAsked,
      this.currentStep = OnboardingCreateStep.showMnemonic});

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
  @JsonKey()
  final OnboardingCreateStep currentStep;

  @override
  String toString() {
    return 'OnboardingCreateState(mnemonicError: $mnemonicError, mnemonicState: $mnemonicState, createState: $createState, currentStep: $currentStep)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingCreateStateImpl &&
            (identical(other.mnemonicError, mnemonicError) ||
                other.mnemonicError == mnemonicError) &&
            const DeepCollectionEquality()
                .equals(other.mnemonicState, mnemonicState) &&
            const DeepCollectionEquality()
                .equals(other.createState, createState) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      mnemonicError,
      const DeepCollectionEquality().hash(mnemonicState),
      const DeepCollectionEquality().hash(createState),
      currentStep);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingCreateStateImplCopyWith<_$OnboardingCreateStateImpl>
      get copyWith => __$$OnboardingCreateStateImplCopyWithImpl<
          _$OnboardingCreateStateImpl>(this, _$identity);
}

abstract class _OnboardingCreateState implements OnboardingCreateState {
  const factory _OnboardingCreateState(
      {final MnemonicErrorState? mnemonicError,
      final dynamic mnemonicState,
      final dynamic createState,
      final OnboardingCreateStep currentStep}) = _$OnboardingCreateStateImpl;

  @override
  MnemonicErrorState? get mnemonicError;
  @override
  dynamic get mnemonicState;
  @override
  dynamic get createState;
  @override
  OnboardingCreateStep get currentStep;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingCreateStateImplCopyWith<_$OnboardingCreateStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
