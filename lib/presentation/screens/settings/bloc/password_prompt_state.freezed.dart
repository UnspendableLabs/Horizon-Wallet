// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_prompt_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PasswordPromptState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? gapLimit) initial,
    required TResult Function(int oldValue) prompt,
    required TResult Function() validate,
    required TResult Function(String password, int gapLimit) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? gapLimit)? initial,
    TResult? Function(int oldValue)? prompt,
    TResult? Function()? validate,
    TResult? Function(String password, int gapLimit)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? gapLimit)? initial,
    TResult Function(int oldValue)? prompt,
    TResult Function()? validate,
    TResult Function(String password, int gapLimit)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Prompt value) prompt,
    required TResult Function(_Validate value) validate,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Prompt value)? prompt,
    TResult? Function(_Validate value)? validate,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Prompt value)? prompt,
    TResult Function(_Validate value)? validate,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordPromptStateCopyWith<$Res> {
  factory $PasswordPromptStateCopyWith(
          PasswordPromptState value, $Res Function(PasswordPromptState) then) =
      _$PasswordPromptStateCopyWithImpl<$Res, PasswordPromptState>;
}

/// @nodoc
class _$PasswordPromptStateCopyWithImpl<$Res, $Val extends PasswordPromptState>
    implements $PasswordPromptStateCopyWith<$Res> {
  _$PasswordPromptStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? gapLimit});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$PasswordPromptStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gapLimit = freezed,
  }) {
    return _then(_$InitialImpl(
      freezed == gapLimit
          ? _value.gapLimit
          : gapLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl([this.gapLimit]);

  @override
  final int? gapLimit;

  @override
  String toString() {
    return 'PasswordPromptState.initial(gapLimit: $gapLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            (identical(other.gapLimit, gapLimit) ||
                other.gapLimit == gapLimit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, gapLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? gapLimit) initial,
    required TResult Function(int oldValue) prompt,
    required TResult Function() validate,
    required TResult Function(String password, int gapLimit) success,
    required TResult Function(String error) error,
  }) {
    return initial(gapLimit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? gapLimit)? initial,
    TResult? Function(int oldValue)? prompt,
    TResult? Function()? validate,
    TResult? Function(String password, int gapLimit)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call(gapLimit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? gapLimit)? initial,
    TResult Function(int oldValue)? prompt,
    TResult Function()? validate,
    TResult Function(String password, int gapLimit)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(gapLimit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Prompt value) prompt,
    required TResult Function(_Validate value) validate,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Prompt value)? prompt,
    TResult? Function(_Validate value)? validate,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Prompt value)? prompt,
    TResult Function(_Validate value)? validate,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements PasswordPromptState {
  const factory _Initial([final int? gapLimit]) = _$InitialImpl;

  int? get gapLimit;
  @JsonKey(ignore: true)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PromptImplCopyWith<$Res> {
  factory _$$PromptImplCopyWith(
          _$PromptImpl value, $Res Function(_$PromptImpl) then) =
      __$$PromptImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int oldValue});
}

/// @nodoc
class __$$PromptImplCopyWithImpl<$Res>
    extends _$PasswordPromptStateCopyWithImpl<$Res, _$PromptImpl>
    implements _$$PromptImplCopyWith<$Res> {
  __$$PromptImplCopyWithImpl(
      _$PromptImpl _value, $Res Function(_$PromptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oldValue = null,
  }) {
    return _then(_$PromptImpl(
      null == oldValue
          ? _value.oldValue
          : oldValue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PromptImpl implements _Prompt {
  const _$PromptImpl(this.oldValue);

  @override
  final int oldValue;

  @override
  String toString() {
    return 'PasswordPromptState.prompt(oldValue: $oldValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromptImpl &&
            (identical(other.oldValue, oldValue) ||
                other.oldValue == oldValue));
  }

  @override
  int get hashCode => Object.hash(runtimeType, oldValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PromptImplCopyWith<_$PromptImpl> get copyWith =>
      __$$PromptImplCopyWithImpl<_$PromptImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? gapLimit) initial,
    required TResult Function(int oldValue) prompt,
    required TResult Function() validate,
    required TResult Function(String password, int gapLimit) success,
    required TResult Function(String error) error,
  }) {
    return prompt(oldValue);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? gapLimit)? initial,
    TResult? Function(int oldValue)? prompt,
    TResult? Function()? validate,
    TResult? Function(String password, int gapLimit)? success,
    TResult? Function(String error)? error,
  }) {
    return prompt?.call(oldValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? gapLimit)? initial,
    TResult Function(int oldValue)? prompt,
    TResult Function()? validate,
    TResult Function(String password, int gapLimit)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (prompt != null) {
      return prompt(oldValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Prompt value) prompt,
    required TResult Function(_Validate value) validate,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return prompt(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Prompt value)? prompt,
    TResult? Function(_Validate value)? validate,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return prompt?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Prompt value)? prompt,
    TResult Function(_Validate value)? validate,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (prompt != null) {
      return prompt(this);
    }
    return orElse();
  }
}

