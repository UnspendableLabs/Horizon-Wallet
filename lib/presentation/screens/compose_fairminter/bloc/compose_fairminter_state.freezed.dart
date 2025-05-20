// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_fairminter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeFairminterState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState =>
      throw _privateConstructorUsedError; // Fairminter specific properties
  AssetState get assetState => throw _privateConstructorUsedError;
  FairmintersState get fairmintersState => throw _privateConstructorUsedError;

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComposeFairminterStateCopyWith<ComposeFairminterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeFairminterStateCopyWith<$Res> {
  factory $ComposeFairminterStateCopyWith(ComposeFairminterState value,
          $Res Function(ComposeFairminterState) then) =
      _$ComposeFairminterStateCopyWithImpl<$Res, ComposeFairminterState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      AssetState assetState,
      FairmintersState fairmintersState});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
  $AssetStateCopyWith<$Res> get assetState;
  $FairmintersStateCopyWith<$Res> get fairmintersState;
}

/// @nodoc
class _$ComposeFairminterStateCopyWithImpl<$Res,
        $Val extends ComposeFairminterState>
    implements $ComposeFairminterStateCopyWith<$Res> {
  _$ComposeFairminterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? assetState = null,
    Object? fairmintersState = null,
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
      fairmintersState: null == fairmintersState
          ? _value.fairmintersState
          : fairmintersState // ignore: cast_nullable_to_non_nullable
              as FairmintersState,
    ) as $Val);
  }

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeeStateCopyWith<$Res> get feeState {
    return $FeeStateCopyWith<$Res>(_value.feeState, (value) {
      return _then(_value.copyWith(feeState: value) as $Val);
    });
  }

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BalancesStateCopyWith<$Res> get balancesState {
    return $BalancesStateCopyWith<$Res>(_value.balancesState, (value) {
      return _then(_value.copyWith(balancesState: value) as $Val);
    });
  }

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssetStateCopyWith<$Res> get assetState {
    return $AssetStateCopyWith<$Res>(_value.assetState, (value) {
      return _then(_value.copyWith(assetState: value) as $Val);
    });
  }

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FairmintersStateCopyWith<$Res> get fairmintersState {
    return $FairmintersStateCopyWith<$Res>(_value.fairmintersState, (value) {
      return _then(_value.copyWith(fairmintersState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComposeFairmintStateImplCopyWith<$Res>
    implements $ComposeFairminterStateCopyWith<$Res> {
  factory _$$ComposeFairmintStateImplCopyWith(_$ComposeFairmintStateImpl value,
          $Res Function(_$ComposeFairmintStateImpl) then) =
      __$$ComposeFairmintStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      AssetState assetState,
      FairmintersState fairmintersState});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
  @override
  $AssetStateCopyWith<$Res> get assetState;
  @override
  $FairmintersStateCopyWith<$Res> get fairmintersState;
}

/// @nodoc
class __$$ComposeFairmintStateImplCopyWithImpl<$Res>
    extends _$ComposeFairminterStateCopyWithImpl<$Res,
        _$ComposeFairmintStateImpl>
    implements _$$ComposeFairmintStateImplCopyWith<$Res> {
  __$$ComposeFairmintStateImplCopyWithImpl(_$ComposeFairmintStateImpl _value,
      $Res Function(_$ComposeFairmintStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? assetState = null,
    Object? fairmintersState = null,
  }) {
    return _then(_$ComposeFairmintStateImpl(
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
      fairmintersState: null == fairmintersState
          ? _value.fairmintersState
          : fairmintersState // ignore: cast_nullable_to_non_nullable
              as FairmintersState,
    ));
  }
}

/// @nodoc

class _$ComposeFairmintStateImpl extends _ComposeFairmintState {
  const _$ComposeFairmintStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      required this.assetState,
      required this.fairmintersState})
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
// Fairminter specific properties
  @override
  final AssetState assetState;
  @override
  final FairmintersState fairmintersState;

  @override
  String toString() {
    return 'ComposeFairminterState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, assetState: $assetState, fairmintersState: $fairmintersState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeFairmintStateImpl &&
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
            (identical(other.fairmintersState, fairmintersState) ||
                other.fairmintersState == fairmintersState));
  }

  @override
  int get hashCode => Object.hash(runtimeType, feeState, balancesState,
      feeOption, submitState, assetState, fairmintersState);

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeFairmintStateImplCopyWith<_$ComposeFairmintStateImpl>
      get copyWith =>
          __$$ComposeFairmintStateImplCopyWithImpl<_$ComposeFairmintStateImpl>(
              this, _$identity);
}

