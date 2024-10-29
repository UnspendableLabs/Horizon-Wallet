// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_address_pk_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ViewAddressPkState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ViewAddressPkStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewAddressPkStateSuccess succcess) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewAddressPkStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewAddressPkStateSuccess succcess)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewAddressPkStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewAddressPkStateSuccess succcess)? success,
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
abstract class $ViewAddressPkStateCopyWith<$Res> {
  factory $ViewAddressPkStateCopyWith(
          ViewAddressPkState value, $Res Function(ViewAddressPkState) then) =
      _$ViewAddressPkStateCopyWithImpl<$Res, ViewAddressPkState>;
}

/// @nodoc
class _$ViewAddressPkStateCopyWithImpl<$Res, $Val extends ViewAddressPkState>
    implements $ViewAddressPkStateCopyWith<$Res> {
  _$ViewAddressPkStateCopyWithImpl(this._value, this._then);

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
  $Res call({ViewAddressPkStateInitial initial});

  $ViewAddressPkStateInitialCopyWith<$Res> get initial;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ViewAddressPkStateCopyWithImpl<$Res, _$InitialImpl>
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
              as ViewAddressPkStateInitial,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $ViewAddressPkStateInitialCopyWith<$Res> get initial {
    return $ViewAddressPkStateInitialCopyWith<$Res>(_value.initial, (value) {
      return _then(_value.copyWith(initial: value));
    });
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(this.initial);

  @override
  final ViewAddressPkStateInitial initial;

  @override
  String toString() {
    return 'ViewAddressPkState.initial(initial: $initial)';
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
    required TResult Function(ViewAddressPkStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewAddressPkStateSuccess succcess) success,
  }) {
    return initial(this.initial);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewAddressPkStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewAddressPkStateSuccess succcess)? success,
  }) {
    return initial?.call(this.initial);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewAddressPkStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewAddressPkStateSuccess succcess)? success,
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

abstract class _Initial implements ViewAddressPkState {
  const factory _Initial(final ViewAddressPkStateInitial initial) =
      _$InitialImpl;

  ViewAddressPkStateInitial get initial;
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
    extends _$ViewAddressPkStateCopyWithImpl<$Res, _$LoadingImpl>
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
    return 'ViewAddressPkState.loading()';
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
    required TResult Function(ViewAddressPkStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewAddressPkStateSuccess succcess) success,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewAddressPkStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewAddressPkStateSuccess succcess)? success,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewAddressPkStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewAddressPkStateSuccess succcess)? success,
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

abstract class _Loading implements ViewAddressPkState {
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
    extends _$ViewAddressPkStateCopyWithImpl<$Res, _$ErrorImpl>
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
    return 'ViewAddressPkState.error(error: $error)';
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
    required TResult Function(ViewAddressPkStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewAddressPkStateSuccess succcess) success,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewAddressPkStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewAddressPkStateSuccess succcess)? success,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewAddressPkStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewAddressPkStateSuccess succcess)? success,
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

abstract class _Error implements ViewAddressPkState {
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
  $Res call({ViewAddressPkStateSuccess succcess});