abstract class _Prompt implements PasswordPromptState {
  const factory _Prompt(final int oldValue) = _$PromptImpl;

  int get oldValue;
  @JsonKey(ignore: true)
  _$$PromptImplCopyWith<_$PromptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidateImplCopyWith<$Res> {
  factory _$$ValidateImplCopyWith(
          _$ValidateImpl value, $Res Function(_$ValidateImpl) then) =
      __$$ValidateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ValidateImplCopyWithImpl<$Res>
    extends _$PasswordPromptStateCopyWithImpl<$Res, _$ValidateImpl>
    implements _$$ValidateImplCopyWith<$Res> {
  __$$ValidateImplCopyWithImpl(
      _$ValidateImpl _value, $Res Function(_$ValidateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ValidateImpl implements _Validate {
  const _$ValidateImpl();

  @override
  String toString() {
    return 'PasswordPromptState.validate()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ValidateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? gapLimit) initial,
    required TResult Function(int oldValue) prompt,
    required TResult Function() validate,
    required TResult Function(String password, int gapLimit) success,
    required TResult Function(String error) error,
  }) {
    return validate();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? gapLimit)? initial,
    TResult? Function(int oldValue)? prompt,
    TResult? Function()? validate,
    TResult? Function(String password, int gapLimit)? success,
    TResult? Function(String error)? error,
  }) {
    return validate?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? gapLimit)? initial,
    TResult Function(int oldValue)? prompt,
    TResult Function()? validate,
    TResult Function(String password, int gapLimit)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (validate != null) {
      return validate();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Prompt value) prompt,
    required TResult Function(_Validate value) validate,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return validate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Prompt value)? prompt,
    TResult? Function(_Validate value)? validate,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return validate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Prompt value)? prompt,
    TResult Function(_Validate value)? validate,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (validate != null) {
      return validate(this);
    }
    return orElse();
  }
}

abstract class _Validate implements PasswordPromptState {
  const factory _Validate() = _$ValidateImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl value, $Res Function(_$SuccessImpl) then) =
      __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String password, int gapLimit});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$PasswordPromptStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl _value, $Res Function(_$SuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? gapLimit = null,
  }) {
    return _then(_$SuccessImpl(
      null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      null == gapLimit
          ? _value.gapLimit
          : gapLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.password, this.gapLimit);

  @override
  final String password;
  @override
  final int gapLimit;

  @override
  String toString() {
    return 'PasswordPromptState.success(password: $password, gapLimit: $gapLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.gapLimit, gapLimit) ||
                other.gapLimit == gapLimit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, password, gapLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? gapLimit) initial,
    required TResult Function(int oldValue) prompt,
    required TResult Function() validate,
    required TResult Function(String password, int gapLimit) success,
    required TResult Function(String error) error,
  }) {
    return success(password, gapLimit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? gapLimit)? initial,
    TResult? Function(int oldValue)? prompt,
    TResult? Function()? validate,
    TResult? Function(String password, int gapLimit)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(password, gapLimit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? gapLimit)? initial,
    TResult Function(int oldValue)? prompt,
    TResult Function()? validate,
    TResult Function(String password, int gapLimit)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(password, gapLimit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Prompt value) prompt,
    required TResult Function(_Validate value) validate,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Prompt value)? prompt,
    TResult? Function(_Validate value)? validate,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Prompt value)? prompt,
    TResult Function(_Validate value)? validate,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements PasswordPromptState {
  const factory _Success(final String password, final int gapLimit) =
      _$SuccessImpl;

  String get password;
  int get gapLimit;
  @JsonKey(ignore: true)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$PasswordPromptStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$ErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'PasswordPromptState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? gapLimit) initial,
    required TResult Function(int oldValue) prompt,
    required TResult Function() validate,
    required TResult Function(String password, int gapLimit) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? gapLimit)? initial,
    TResult? Function(int oldValue)? prompt,
    TResult? Function()? validate,
    TResult? Function(String password, int gapLimit)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? gapLimit)? initial,
    TResult Function(int oldValue)? prompt,
    TResult Function()? validate,
    TResult Function(String password, int gapLimit)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Prompt value) prompt,
    required TResult Function(_Validate value) validate,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Prompt value)? prompt,
    TResult? Function(_Validate value)? validate,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Prompt value)? prompt,
    TResult Function(_Validate value)? validate,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements PasswordPromptState {
  const factory _Error(final String error) = _$ErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
