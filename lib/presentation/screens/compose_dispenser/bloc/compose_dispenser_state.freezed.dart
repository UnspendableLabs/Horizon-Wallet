// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_dispenser_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeDispenserState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState =>
      throw _privateConstructorUsedError; // Dispenser-specific properties
  DispenserState get dispensersState => throw _privateConstructorUsedError;
  String? get assetName => throw _privateConstructorUsedError;
  String? get openAddress => throw _privateConstructorUsedError;
  String get giveQuantity => throw _privateConstructorUsedError;
  String get escrowQuantity => throw _privateConstructorUsedError;
  String get mainchainrate => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeDispenserStateCopyWith<ComposeDispenserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeDispenserStateCopyWith<$Res> {
  factory $ComposeDispenserStateCopyWith(ComposeDispenserState value,
          $Res Function(ComposeDispenserState) then) =
      _$ComposeDispenserStateCopyWithImpl<$Res, ComposeDispenserState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      DispenserState dispensersState,
      String? assetName,
      String? openAddress,
      String giveQuantity,
      String escrowQuantity,
      String mainchainrate,
      int status});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
  $DispenserStateCopyWith<$Res> get dispensersState;
}

/// @nodoc
class _$ComposeDispenserStateCopyWithImpl<$Res,
        $Val extends ComposeDispenserState>
    implements $ComposeDispenserStateCopyWith<$Res> {
  _$ComposeDispenserStateCopyWithImpl(this._value, this._then);

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
    Object? dispensersState = null,
    Object? assetName = freezed,
    Object? openAddress = freezed,
    Object? giveQuantity = null,
    Object? escrowQuantity = null,
    Object? mainchainrate = null,
    Object? status = null,
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
      dispensersState: null == dispensersState
          ? _value.dispensersState
          : dispensersState // ignore: cast_nullable_to_non_nullable
              as DispenserState,
      assetName: freezed == assetName
          ? _value.assetName
          : assetName // ignore: cast_nullable_to_non_nullable
              as String?,
      openAddress: freezed == openAddress
          ? _value.openAddress
          : openAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      giveQuantity: null == giveQuantity
          ? _value.giveQuantity
          : giveQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      escrowQuantity: null == escrowQuantity
          ? _value.escrowQuantity
          : escrowQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      mainchainrate: null == mainchainrate
          ? _value.mainchainrate
          : mainchainrate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
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
  $DispenserStateCopyWith<$Res> get dispensersState {
    return $DispenserStateCopyWith<$Res>(_value.dispensersState, (value) {
      return _then(_value.copyWith(dispensersState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComposeDispenserStateImplCopyWith<$Res>
    implements $ComposeDispenserStateCopyWith<$Res> {
  factory _$$ComposeDispenserStateImplCopyWith(
          _$ComposeDispenserStateImpl value,
          $Res Function(_$ComposeDispenserStateImpl) then) =
      __$$ComposeDispenserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      DispenserState dispensersState,
      String? assetName,
      String? openAddress,
      String giveQuantity,
      String escrowQuantity,
      String mainchainrate,
      int status});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
  @override
  $DispenserStateCopyWith<$Res> get dispensersState;
}

/// @nodoc
class __$$ComposeDispenserStateImplCopyWithImpl<$Res>
    extends _$ComposeDispenserStateCopyWithImpl<$Res,
        _$ComposeDispenserStateImpl>
    implements _$$ComposeDispenserStateImplCopyWith<$Res> {
  __$$ComposeDispenserStateImplCopyWithImpl(_$ComposeDispenserStateImpl _value,
      $Res Function(_$ComposeDispenserStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? dispensersState = null,
    Object? assetName = freezed,
    Object? openAddress = freezed,
    Object? giveQuantity = null,
    Object? escrowQuantity = null,
    Object? mainchainrate = null,
    Object? status = null,
  }) {
    return _then(_$ComposeDispenserStateImpl(
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
      dispensersState: null == dispensersState
          ? _value.dispensersState
          : dispensersState // ignore: cast_nullable_to_non_nullable
              as DispenserState,
      assetName: freezed == assetName
          ? _value.assetName
          : assetName // ignore: cast_nullable_to_non_nullable
              as String?,
      openAddress: freezed == openAddress
          ? _value.openAddress
          : openAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      giveQuantity: null == giveQuantity
          ? _value.giveQuantity
          : giveQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      escrowQuantity: null == escrowQuantity
          ? _value.escrowQuantity
          : escrowQuantity // ignore: cast_nullable_to_non_nullable
              as String,
      mainchainrate: null == mainchainrate
          ? _value.mainchainrate
          : mainchainrate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ComposeDispenserStateImpl extends _ComposeDispenserState {
  const _$ComposeDispenserStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      required this.dispensersState,
      this.assetName,
      this.openAddress,
      required this.giveQuantity,
      required this.escrowQuantity,
      required this.mainchainrate,
      required this.status})
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
// Dispenser-specific properties
  @override
  final DispenserState dispensersState;
  @override
  final String? assetName;
  @override
  final String? openAddress;
  @override
  final String giveQuantity;
  @override
  final String escrowQuantity;
  @override
  final String mainchainrate;
  @override
  final int status;

  @override
  String toString() {
    return 'ComposeDispenserState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, dispensersState: $dispensersState, assetName: $assetName, openAddress: $openAddress, giveQuantity: $giveQuantity, escrowQuantity: $escrowQuantity, mainchainrate: $mainchainrate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeDispenserStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState) &&
            (identical(other.dispensersState, dispensersState) ||
                other.dispensersState == dispensersState) &&
            (identical(other.assetName, assetName) ||
                other.assetName == assetName) &&
            (identical(other.openAddress, openAddress) ||
                other.openAddress == openAddress) &&
            (identical(other.giveQuantity, giveQuantity) ||
                other.giveQuantity == giveQuantity) &&
            (identical(other.escrowQuantity, escrowQuantity) ||
                other.escrowQuantity == escrowQuantity) &&
            (identical(other.mainchainrate, mainchainrate) ||
                other.mainchainrate == mainchainrate) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      feeState,
      balancesState,
      feeOption,
      submitState,
      dispensersState,
      assetName,
      openAddress,
      giveQuantity,
      escrowQuantity,
      mainchainrate,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeDispenserStateImplCopyWith<_$ComposeDispenserStateImpl>
      get copyWith => __$$ComposeDispenserStateImplCopyWithImpl<
          _$ComposeDispenserStateImpl>(this, _$identity);
}

abstract class _ComposeDispenserState extends ComposeDispenserState {
  const factory _ComposeDispenserState(
      {required final FeeState feeState,
      required final BalancesState balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState,
      required final DispenserState dispensersState,
      final String? assetName,
      final String? openAddress,
      required final String giveQuantity,
      required final String escrowQuantity,
      required final String mainchainrate,
      required final int status}) = _$ComposeDispenserStateImpl;
  const _ComposeDispenserState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override // Dispenser-specific properties
  DispenserState get dispensersState;
  @override
  String? get assetName;
  @override
  String? get openAddress;
  @override
  String get giveQuantity;
  @override
  String get escrowQuantity;
  @override
  String get mainchainrate;
  @override
  int get status;
  @override
  @JsonKey(ignore: true)
  _$$ComposeDispenserStateImplCopyWith<_$ComposeDispenserStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DispenserState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccess value) success,
    required TResult Function(_DispenserError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccess value)? success,
    TResult? Function(_DispenserError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccess value)? success,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispenserStateCopyWith<$Res> {
  factory $DispenserStateCopyWith(
          DispenserState value, $Res Function(DispenserState) then) =
      _$DispenserStateCopyWithImpl<$Res, DispenserState>;
}

/// @nodoc
class _$DispenserStateCopyWithImpl<$Res, $Val extends DispenserState>
    implements $DispenserStateCopyWith<$Res> {
  _$DispenserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DispenserInitialImplCopyWith<$Res> {
  factory _$$DispenserInitialImplCopyWith(_$DispenserInitialImpl value,
          $Res Function(_$DispenserInitialImpl) then) =
      __$$DispenserInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispenserInitialImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res, _$DispenserInitialImpl>
    implements _$$DispenserInitialImplCopyWith<$Res> {
  __$$DispenserInitialImplCopyWithImpl(_$DispenserInitialImpl _value,
      $Res Function(_$DispenserInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispenserInitialImpl implements _DispenserInitial {
  const _$DispenserInitialImpl();

  @override
  String toString() {
    return 'DispenserState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DispenserInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
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
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccess value) success,
    required TResult Function(_DispenserError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccess value)? success,
    TResult? Function(_DispenserError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccess value)? success,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _DispenserInitial implements DispenserState {
  const factory _DispenserInitial() = _$DispenserInitialImpl;
}

/// @nodoc
abstract class _$$DispenserLoadingImplCopyWith<$Res> {
  factory _$$DispenserLoadingImplCopyWith(_$DispenserLoadingImpl value,
          $Res Function(_$DispenserLoadingImpl) then) =
      __$$DispenserLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispenserLoadingImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res, _$DispenserLoadingImpl>
    implements _$$DispenserLoadingImplCopyWith<$Res> {
  __$$DispenserLoadingImplCopyWithImpl(_$DispenserLoadingImpl _value,
      $Res Function(_$DispenserLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispenserLoadingImpl implements _DispenserLoading {
  const _$DispenserLoadingImpl();

  @override
  String toString() {
    return 'DispenserState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DispenserLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
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
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccess value) success,
    required TResult Function(_DispenserError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccess value)? success,
    TResult? Function(_DispenserError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccess value)? success,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _DispenserLoading implements DispenserState {
  const factory _DispenserLoading() = _$DispenserLoadingImpl;
}

/// @nodoc
abstract class _$$DispenserSuccessImplCopyWith<$Res> {
  factory _$$DispenserSuccessImplCopyWith(_$DispenserSuccessImpl value,
          $Res Function(_$DispenserSuccessImpl) then) =
      __$$DispenserSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Dispenser> dispensers});
}

/// @nodoc
class __$$DispenserSuccessImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res, _$DispenserSuccessImpl>
    implements _$$DispenserSuccessImplCopyWith<$Res> {
  __$$DispenserSuccessImplCopyWithImpl(_$DispenserSuccessImpl _value,
      $Res Function(_$DispenserSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dispensers = null,
  }) {
    return _then(_$DispenserSuccessImpl(
      null == dispensers
          ? _value._dispensers
          : dispensers // ignore: cast_nullable_to_non_nullable
              as List<Dispenser>,
    ));
  }
}

/// @nodoc

class _$DispenserSuccessImpl implements _DispenserSuccess {
  const _$DispenserSuccessImpl(final List<Dispenser> dispensers)
      : _dispensers = dispensers;

  final List<Dispenser> _dispensers;
  @override
  List<Dispenser> get dispensers {
    if (_dispensers is EqualUnmodifiableListView) return _dispensers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dispensers);
  }

  @override
  String toString() {
    return 'DispenserState.success(dispensers: $dispensers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispenserSuccessImpl &&
            const DeepCollectionEquality()
                .equals(other._dispensers, _dispensers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_dispensers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispenserSuccessImplCopyWith<_$DispenserSuccessImpl> get copyWith =>
      __$$DispenserSuccessImplCopyWithImpl<_$DispenserSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return success(dispensers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(dispensers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(dispensers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccess value) success,
    required TResult Function(_DispenserError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccess value)? success,
    TResult? Function(_DispenserError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccess value)? success,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _DispenserSuccess implements DispenserState {
  const factory _DispenserSuccess(final List<Dispenser> dispensers) =
      _$DispenserSuccessImpl;

  List<Dispenser> get dispensers;
  @JsonKey(ignore: true)
  _$$DispenserSuccessImplCopyWith<_$DispenserSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DispenserErrorImplCopyWith<$Res> {
  factory _$$DispenserErrorImplCopyWith(_$DispenserErrorImpl value,
          $Res Function(_$DispenserErrorImpl) then) =
      __$$DispenserErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$DispenserErrorImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res, _$DispenserErrorImpl>
    implements _$$DispenserErrorImplCopyWith<$Res> {
  __$$DispenserErrorImplCopyWithImpl(
      _$DispenserErrorImpl _value, $Res Function(_$DispenserErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$DispenserErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DispenserErrorImpl implements _DispenserError {
  const _$DispenserErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'DispenserState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispenserErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispenserErrorImplCopyWith<_$DispenserErrorImpl> get copyWith =>
      __$$DispenserErrorImplCopyWithImpl<_$DispenserErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Dispenser> dispensers) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Dispenser> dispensers)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Dispenser> dispensers)? success,
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
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccess value) success,
    required TResult Function(_DispenserError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccess value)? success,
    TResult? Function(_DispenserError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccess value)? success,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _DispenserError implements DispenserState {
  const factory _DispenserError(final String error) = _$DispenserErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$DispenserErrorImplCopyWith<_$DispenserErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