  $ViewAddressPkStateSuccessCopyWith<$Res> get succcess;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$ViewAddressPkStateCopyWithImpl<$Res, _$SuccessImpl>
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
              as ViewAddressPkStateSuccess,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $ViewAddressPkStateSuccessCopyWith<$Res> get succcess {
    return $ViewAddressPkStateSuccessCopyWith<$Res>(_value.succcess, (value) {
      return _then(_value.copyWith(succcess: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.succcess);

  @override
  final ViewAddressPkStateSuccess succcess;

  @override
  String toString() {
    return 'ViewAddressPkState.success(succcess: $succcess)';
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
    required TResult Function(ViewAddressPkStateInitial initial) initial,
    required TResult Function() loading,
    required TResult Function(String error) error,
    required TResult Function(ViewAddressPkStateSuccess succcess) success,
  }) {
    return success(succcess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ViewAddressPkStateInitial initial)? initial,
    TResult? Function()? loading,
    TResult? Function(String error)? error,
    TResult? Function(ViewAddressPkStateSuccess succcess)? success,
  }) {
    return success?.call(succcess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ViewAddressPkStateInitial initial)? initial,
    TResult Function()? loading,
    TResult Function(String error)? error,
    TResult Function(ViewAddressPkStateSuccess succcess)? success,
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

abstract class _Success implements ViewAddressPkState {
  const factory _Success(final ViewAddressPkStateSuccess succcess) =
      _$SuccessImpl;

  ViewAddressPkStateSuccess get succcess;
  @JsonKey(ignore: true)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViewAddressPkStateInitial {
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ViewAddressPkStateInitialCopyWith<ViewAddressPkStateInitial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewAddressPkStateInitialCopyWith<$Res> {
  factory $ViewAddressPkStateInitialCopyWith(ViewAddressPkStateInitial value,
          $Res Function(ViewAddressPkStateInitial) then) =
      _$ViewAddressPkStateInitialCopyWithImpl<$Res, ViewAddressPkStateInitial>;
  @useResult
  $Res call({String? error});
}

/// @nodoc
class _$ViewAddressPkStateInitialCopyWithImpl<$Res,
        $Val extends ViewAddressPkStateInitial>
    implements $ViewAddressPkStateInitialCopyWith<$Res> {
  _$ViewAddressPkStateInitialCopyWithImpl(this._value, this._then);

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
abstract class _$$ViewAddressPkStateInitialImplCopyWith<$Res>
    implements $ViewAddressPkStateInitialCopyWith<$Res> {
  factory _$$ViewAddressPkStateInitialImplCopyWith(
          _$ViewAddressPkStateInitialImpl value,
          $Res Function(_$ViewAddressPkStateInitialImpl) then) =
      __$$ViewAddressPkStateInitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? error});
}

/// @nodoc
class __$$ViewAddressPkStateInitialImplCopyWithImpl<$Res>
    extends _$ViewAddressPkStateInitialCopyWithImpl<$Res,
        _$ViewAddressPkStateInitialImpl>
    implements _$$ViewAddressPkStateInitialImplCopyWith<$Res> {
  __$$ViewAddressPkStateInitialImplCopyWithImpl(
      _$ViewAddressPkStateInitialImpl _value,
      $Res Function(_$ViewAddressPkStateInitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_$ViewAddressPkStateInitialImpl(
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ViewAddressPkStateInitialImpl implements _ViewAddressPkStateInitial {
  const _$ViewAddressPkStateInitialImpl({this.error});

  @override
  final String? error;

  @override
  String toString() {
    return 'ViewAddressPkStateInitial(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewAddressPkStateInitialImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewAddressPkStateInitialImplCopyWith<_$ViewAddressPkStateInitialImpl>
      get copyWith => __$$ViewAddressPkStateInitialImplCopyWithImpl<
          _$ViewAddressPkStateInitialImpl>(this, _$identity);
}

abstract class _ViewAddressPkStateInitial implements ViewAddressPkStateInitial {
  const factory _ViewAddressPkStateInitial({final String? error}) =
      _$ViewAddressPkStateInitialImpl;

  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ViewAddressPkStateInitialImplCopyWith<_$ViewAddressPkStateInitialImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViewAddressPkStateSuccess {
  String get address => throw _privateConstructorUsedError;
  String get privateKeyWif => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ViewAddressPkStateSuccessCopyWith<ViewAddressPkStateSuccess> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewAddressPkStateSuccessCopyWith<$Res> {
  factory $ViewAddressPkStateSuccessCopyWith(ViewAddressPkStateSuccess value,
          $Res Function(ViewAddressPkStateSuccess) then) =
      _$ViewAddressPkStateSuccessCopyWithImpl<$Res, ViewAddressPkStateSuccess>;
  @useResult
  $Res call({String address, String privateKeyWif});
}

/// @nodoc
class _$ViewAddressPkStateSuccessCopyWithImpl<$Res,
        $Val extends ViewAddressPkStateSuccess>
    implements $ViewAddressPkStateSuccessCopyWith<$Res> {
  _$ViewAddressPkStateSuccessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? privateKeyWif = null,
  }) {
    return _then(_value.copyWith(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      privateKeyWif: null == privateKeyWif
          ? _value.privateKeyWif
          : privateKeyWif // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewAddressPkStateSuccessImplCopyWith<$Res>
    implements $ViewAddressPkStateSuccessCopyWith<$Res> {
  factory _$$ViewAddressPkStateSuccessImplCopyWith(
          _$ViewAddressPkStateSuccessImpl value,
          $Res Function(_$ViewAddressPkStateSuccessImpl) then) =
      __$$ViewAddressPkStateSuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String address, String privateKeyWif});
}

/// @nodoc
class __$$ViewAddressPkStateSuccessImplCopyWithImpl<$Res>
    extends _$ViewAddressPkStateSuccessCopyWithImpl<$Res,
        _$ViewAddressPkStateSuccessImpl>
    implements _$$ViewAddressPkStateSuccessImplCopyWith<$Res> {
  __$$ViewAddressPkStateSuccessImplCopyWithImpl(
      _$ViewAddressPkStateSuccessImpl _value,
      $Res Function(_$ViewAddressPkStateSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? privateKeyWif = null,
  }) {
    return _then(_$ViewAddressPkStateSuccessImpl(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      privateKeyWif: null == privateKeyWif
          ? _value.privateKeyWif
          : privateKeyWif // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ViewAddressPkStateSuccessImpl implements _ViewAddressPkStateSuccess {
  const _$ViewAddressPkStateSuccessImpl(
      {required this.address, required this.privateKeyWif});

  @override
  final String address;
  @override
  final String privateKeyWif;

  @override
  String toString() {
    return 'ViewAddressPkStateSuccess(address: $address, privateKeyWif: $privateKeyWif)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewAddressPkStateSuccessImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.privateKeyWif, privateKeyWif) ||
                other.privateKeyWif == privateKeyWif));
  }

  @override
  int get hashCode => Object.hash(runtimeType, address, privateKeyWif);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewAddressPkStateSuccessImplCopyWith<_$ViewAddressPkStateSuccessImpl>
      get copyWith => __$$ViewAddressPkStateSuccessImplCopyWithImpl<
          _$ViewAddressPkStateSuccessImpl>(this, _$identity);
}

abstract class _ViewAddressPkStateSuccess implements ViewAddressPkStateSuccess {
  const factory _ViewAddressPkStateSuccess(
      {required final String address,
      required final String privateKeyWif}) = _$ViewAddressPkStateSuccessImpl;

  @override
  String get address;
  @override
  String get privateKeyWif;
  @override
  @JsonKey(ignore: true)
  _$$ViewAddressPkStateSuccessImplCopyWith<_$ViewAddressPkStateSuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}
