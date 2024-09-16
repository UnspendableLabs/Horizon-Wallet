// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_import_pk_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingImportPKState {
  String? get pkError => throw _privateConstructorUsedError;
  String get pk => throw _privateConstructorUsedError;
  dynamic get importFormat => throw _privateConstructorUsedError;
  dynamic get importState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OnboardingImportPKStateCopyWith<OnboardingImportPKState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingImportPKStateCopyWith<$Res> {
  factory $OnboardingImportPKStateCopyWith(OnboardingImportPKState value,
          $Res Function(OnboardingImportPKState) then) =
      _$OnboardingImportPKStateCopyWithImpl<$Res, OnboardingImportPKState>;
  @useResult
  $Res call(
      {String? pkError, String pk, dynamic importFormat, dynamic importState});
}

/// @nodoc
class _$OnboardingImportPKStateCopyWithImpl<$Res,
        $Val extends OnboardingImportPKState>
    implements $OnboardingImportPKStateCopyWith<$Res> {
  _$OnboardingImportPKStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pkError = freezed,
    Object? pk = null,
    Object? importFormat = freezed,
    Object? importState = freezed,
  }) {
    return _then(_value.copyWith(
      pkError: freezed == pkError
          ? _value.pkError
          : pkError // ignore: cast_nullable_to_non_nullable
              as String?,
      pk: null == pk
          ? _value.pk
          : pk // ignore: cast_nullable_to_non_nullable
              as String,
      importFormat: freezed == importFormat
          ? _value.importFormat
          : importFormat // ignore: cast_nullable_to_non_nullable
              as dynamic,
      importState: freezed == importState
          ? _value.importState
          : importState // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingImportPKStateImplCopyWith<$Res>
    implements $OnboardingImportPKStateCopyWith<$Res> {
  factory _$$OnboardingImportPKStateImplCopyWith(
          _$OnboardingImportPKStateImpl value,
          $Res Function(_$OnboardingImportPKStateImpl) then) =
      __$$OnboardingImportPKStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? pkError, String pk, dynamic importFormat, dynamic importState});
}

/// @nodoc
class __$$OnboardingImportPKStateImplCopyWithImpl<$Res>
    extends _$OnboardingImportPKStateCopyWithImpl<$Res,
        _$OnboardingImportPKStateImpl>
    implements _$$OnboardingImportPKStateImplCopyWith<$Res> {
  __$$OnboardingImportPKStateImplCopyWithImpl(
      _$OnboardingImportPKStateImpl _value,
      $Res Function(_$OnboardingImportPKStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pkError = freezed,
    Object? pk = null,
    Object? importFormat = freezed,
    Object? importState = freezed,
  }) {
    return _then(_$OnboardingImportPKStateImpl(
      pkError: freezed == pkError
          ? _value.pkError
          : pkError // ignore: cast_nullable_to_non_nullable
              as String?,
      pk: null == pk
          ? _value.pk
          : pk // ignore: cast_nullable_to_non_nullable
              as String,
      importFormat:
          freezed == importFormat ? _value.importFormat! : importFormat,
      importState: freezed == importState ? _value.importState! : importState,
    ));
  }
}

/// @nodoc

class _$OnboardingImportPKStateImpl implements _OnboardingImportPKState {
  const _$OnboardingImportPKStateImpl(
      {this.pkError,
      this.pk = "",
      this.importFormat = ImportFormat.horizon,
      this.importState = ImportStateNotAsked});

  @override
  final String? pkError;
  @override
  @JsonKey()
  final String pk;
  @override
  @JsonKey()
  final dynamic importFormat;
  @override
  @JsonKey()
  final dynamic importState;

  @override
  String toString() {
    return 'OnboardingImportPKState(pkError: $pkError, pk: $pk, importFormat: $importFormat, importState: $importState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingImportPKStateImpl &&
            (identical(other.pkError, pkError) || other.pkError == pkError) &&
            (identical(other.pk, pk) || other.pk == pk) &&
            const DeepCollectionEquality()
                .equals(other.importFormat, importFormat) &&
            const DeepCollectionEquality()
                .equals(other.importState, importState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      pkError,
      pk,
      const DeepCollectionEquality().hash(importFormat),
      const DeepCollectionEquality().hash(importState));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingImportPKStateImplCopyWith<_$OnboardingImportPKStateImpl>
      get copyWith => __$$OnboardingImportPKStateImplCopyWithImpl<
          _$OnboardingImportPKStateImpl>(this, _$identity);
}

abstract class _OnboardingImportPKState implements OnboardingImportPKState {
  const factory _OnboardingImportPKState(
      {final String? pkError,
      final String pk,
      final dynamic importFormat,
      final dynamic importState}) = _$OnboardingImportPKStateImpl;

  @override
  String? get pkError;
  @override
  String get pk;
  @override
  dynamic get importFormat;
  @override
  dynamic get importState;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingImportPKStateImplCopyWith<_$OnboardingImportPKStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