abstract class _ComposeFairmintState extends ComposeFairminterState {
  const factory _ComposeFairmintState(
          {required final FeeState feeState,
          required final BalancesState balancesState,
          required final FeeOption feeOption,
          required final SubmitState submitState,
          required final AssetState assetState,
          required final FairmintersState fairmintersState}) =
      _$ComposeFairmintStateImpl;
  const _ComposeFairmintState._() : super._();

// Inherited properties
  @override
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState; // Fairminter specific properties
  @override
  AssetState get assetState;
  @override
  FairmintersState get fairmintersState;

  /// Create a copy of ComposeFairminterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComposeFairmintStateImplCopyWith<_$ComposeFairmintStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssetState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Asset> assets) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Asset> assets)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Asset> assets)? success,
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

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
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
    required TResult Function(List<Asset> assets) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Asset> assets)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Asset> assets)? success,
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

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
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
    required TResult Function(List<Asset> assets) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Asset> assets)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Asset> assets)? success,
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
  $Res call({List<Asset> assets});
}

/// @nodoc
class __$$AssetSuccessImplCopyWithImpl<$Res>
    extends _$AssetStateCopyWithImpl<$Res, _$AssetSuccessImpl>
    implements _$$AssetSuccessImplCopyWith<$Res> {
  __$$AssetSuccessImplCopyWithImpl(
      _$AssetSuccessImpl _value, $Res Function(_$AssetSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assets = null,
  }) {
    return _then(_$AssetSuccessImpl(
      null == assets
          ? _value._assets
          : assets // ignore: cast_nullable_to_non_nullable
              as List<Asset>,
    ));
  }
}

/// @nodoc

class _$AssetSuccessImpl implements _AssetSuccess {
  const _$AssetSuccessImpl(final List<Asset> assets) : _assets = assets;

