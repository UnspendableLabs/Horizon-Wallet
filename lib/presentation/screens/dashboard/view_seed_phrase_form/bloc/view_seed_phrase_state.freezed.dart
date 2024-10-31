// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_seed_phrase_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ViewSeedPhraseState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ViewSeedPhraseStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewSeedPhraseStateSuccess succcess) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewSeedPhraseStateSuccess succcess)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewSeedPhraseStateSuccess succcess)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Error value) error,
    required TResult Function(_Success value) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Error value)? error,
    TResult? Function(_Success value)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Error value)? error,
    TResult Function(_Success value)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewSeedPhraseStateCopyWith<$Res> {
  factory $ViewSeedPhraseStateCopyWith(
          ViewSeedPhraseState value, $Res Function(ViewSeedPhraseState) then) =
      _$ViewSeedPhraseStateCopyWithImpl<$Res, ViewSeedPhraseState>;
}

/// @nodoc
class _$ViewSeedPhraseStateCopyWithImpl<$Res, $Val extends ViewSeedPhraseState>
    implements $ViewSeedPhraseStateCopyWith<$Res> {
  _$ViewSeedPhraseStateCopyWithImpl(this._value, this._then);

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
  $Res call({ViewSeedPhraseStateInitial initial});

  $ViewSeedPhraseStateInitialCopyWith<$Res> get initial;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ViewSeedPhraseStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initial = null,
  }) {
    return _then(_$InitialImpl(
      null == initial
          ? _value.initial
          : initial // ignore: cast_nullable_to_non_nullable
              as ViewSeedPhraseStateInitial,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $ViewSeedPhraseStateInitialCopyWith<$Res> get initial {
    return $ViewSeedPhraseStateInitialCopyWith<$Res>(_value.initial, (value) {
      return _then(_value.copyWith(initial: value));
    });
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(this.initial);

  @override
  final ViewSeedPhraseStateInitial initial;

  @override
  String toString() {
    return 'ViewSeedPhraseState.initial(initial: $initial)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            (identical(other.initial, initial) || other.initial == initial));
  }

  @override
  int get hashCode => Object.hash(runtimeType, initial);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ViewSeedPhraseStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewSeedPhraseStateSuccess succcess) success,
  }) {
    return initial(this.initial);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewSeedPhraseStateSuccess succcess)? success,
  }) {
    return initial?.call(this.initial);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewSeedPhraseStateSuccess succcess)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this.initial);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Error value) error,
    required TResult Function(_Success value) success,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Error value)? error,
    TResult? Function(_Success value)? success,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Error value)? error,
    TResult Function(_Success value)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ViewSeedPhraseState {
  const factory _Initial(final ViewSeedPhraseStateInitial initial) =
      _$InitialImpl;

  ViewSeedPhraseStateInitial get initial;
  @JsonKey(ignore: true)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ViewSeedPhraseStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ViewSeedPhraseState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ViewSeedPhraseStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewSeedPhraseStateSuccess succcess) success,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewSeedPhraseStateSuccess succcess)? success,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewSeedPhraseStateSuccess succcess)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Error value) error,
    required TResult Function(_Success value) success,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Error value)? error,
    TResult? Function(_Success value)? success,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Error value)? error,
    TResult Function(_Success value)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ViewSeedPhraseState {
  const factory _Loading() = _$LoadingImpl;
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
    extends _$ViewSeedPhraseStateCopyWithImpl<$Res, _$ErrorImpl>
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
    return 'ViewSeedPhraseState.error(error: $error)';
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
    required TResult Function(ViewSeedPhraseStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewSeedPhraseStateSuccess succcess) success,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewSeedPhraseStateSuccess succcess)? success,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewSeedPhraseStateSuccess succcess)? success,
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
    required TResult Function(_Loading value) loading,
    required TResult Function(_Error value) error,
    required TResult Function(_Success value) success,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Error value)? error,
    TResult? Function(_Success value)? success,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Error value)? error,
    TResult Function(_Success value)? success,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ViewSeedPhraseState {
  const factory _Error(final String error) = _$ErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl value, $Res Function(_$SuccessImpl) then) =
      __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ViewSeedPhraseStateSuccess succcess});

  $ViewSeedPhraseStateSuccessCopyWith<$Res> get succcess;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$ViewSeedPhraseStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl _value, $Res Function(_$SuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? succcess = null,
  }) {
    return _then(_$SuccessImpl(
      null == succcess
          ? _value.succcess
          : succcess // ignore: cast_nullable_to_non_nullable
              as ViewSeedPhraseStateSuccess,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $ViewSeedPhraseStateSuccessCopyWith<$Res> get succcess {
    return $ViewSeedPhraseStateSuccessCopyWith<$Res>(_value.succcess, (value) {
      return _then(_value.copyWith(succcess: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.succcess);

  @override
  final ViewSeedPhraseStateSuccess succcess;

  @override
  String toString() {
    return 'ViewSeedPhraseState.success(succcess: $succcess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.succcess, succcess) ||
                other.succcess == succcess));
  }

  @override
  int get hashCode => Object.hash(runtimeType, succcess);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ViewSeedPhraseStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewSeedPhraseStateSuccess succcess) success,
  }) {
    return success(succcess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewSeedPhraseStateSuccess succcess)? success,
  }) {
    return success?.call(succcess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewSeedPhraseStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewSeedPhraseStateSuccess succcess)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(succcess);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Error value) error,
    required TResult Function(_Success value) success,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Error value)? error,
    TResult? Function(_Success value)? success,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Error value)? error,
    TResult Function(_Success value)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements ViewSeedPhraseState {
  const factory _Success(final ViewSeedPhraseStateSuccess succcess) =
      _$SuccessImpl;

  ViewSeedPhraseStateSuccess get succcess;
  @JsonKey(ignore: true)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViewSeedPhraseStateInitial {
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ViewSeedPhraseStateInitialCopyWith<ViewSeedPhraseStateInitial>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewSeedPhraseStateInitialCopyWith<$Res> {
  factory $ViewSeedPhraseStateInitialCopyWith(ViewSeedPhraseStateInitial value,
          $Res Function(ViewSeedPhraseStateInitial) then) =
      _$ViewSeedPhraseStateInitialCopyWithImpl<$Res,
          ViewSeedPhraseStateInitial>;
  @useResult
  $Res call({String? error});
}

/// @nodoc
class _$ViewSeedPhraseStateInitialCopyWithImpl<$Res,
        $Val extends ViewSeedPhraseStateInitial>
    implements $ViewSeedPhraseStateInitialCopyWith<$Res> {
  _$ViewSeedPhraseStateInitialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewSeedPhraseStateInitialImplCopyWith<$Res>
    implements $ViewSeedPhraseStateInitialCopyWith<$Res> {
  factory _$$ViewSeedPhraseStateInitialImplCopyWith(
          _$ViewSeedPhraseStateInitialImpl value,
          $Res Function(_$ViewSeedPhraseStateInitialImpl) then) =
      __$$ViewSeedPhraseStateInitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? error});
}

/// @nodoc
class __$$ViewSeedPhraseStateInitialImplCopyWithImpl<$Res>
    extends _$ViewSeedPhraseStateInitialCopyWithImpl<$Res,
        _$ViewSeedPhraseStateInitialImpl>
    implements _$$ViewSeedPhraseStateInitialImplCopyWith<$Res> {
  __$$ViewSeedPhraseStateInitialImplCopyWithImpl(
      _$ViewSeedPhraseStateInitialImpl _value,
      $Res Function(_$ViewSeedPhraseStateInitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_$ViewSeedPhraseStateInitialImpl(
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ViewSeedPhraseStateInitialImpl implements _ViewSeedPhraseStateInitial {
  const _$ViewSeedPhraseStateInitialImpl({this.error});

  @override
  final String? error;

  @override
  String toString() {
    return 'ViewSeedPhraseStateInitial(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewSeedPhraseStateInitialImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewSeedPhraseStateInitialImplCopyWith<_$ViewSeedPhraseStateInitialImpl>
      get copyWith => __$$ViewSeedPhraseStateInitialImplCopyWithImpl<
          _$ViewSeedPhraseStateInitialImpl>(this, _$identity);
}

abstract class _ViewSeedPhraseStateInitial
    implements ViewSeedPhraseStateInitial {
  const factory _ViewSeedPhraseStateInitial({final String? error}) =
      _$ViewSeedPhraseStateInitialImpl;

  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ViewSeedPhraseStateInitialImplCopyWith<_$ViewSeedPhraseStateInitialImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViewSeedPhraseStateSuccess {
  String get seedPhrase => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ViewSeedPhraseStateSuccessCopyWith<ViewSeedPhraseStateSuccess>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewSeedPhraseStateSuccessCopyWith<$Res> {
  factory $ViewSeedPhraseStateSuccessCopyWith(ViewSeedPhraseStateSuccess value,
          $Res Function(ViewSeedPhraseStateSuccess) then) =
      _$ViewSeedPhraseStateSuccessCopyWithImpl<$Res,
          ViewSeedPhraseStateSuccess>;
  @useResult
  $Res call({String seedPhrase});
}

/// @nodoc
class _$ViewSeedPhraseStateSuccessCopyWithImpl<$Res,
        $Val extends ViewSeedPhraseStateSuccess>
    implements $ViewSeedPhraseStateSuccessCopyWith<$Res> {
  _$ViewSeedPhraseStateSuccessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seedPhrase = null,
  }) {
    return _then(_value.copyWith(
      seedPhrase: null == seedPhrase
          ? _value.seedPhrase
          : seedPhrase // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewSeedPhraseStateSuccessImplCopyWith<$Res>
    implements $ViewSeedPhraseStateSuccessCopyWith<$Res> {
  factory _$$ViewSeedPhraseStateSuccessImplCopyWith(
          _$ViewSeedPhraseStateSuccessImpl value,
          $Res Function(_$ViewSeedPhraseStateSuccessImpl) then) =
      __$$ViewSeedPhraseStateSuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String seedPhrase});
}

/// @nodoc
class __$$ViewSeedPhraseStateSuccessImplCopyWithImpl<$Res>
    extends _$ViewSeedPhraseStateSuccessCopyWithImpl<$Res,
        _$ViewSeedPhraseStateSuccessImpl>
    implements _$$ViewSeedPhraseStateSuccessImplCopyWith<$Res> {
  __$$ViewSeedPhraseStateSuccessImplCopyWithImpl(
      _$ViewSeedPhraseStateSuccessImpl _value,
      $Res Function(_$ViewSeedPhraseStateSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seedPhrase = null,
  }) {
    return _then(_$ViewSeedPhraseStateSuccessImpl(
      seedPhrase: null == seedPhrase
          ? _value.seedPhrase
          : seedPhrase // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ViewSeedPhraseStateSuccessImpl implements _ViewSeedPhraseStateSuccess {
  const _$ViewSeedPhraseStateSuccessImpl({required this.seedPhrase});

  @override
  final String seedPhrase;

  @override
  String toString() {
    return 'ViewSeedPhraseStateSuccess(seedPhrase: $seedPhrase)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewSeedPhraseStateSuccessImpl &&
            (identical(other.seedPhrase, seedPhrase) ||
                other.seedPhrase == seedPhrase));
  }

  @override
  int get hashCode => Object.hash(runtimeType, seedPhrase);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewSeedPhraseStateSuccessImplCopyWith<_$ViewSeedPhraseStateSuccessImpl>
      get copyWith => __$$ViewSeedPhraseStateSuccessImplCopyWithImpl<
          _$ViewSeedPhraseStateSuccessImpl>(this, _$identity);
}

abstract class _ViewSeedPhraseStateSuccess
    implements ViewSeedPhraseStateSuccess {
  const factory _ViewSeedPhraseStateSuccess(
      {required final String seedPhrase}) = _$ViewSeedPhraseStateSuccessImpl;

  @override
  String get seedPhrase;
  @override
  @JsonKey(ignore: true)
  _$$ViewSeedPhraseStateSuccessImplCopyWith<_$ViewSeedPhraseStateSuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}
