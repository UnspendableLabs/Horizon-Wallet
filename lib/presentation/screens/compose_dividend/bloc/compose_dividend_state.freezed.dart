// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_dividend_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeDividendState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState =>
      throw _privateConstructorUsedError; // dividend specific properties
  AssetState get assetState => throw _privateConstructorUsedError;
  DividendXcpFeeState get dividendXcpFeeState =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeDividendStateCopyWith<ComposeDividendState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeDividendStateCopyWith<$Res> {
  factory $ComposeDividendStateCopyWith(ComposeDividendState value,
          $Res Function(ComposeDividendState) then) =
      _$ComposeDividendStateCopyWithImpl<$Res, ComposeDividendState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      AssetState assetState,
      DividendXcpFeeState dividendXcpFeeState});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
  $AssetStateCopyWith<$Res> get assetState;
  $DividendXcpFeeStateCopyWith<$Res> get dividendXcpFeeState;
}

/// @nodoc
class _$ComposeDividendStateCopyWithImpl<$Res,
        $Val extends ComposeDividendState>
    implements $ComposeDividendStateCopyWith<$Res> {
  _$ComposeDividendStateCopyWithImpl(this._value, this._then);

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
    Object? assetState = null,
    Object? dividendXcpFeeState = null,
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
      assetState: null == assetState
          ? _value.assetState
          : assetState // ignore: cast_nullable_to_non_nullable
              as AssetState,
      dividendXcpFeeState: null == dividendXcpFeeState
          ? _value.dividendXcpFeeState
          : dividendXcpFeeState // ignore: cast_nullable_to_non_nullable
              as DividendXcpFeeState,
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

  @override
  @pragma('vm:prefer-inline')
  $AssetStateCopyWith<$Res> get assetState {
    return $AssetStateCopyWith<$Res>(_value.assetState, (value) {
      return _then(_value.copyWith(assetState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DividendXcpFeeStateCopyWith<$Res> get dividendXcpFeeState {
    return $DividendXcpFeeStateCopyWith<$Res>(_value.dividendXcpFeeState,
        (value) {
      return _then(_value.copyWith(dividendXcpFeeState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComposeDividendStateImplCopyWith<$Res>
    implements $ComposeDividendStateCopyWith<$Res> {
  factory _$$ComposeDividendStateImplCopyWith(_$ComposeDividendStateImpl value,
          $Res Function(_$ComposeDividendStateImpl) then) =
      __$$ComposeDividendStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      AssetState assetState,
      DividendXcpFeeState dividendXcpFeeState});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
  @override
  $AssetStateCopyWith<$Res> get assetState;
  @override
  $DividendXcpFeeStateCopyWith<$Res> get dividendXcpFeeState;
}

/// @nodoc
class __$$ComposeDividendStateImplCopyWithImpl<$Res>
    extends _$ComposeDividendStateCopyWithImpl<$Res, _$ComposeDividendStateImpl>
    implements _$$ComposeDividendStateImplCopyWith<$Res> {
  __$$ComposeDividendStateImplCopyWithImpl(_$ComposeDividendStateImpl _value,
      $Res Function(_$ComposeDividendStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? assetState = null,
    Object? dividendXcpFeeState = null,
  }) {
    return _then(_$ComposeDividendStateImpl(
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
      assetState: null == assetState
          ? _value.assetState
          : assetState // ignore: cast_nullable_to_non_nullable
              as AssetState,
      dividendXcpFeeState: null == dividendXcpFeeState
          ? _value.dividendXcpFeeState
          : dividendXcpFeeState // ignore: cast_nullable_to_non_nullable
              as DividendXcpFeeState,
    ));
  }
}

/// @nodoc

class _$ComposeDividendStateImpl extends _ComposeDividendState {
  const _$ComposeDividendStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      required this.assetState,
      required this.dividendXcpFeeState})
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
// dividend specific properties
  @override
  final AssetState assetState;
  @override
  final DividendXcpFeeState dividendXcpFeeState;

  @override
  String toString() {
    return 'ComposeDividendState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, assetState: $assetState, dividendXcpFeeState: $dividendXcpFeeState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeDividendStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState) &&
            (identical(other.assetState, assetState) ||
                other.assetState == assetState) &&
            (identical(other.dividendXcpFeeState, dividendXcpFeeState) ||
                other.dividendXcpFeeState == dividendXcpFeeState));
  }

  @override
  int get hashCode => Object.hash(runtimeType, feeState, balancesState,
      feeOption, submitState, assetState, dividendXcpFeeState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeDividendStateImplCopyWith<_$ComposeDividendStateImpl>
      get copyWith =>
          __$$ComposeDividendStateImplCopyWithImpl<_$ComposeDividendStateImpl>(
              this, _$identity);
}

abstract class _ComposeDividendState extends ComposeDividendState {
  const factory _ComposeDividendState(
          {required final FeeState feeState,
          required final BalancesState balancesState,
          required final FeeOption feeOption,
          required final SubmitState submitState,
          required final AssetState assetState,
          required final DividendXcpFeeState dividendXcpFeeState}) =
      _$ComposeDividendStateImpl;
  const _ComposeDividendState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override // dividend specific properties
  AssetState get assetState;
  @override
  DividendXcpFeeState get dividendXcpFeeState;
  @override
  @JsonKey(ignore: true)
  _$$ComposeDividendStateImplCopyWith<_$ComposeDividendStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssetState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Asset asset) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Asset asset)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Asset asset)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AssetInitial value) initial,
    required TResult Function(_AssetLoading value) loading,
    required TResult Function(_AssetSuccess value) success,
    required TResult Function(_AssetError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AssetInitial value)? initial,
    TResult? Function(_AssetLoading value)? loading,
    TResult? Function(_AssetSuccess value)? success,
    TResult? Function(_AssetError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AssetInitial value)? initial,
    TResult Function(_AssetLoading value)? loading,
    TResult Function(_AssetSuccess value)? success,
    TResult Function(_AssetError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetStateCopyWith<$Res> {
  factory $AssetStateCopyWith(
          AssetState value, $Res Function(AssetState) then) =
      _$AssetStateCopyWithImpl<$Res, AssetState>;
}

/// @nodoc
class _$AssetStateCopyWithImpl<$Res, $Val extends AssetState>
    implements $AssetStateCopyWith<$Res> {
  _$AssetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AssetInitialImplCopyWith<$Res> {
  factory _$$AssetInitialImplCopyWith(
          _$AssetInitialImpl value, $Res Function(_$AssetInitialImpl) then) =
      __$$AssetInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AssetInitialImplCopyWithImpl<$Res>
    extends _$AssetStateCopyWithImpl<$Res, _$AssetInitialImpl>
    implements _$$AssetInitialImplCopyWith<$Res> {
  __$$AssetInitialImplCopyWithImpl(
      _$AssetInitialImpl _value, $Res Function(_$AssetInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AssetInitialImpl implements _AssetInitial {
  const _$AssetInitialImpl();

  @override
  String toString() {
    return 'AssetState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AssetInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Asset asset) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Asset asset)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Asset asset)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AssetInitial value) initial,
    required TResult Function(_AssetLoading value) loading,
    required TResult Function(_AssetSuccess value) success,
    required TResult Function(_AssetError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AssetInitial value)? initial,
    TResult? Function(_AssetLoading value)? loading,
    TResult? Function(_AssetSuccess value)? success,
    TResult? Function(_AssetError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AssetInitial value)? initial,
    TResult Function(_AssetLoading value)? loading,
    TResult Function(_AssetSuccess value)? success,
    TResult Function(_AssetError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _AssetInitial implements AssetState {
  const factory _AssetInitial() = _$AssetInitialImpl;
}

/// @nodoc
abstract class _$$AssetLoadingImplCopyWith<$Res> {
  factory _$$AssetLoadingImplCopyWith(
          _$AssetLoadingImpl value, $Res Function(_$AssetLoadingImpl) then) =
      __$$AssetLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AssetLoadingImplCopyWithImpl<$Res>
    extends _$AssetStateCopyWithImpl<$Res, _$AssetLoadingImpl>
    implements _$$AssetLoadingImplCopyWith<$Res> {
  __$$AssetLoadingImplCopyWithImpl(
      _$AssetLoadingImpl _value, $Res Function(_$AssetLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AssetLoadingImpl implements _AssetLoading {
  const _$AssetLoadingImpl();

  @override
  String toString() {
    return 'AssetState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AssetLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Asset asset) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Asset asset)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Asset asset)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_AssetInitial value) initial,
    required TResult Function(_AssetLoading value) loading,
    required TResult Function(_AssetSuccess value) success,
    required TResult Function(_AssetError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AssetInitial value)? initial,
    TResult? Function(_AssetLoading value)? loading,
    TResult? Function(_AssetSuccess value)? success,
    TResult? Function(_AssetError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AssetInitial value)? initial,
    TResult Function(_AssetLoading value)? loading,
    TResult Function(_AssetSuccess value)? success,
    TResult Function(_AssetError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _AssetLoading implements AssetState {
  const factory _AssetLoading() = _$AssetLoadingImpl;
}

/// @nodoc
abstract class _$$AssetSuccessImplCopyWith<$Res> {
  factory _$$AssetSuccessImplCopyWith(
          _$AssetSuccessImpl value, $Res Function(_$AssetSuccessImpl) then) =
      __$$AssetSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Asset asset});
}

/// @nodoc
class __$$AssetSuccessImplCopyWithImpl<$Res>
    extends _$AssetStateCopyWithImpl<$Res, _$AssetSuccessImpl>
    implements _$$AssetSuccessImplCopyWith<$Res> {
  __$$AssetSuccessImplCopyWithImpl(
      _$AssetSuccessImpl _value, $Res Function(_$AssetSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? asset = null,
  }) {
    return _then(_$AssetSuccessImpl(
      null == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as Asset,
    ));
  }
}

/// @nodoc

class _$AssetSuccessImpl implements _AssetSuccess {
  const _$AssetSuccessImpl(this.asset);

  @override
  final Asset asset;

  @override
  String toString() {
    return 'AssetState.success(asset: $asset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetSuccessImpl &&
            (identical(other.asset, asset) || other.asset == asset));
  }

  @override
  int get hashCode => Object.hash(runtimeType, asset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetSuccessImplCopyWith<_$AssetSuccessImpl> get copyWith =>
      __$$AssetSuccessImplCopyWithImpl<_$AssetSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Asset asset) success,
    required TResult Function(String error) error,
  }) {
    return success(asset);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Asset asset)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(asset);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Asset asset)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(asset);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AssetInitial value) initial,
    required TResult Function(_AssetLoading value) loading,
    required TResult Function(_AssetSuccess value) success,
    required TResult Function(_AssetError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AssetInitial value)? initial,
    TResult? Function(_AssetLoading value)? loading,
    TResult? Function(_AssetSuccess value)? success,
    TResult? Function(_AssetError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AssetInitial value)? initial,
    TResult Function(_AssetLoading value)? loading,
    TResult Function(_AssetSuccess value)? success,
    TResult Function(_AssetError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _AssetSuccess implements AssetState {
  const factory _AssetSuccess(final Asset asset) = _$AssetSuccessImpl;

  Asset get asset;
  @JsonKey(ignore: true)
  _$$AssetSuccessImplCopyWith<_$AssetSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssetErrorImplCopyWith<$Res> {
  factory _$$AssetErrorImplCopyWith(
          _$AssetErrorImpl value, $Res Function(_$AssetErrorImpl) then) =
      __$$AssetErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$AssetErrorImplCopyWithImpl<$Res>
    extends _$AssetStateCopyWithImpl<$Res, _$AssetErrorImpl>
    implements _$$AssetErrorImplCopyWith<$Res> {
  __$$AssetErrorImplCopyWithImpl(
      _$AssetErrorImpl _value, $Res Function(_$AssetErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$AssetErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AssetErrorImpl implements _AssetError {
  const _$AssetErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'AssetState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetErrorImplCopyWith<_$AssetErrorImpl> get copyWith =>
      __$$AssetErrorImplCopyWithImpl<_$AssetErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Asset asset) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Asset asset)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Asset asset)? success,
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
    required TResult Function(_AssetInitial value) initial,
    required TResult Function(_AssetLoading value) loading,
    required TResult Function(_AssetSuccess value) success,
    required TResult Function(_AssetError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AssetInitial value)? initial,
    TResult? Function(_AssetLoading value)? loading,
    TResult? Function(_AssetSuccess value)? success,
    TResult? Function(_AssetError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AssetInitial value)? initial,
    TResult Function(_AssetLoading value)? loading,
    TResult Function(_AssetSuccess value)? success,
    TResult Function(_AssetError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _AssetError implements AssetState {
  const factory _AssetError(final String error) = _$AssetErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$AssetErrorImplCopyWith<_$AssetErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DividendXcpFeeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int dividendXcpFee) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int dividendXcpFee)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int dividendXcpFee)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DividendXcpFeeInitial value) initial,
    required TResult Function(_DividendXcpFeeLoading value) loading,
    required TResult Function(_DividendXcpFeeSuccess value) success,
    required TResult Function(_DividendXcpFeeError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DividendXcpFeeInitial value)? initial,
    TResult? Function(_DividendXcpFeeLoading value)? loading,
    TResult? Function(_DividendXcpFeeSuccess value)? success,
    TResult? Function(_DividendXcpFeeError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DividendXcpFeeInitial value)? initial,
    TResult Function(_DividendXcpFeeLoading value)? loading,
    TResult Function(_DividendXcpFeeSuccess value)? success,
    TResult Function(_DividendXcpFeeError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DividendXcpFeeStateCopyWith<$Res> {
  factory $DividendXcpFeeStateCopyWith(
          DividendXcpFeeState value, $Res Function(DividendXcpFeeState) then) =
      _$DividendXcpFeeStateCopyWithImpl<$Res, DividendXcpFeeState>;
}

/// @nodoc
class _$DividendXcpFeeStateCopyWithImpl<$Res, $Val extends DividendXcpFeeState>
    implements $DividendXcpFeeStateCopyWith<$Res> {
  _$DividendXcpFeeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DividendXcpFeeInitialImplCopyWith<$Res> {
  factory _$$DividendXcpFeeInitialImplCopyWith(
          _$DividendXcpFeeInitialImpl value,
          $Res Function(_$DividendXcpFeeInitialImpl) then) =
      __$$DividendXcpFeeInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DividendXcpFeeInitialImplCopyWithImpl<$Res>
    extends _$DividendXcpFeeStateCopyWithImpl<$Res, _$DividendXcpFeeInitialImpl>
    implements _$$DividendXcpFeeInitialImplCopyWith<$Res> {
  __$$DividendXcpFeeInitialImplCopyWithImpl(_$DividendXcpFeeInitialImpl _value,
      $Res Function(_$DividendXcpFeeInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DividendXcpFeeInitialImpl implements _DividendXcpFeeInitial {
  const _$DividendXcpFeeInitialImpl();

  @override
  String toString() {
    return 'DividendXcpFeeState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DividendXcpFeeInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int dividendXcpFee) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int dividendXcpFee)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int dividendXcpFee)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DividendXcpFeeInitial value) initial,
    required TResult Function(_DividendXcpFeeLoading value) loading,
    required TResult Function(_DividendXcpFeeSuccess value) success,
    required TResult Function(_DividendXcpFeeError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DividendXcpFeeInitial value)? initial,
    TResult? Function(_DividendXcpFeeLoading value)? loading,
    TResult? Function(_DividendXcpFeeSuccess value)? success,
    TResult? Function(_DividendXcpFeeError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DividendXcpFeeInitial value)? initial,
    TResult Function(_DividendXcpFeeLoading value)? loading,
    TResult Function(_DividendXcpFeeSuccess value)? success,
    TResult Function(_DividendXcpFeeError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _DividendXcpFeeInitial implements DividendXcpFeeState {
  const factory _DividendXcpFeeInitial() = _$DividendXcpFeeInitialImpl;
}

/// @nodoc
abstract class _$$DividendXcpFeeLoadingImplCopyWith<$Res> {
  factory _$$DividendXcpFeeLoadingImplCopyWith(
          _$DividendXcpFeeLoadingImpl value,
          $Res Function(_$DividendXcpFeeLoadingImpl) then) =
      __$$DividendXcpFeeLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DividendXcpFeeLoadingImplCopyWithImpl<$Res>
    extends _$DividendXcpFeeStateCopyWithImpl<$Res, _$DividendXcpFeeLoadingImpl>
    implements _$$DividendXcpFeeLoadingImplCopyWith<$Res> {
  __$$DividendXcpFeeLoadingImplCopyWithImpl(_$DividendXcpFeeLoadingImpl _value,
      $Res Function(_$DividendXcpFeeLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DividendXcpFeeLoadingImpl implements _DividendXcpFeeLoading {
  const _$DividendXcpFeeLoadingImpl();

  @override
  String toString() {
    return 'DividendXcpFeeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DividendXcpFeeLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int dividendXcpFee) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int dividendXcpFee)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int dividendXcpFee)? success,
    TResult Function(String error)? error,
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
    required TResult Function(_DividendXcpFeeInitial value) initial,
    required TResult Function(_DividendXcpFeeLoading value) loading,
    required TResult Function(_DividendXcpFeeSuccess value) success,
    required TResult Function(_DividendXcpFeeError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DividendXcpFeeInitial value)? initial,
    TResult? Function(_DividendXcpFeeLoading value)? loading,
    TResult? Function(_DividendXcpFeeSuccess value)? success,
    TResult? Function(_DividendXcpFeeError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DividendXcpFeeInitial value)? initial,
    TResult Function(_DividendXcpFeeLoading value)? loading,
    TResult Function(_DividendXcpFeeSuccess value)? success,
    TResult Function(_DividendXcpFeeError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _DividendXcpFeeLoading implements DividendXcpFeeState {
  const factory _DividendXcpFeeLoading() = _$DividendXcpFeeLoadingImpl;
}

/// @nodoc
abstract class _$$DividendXcpFeeSuccessImplCopyWith<$Res> {
  factory _$$DividendXcpFeeSuccessImplCopyWith(
          _$DividendXcpFeeSuccessImpl value,
          $Res Function(_$DividendXcpFeeSuccessImpl) then) =
      __$$DividendXcpFeeSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int dividendXcpFee});
}

/// @nodoc
class __$$DividendXcpFeeSuccessImplCopyWithImpl<$Res>
    extends _$DividendXcpFeeStateCopyWithImpl<$Res, _$DividendXcpFeeSuccessImpl>
    implements _$$DividendXcpFeeSuccessImplCopyWith<$Res> {
  __$$DividendXcpFeeSuccessImplCopyWithImpl(_$DividendXcpFeeSuccessImpl _value,
      $Res Function(_$DividendXcpFeeSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dividendXcpFee = null,
  }) {
    return _then(_$DividendXcpFeeSuccessImpl(
      null == dividendXcpFee
          ? _value.dividendXcpFee
          : dividendXcpFee // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DividendXcpFeeSuccessImpl implements _DividendXcpFeeSuccess {
  const _$DividendXcpFeeSuccessImpl(this.dividendXcpFee);

  @override
  final int dividendXcpFee;

  @override
  String toString() {
    return 'DividendXcpFeeState.success(dividendXcpFee: $dividendXcpFee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DividendXcpFeeSuccessImpl &&
            (identical(other.dividendXcpFee, dividendXcpFee) ||
                other.dividendXcpFee == dividendXcpFee));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dividendXcpFee);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DividendXcpFeeSuccessImplCopyWith<_$DividendXcpFeeSuccessImpl>
      get copyWith => __$$DividendXcpFeeSuccessImplCopyWithImpl<
          _$DividendXcpFeeSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int dividendXcpFee) success,
    required TResult Function(String error) error,
  }) {
    return success(dividendXcpFee);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int dividendXcpFee)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(dividendXcpFee);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int dividendXcpFee)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(dividendXcpFee);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DividendXcpFeeInitial value) initial,
    required TResult Function(_DividendXcpFeeLoading value) loading,
    required TResult Function(_DividendXcpFeeSuccess value) success,
    required TResult Function(_DividendXcpFeeError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DividendXcpFeeInitial value)? initial,
    TResult? Function(_DividendXcpFeeLoading value)? loading,
    TResult? Function(_DividendXcpFeeSuccess value)? success,
    TResult? Function(_DividendXcpFeeError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DividendXcpFeeInitial value)? initial,
    TResult Function(_DividendXcpFeeLoading value)? loading,
    TResult Function(_DividendXcpFeeSuccess value)? success,
    TResult Function(_DividendXcpFeeError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _DividendXcpFeeSuccess implements DividendXcpFeeState {
  const factory _DividendXcpFeeSuccess(final int dividendXcpFee) =
      _$DividendXcpFeeSuccessImpl;

  int get dividendXcpFee;
  @JsonKey(ignore: true)
  _$$DividendXcpFeeSuccessImplCopyWith<_$DividendXcpFeeSuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DividendXcpFeeErrorImplCopyWith<$Res> {
  factory _$$DividendXcpFeeErrorImplCopyWith(_$DividendXcpFeeErrorImpl value,
          $Res Function(_$DividendXcpFeeErrorImpl) then) =
      __$$DividendXcpFeeErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$DividendXcpFeeErrorImplCopyWithImpl<$Res>
    extends _$DividendXcpFeeStateCopyWithImpl<$Res, _$DividendXcpFeeErrorImpl>
    implements _$$DividendXcpFeeErrorImplCopyWith<$Res> {
  __$$DividendXcpFeeErrorImplCopyWithImpl(_$DividendXcpFeeErrorImpl _value,
      $Res Function(_$DividendXcpFeeErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$DividendXcpFeeErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DividendXcpFeeErrorImpl implements _DividendXcpFeeError {
  const _$DividendXcpFeeErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'DividendXcpFeeState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DividendXcpFeeErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DividendXcpFeeErrorImplCopyWith<_$DividendXcpFeeErrorImpl> get copyWith =>
      __$$DividendXcpFeeErrorImplCopyWithImpl<_$DividendXcpFeeErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int dividendXcpFee) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int dividendXcpFee)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int dividendXcpFee)? success,
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
    required TResult Function(_DividendXcpFeeInitial value) initial,
    required TResult Function(_DividendXcpFeeLoading value) loading,
    required TResult Function(_DividendXcpFeeSuccess value) success,
    required TResult Function(_DividendXcpFeeError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DividendXcpFeeInitial value)? initial,
    TResult? Function(_DividendXcpFeeLoading value)? loading,
    TResult? Function(_DividendXcpFeeSuccess value)? success,
    TResult? Function(_DividendXcpFeeError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DividendXcpFeeInitial value)? initial,
    TResult Function(_DividendXcpFeeLoading value)? loading,
    TResult Function(_DividendXcpFeeSuccess value)? success,
    TResult Function(_DividendXcpFeeError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _DividendXcpFeeError implements DividendXcpFeeState {
  const factory _DividendXcpFeeError(final String error) =
      _$DividendXcpFeeErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$DividendXcpFeeErrorImplCopyWith<_$DividendXcpFeeErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