  final List<Asset> _assets;
  @override
  List<Asset> get assets {
    if (_assets is EqualUnmodifiableListView) return _assets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assets);
  }

  @override
  String toString() {
    return 'AssetState.success(assets: $assets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetSuccessImpl &&
            const DeepCollectionEquality().equals(other._assets, _assets));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_assets));

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetSuccessImplCopyWith<_$AssetSuccessImpl> get copyWith =>
      __$$AssetSuccessImplCopyWithImpl<_$AssetSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Asset> assets) success,
    required TResult Function(String error) error,
  }) {
    return success(assets);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Asset> assets)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(assets);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Asset> assets)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(assets);
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
  const factory _AssetSuccess(final List<Asset> assets) = _$AssetSuccessImpl;

  List<Asset> get assets;

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetErrorImplCopyWith<_$AssetErrorImpl> get copyWith =>
      __$$AssetErrorImplCopyWithImpl<_$AssetErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Asset> assets) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Asset> assets)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Asset> assets)? success,
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

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssetErrorImplCopyWith<_$AssetErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FairmintersState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Fairminter> fairminters) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Fairminter> fairminters)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Fairminter> fairminters)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FairmintersInitial value) initial,
    required TResult Function(_FairmintersLoading value) loading,
    required TResult Function(_FairmintersSuccess value) success,
    required TResult Function(_FairmintersError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FairmintersInitial value)? initial,
    TResult? Function(_FairmintersLoading value)? loading,
    TResult? Function(_FairmintersSuccess value)? success,
    TResult? Function(_FairmintersError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FairmintersInitial value)? initial,
    TResult Function(_FairmintersLoading value)? loading,
    TResult Function(_FairmintersSuccess value)? success,
    TResult Function(_FairmintersError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FairmintersStateCopyWith<$Res> {
  factory $FairmintersStateCopyWith(
          FairmintersState value, $Res Function(FairmintersState) then) =
      _$FairmintersStateCopyWithImpl<$Res, FairmintersState>;
}

/// @nodoc
class _$FairmintersStateCopyWithImpl<$Res, $Val extends FairmintersState>
    implements $FairmintersStateCopyWith<$Res> {
  _$FairmintersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FairmintersInitialImplCopyWith<$Res> {
  factory _$$FairmintersInitialImplCopyWith(_$FairmintersInitialImpl value,
          $Res Function(_$FairmintersInitialImpl) then) =
      __$$FairmintersInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FairmintersInitialImplCopyWithImpl<$Res>
    extends _$FairmintersStateCopyWithImpl<$Res, _$FairmintersInitialImpl>
    implements _$$FairmintersInitialImplCopyWith<$Res> {
  __$$FairmintersInitialImplCopyWithImpl(_$FairmintersInitialImpl _value,
      $Res Function(_$FairmintersInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FairmintersInitialImpl implements _FairmintersInitial {
  const _$FairmintersInitialImpl();

  @override
  String toString() {
    return 'FairmintersState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FairmintersInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Fairminter> fairminters) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Fairminter> fairminters)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Fairminter> fairminters)? success,
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
    required TResult Function(_FairmintersInitial value) initial,
    required TResult Function(_FairmintersLoading value) loading,
    required TResult Function(_FairmintersSuccess value) success,
    required TResult Function(_FairmintersError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FairmintersInitial value)? initial,
    TResult? Function(_FairmintersLoading value)? loading,
    TResult? Function(_FairmintersSuccess value)? success,
    TResult? Function(_FairmintersError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FairmintersInitial value)? initial,
    TResult Function(_FairmintersLoading value)? loading,
    TResult Function(_FairmintersSuccess value)? success,
    TResult Function(_FairmintersError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _FairmintersInitial implements FairmintersState {
  const factory _FairmintersInitial() = _$FairmintersInitialImpl;
}

/// @nodoc
abstract class _$$FairmintersLoadingImplCopyWith<$Res> {
  factory _$$FairmintersLoadingImplCopyWith(_$FairmintersLoadingImpl value,
          $Res Function(_$FairmintersLoadingImpl) then) =
      __$$FairmintersLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FairmintersLoadingImplCopyWithImpl<$Res>
    extends _$FairmintersStateCopyWithImpl<$Res, _$FairmintersLoadingImpl>
    implements _$$FairmintersLoadingImplCopyWith<$Res> {
  __$$FairmintersLoadingImplCopyWithImpl(_$FairmintersLoadingImpl _value,
      $Res Function(_$FairmintersLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FairmintersLoadingImpl implements _FairmintersLoading {
  const _$FairmintersLoadingImpl();

  @override
  String toString() {
    return 'FairmintersState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FairmintersLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Fairminter> fairminters) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Fairminter> fairminters)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Fairminter> fairminters)? success,
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
    required TResult Function(_FairmintersInitial value) initial,
    required TResult Function(_FairmintersLoading value) loading,
    required TResult Function(_FairmintersSuccess value) success,
    required TResult Function(_FairmintersError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FairmintersInitial value)? initial,
    TResult? Function(_FairmintersLoading value)? loading,
    TResult? Function(_FairmintersSuccess value)? success,
    TResult? Function(_FairmintersError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FairmintersInitial value)? initial,
    TResult Function(_FairmintersLoading value)? loading,
    TResult Function(_FairmintersSuccess value)? success,
    TResult Function(_FairmintersError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _FairmintersLoading implements FairmintersState {
  const factory _FairmintersLoading() = _$FairmintersLoadingImpl;
}

/// @nodoc
abstract class _$$FairmintersSuccessImplCopyWith<$Res> {
  factory _$$FairmintersSuccessImplCopyWith(_$FairmintersSuccessImpl value,
          $Res Function(_$FairmintersSuccessImpl) then) =
      __$$FairmintersSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Fairminter> fairminters});
}

/// @nodoc
class __$$FairmintersSuccessImplCopyWithImpl<$Res>
    extends _$FairmintersStateCopyWithImpl<$Res, _$FairmintersSuccessImpl>
    implements _$$FairmintersSuccessImplCopyWith<$Res> {
  __$$FairmintersSuccessImplCopyWithImpl(_$FairmintersSuccessImpl _value,
      $Res Function(_$FairmintersSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fairminters = null,
  }) {
    return _then(_$FairmintersSuccessImpl(
      null == fairminters
          ? _value._fairminters
          : fairminters // ignore: cast_nullable_to_non_nullable
              as List<Fairminter>,
    ));
  }
}

/// @nodoc

class _$FairmintersSuccessImpl implements _FairmintersSuccess {
  const _$FairmintersSuccessImpl(final List<Fairminter> fairminters)
      : _fairminters = fairminters;

  final List<Fairminter> _fairminters;
  @override
  List<Fairminter> get fairminters {
    if (_fairminters is EqualUnmodifiableListView) return _fairminters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fairminters);
  }

  @override
  String toString() {
    return 'FairmintersState.success(fairminters: $fairminters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FairmintersSuccessImpl &&
            const DeepCollectionEquality()
                .equals(other._fairminters, _fairminters));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_fairminters));

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FairmintersSuccessImplCopyWith<_$FairmintersSuccessImpl> get copyWith =>
      __$$FairmintersSuccessImplCopyWithImpl<_$FairmintersSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Fairminter> fairminters) success,
    required TResult Function(String error) error,
  }) {
    return success(fairminters);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Fairminter> fairminters)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(fairminters);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Fairminter> fairminters)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(fairminters);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FairmintersInitial value) initial,
    required TResult Function(_FairmintersLoading value) loading,
    required TResult Function(_FairmintersSuccess value) success,
    required TResult Function(_FairmintersError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FairmintersInitial value)? initial,
    TResult? Function(_FairmintersLoading value)? loading,
    TResult? Function(_FairmintersSuccess value)? success,
    TResult? Function(_FairmintersError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FairmintersInitial value)? initial,
    TResult Function(_FairmintersLoading value)? loading,
    TResult Function(_FairmintersSuccess value)? success,
    TResult Function(_FairmintersError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _FairmintersSuccess implements FairmintersState {
  const factory _FairmintersSuccess(final List<Fairminter> fairminters) =
      _$FairmintersSuccessImpl;

  List<Fairminter> get fairminters;

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FairmintersSuccessImplCopyWith<_$FairmintersSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FairmintersErrorImplCopyWith<$Res> {
  factory _$$FairmintersErrorImplCopyWith(_$FairmintersErrorImpl value,
          $Res Function(_$FairmintersErrorImpl) then) =
      __$$FairmintersErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$FairmintersErrorImplCopyWithImpl<$Res>
    extends _$FairmintersStateCopyWithImpl<$Res, _$FairmintersErrorImpl>
    implements _$$FairmintersErrorImplCopyWith<$Res> {
  __$$FairmintersErrorImplCopyWithImpl(_$FairmintersErrorImpl _value,
      $Res Function(_$FairmintersErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$FairmintersErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FairmintersErrorImpl implements _FairmintersError {
  const _$FairmintersErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'FairmintersState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FairmintersErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FairmintersErrorImplCopyWith<_$FairmintersErrorImpl> get copyWith =>
      __$$FairmintersErrorImplCopyWithImpl<_$FairmintersErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Fairminter> fairminters) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Fairminter> fairminters)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Fairminter> fairminters)? success,
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
    required TResult Function(_FairmintersInitial value) initial,
    required TResult Function(_FairmintersLoading value) loading,
    required TResult Function(_FairmintersSuccess value) success,
    required TResult Function(_FairmintersError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FairmintersInitial value)? initial,
    TResult? Function(_FairmintersLoading value)? loading,
    TResult? Function(_FairmintersSuccess value)? success,
    TResult? Function(_FairmintersError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FairmintersInitial value)? initial,
    TResult Function(_FairmintersLoading value)? loading,
    TResult Function(_FairmintersSuccess value)? success,
    TResult Function(_FairmintersError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _FairmintersError implements FairmintersState {
  const factory _FairmintersError(final String error) = _$FairmintersErrorImpl;

  String get error;

  /// Create a copy of FairmintersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FairmintersErrorImplCopyWith<_$FairmintersErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
