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
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
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
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
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
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
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
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
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
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
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
abstract class _$$DispenserSuccessNormalFlowImplCopyWith<$Res> {
  factory _$$DispenserSuccessNormalFlowImplCopyWith(
          _$DispenserSuccessNormalFlowImpl value,
          $Res Function(_$DispenserSuccessNormalFlowImpl) then) =
      __$$DispenserSuccessNormalFlowImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispenserSuccessNormalFlowImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res, _$DispenserSuccessNormalFlowImpl>
    implements _$$DispenserSuccessNormalFlowImplCopyWith<$Res> {
  __$$DispenserSuccessNormalFlowImplCopyWithImpl(
      _$DispenserSuccessNormalFlowImpl _value,
      $Res Function(_$DispenserSuccessNormalFlowImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispenserSuccessNormalFlowImpl implements _DispenserSuccessNormalFlow {
  const _$DispenserSuccessNormalFlowImpl();

  @override
  String toString() {
    return 'DispenserState.successNormalFlow()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispenserSuccessNormalFlowImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return successNormalFlow();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return successNormalFlow?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (successNormalFlow != null) {
      return successNormalFlow();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return successNormalFlow(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return successNormalFlow?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (successNormalFlow != null) {
      return successNormalFlow(this);
    }
    return orElse();
  }
}

abstract class _DispenserSuccessNormalFlow implements DispenserState {
  const factory _DispenserSuccessNormalFlow() =
      _$DispenserSuccessNormalFlowImpl;
}

/// @nodoc
abstract class _$$DispenserSuccessCreateNewAddressFlowImplCopyWith<$Res> {
  factory _$$DispenserSuccessCreateNewAddressFlowImplCopyWith(
          _$DispenserSuccessCreateNewAddressFlowImpl value,
          $Res Function(_$DispenserSuccessCreateNewAddressFlowImpl) then) =
      __$$DispenserSuccessCreateNewAddressFlowImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispenserSuccessCreateNewAddressFlowImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res,
        _$DispenserSuccessCreateNewAddressFlowImpl>
    implements _$$DispenserSuccessCreateNewAddressFlowImplCopyWith<$Res> {
  __$$DispenserSuccessCreateNewAddressFlowImplCopyWithImpl(
      _$DispenserSuccessCreateNewAddressFlowImpl _value,
      $Res Function(_$DispenserSuccessCreateNewAddressFlowImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispenserSuccessCreateNewAddressFlowImpl
    implements _DispenserSuccessCreateNewAddressFlow {
  const _$DispenserSuccessCreateNewAddressFlowImpl();

  @override
  String toString() {
    return 'DispenserState.successCreateNewAddressFlow()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispenserSuccessCreateNewAddressFlowImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return successCreateNewAddressFlow();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return successCreateNewAddressFlow?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (successCreateNewAddressFlow != null) {
      return successCreateNewAddressFlow();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return successCreateNewAddressFlow(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return successCreateNewAddressFlow?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (successCreateNewAddressFlow != null) {
      return successCreateNewAddressFlow(this);
    }
    return orElse();
  }
}

abstract class _DispenserSuccessCreateNewAddressFlow implements DispenserState {
  const factory _DispenserSuccessCreateNewAddressFlow() =
      _$DispenserSuccessCreateNewAddressFlowImpl;
}

/// @nodoc
abstract class _$$DispenserCloseDialogAndOpenNewAddressImplCopyWith<$Res> {
  factory _$$DispenserCloseDialogAndOpenNewAddressImplCopyWith(
          _$DispenserCloseDialogAndOpenNewAddressImpl value,
          $Res Function(_$DispenserCloseDialogAndOpenNewAddressImpl) then) =
      __$$DispenserCloseDialogAndOpenNewAddressImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String originalAddress,
      bool divisible,
      String asset,
      String giveQuantity,
      String escrowQuantity,
      String mainchainrate,
      int feeRate});
}

/// @nodoc
class __$$DispenserCloseDialogAndOpenNewAddressImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res,
        _$DispenserCloseDialogAndOpenNewAddressImpl>
    implements _$$DispenserCloseDialogAndOpenNewAddressImplCopyWith<$Res> {
  __$$DispenserCloseDialogAndOpenNewAddressImplCopyWithImpl(
      _$DispenserCloseDialogAndOpenNewAddressImpl _value,
      $Res Function(_$DispenserCloseDialogAndOpenNewAddressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalAddress = null,
    Object? divisible = null,
    Object? asset = null,
    Object? giveQuantity = null,
    Object? escrowQuantity = null,
    Object? mainchainrate = null,
    Object? feeRate = null,
  }) {
    return _then(_$DispenserCloseDialogAndOpenNewAddressImpl(
      originalAddress: null == originalAddress
          ? _value.originalAddress
          : originalAddress // ignore: cast_nullable_to_non_nullable
              as String,
      divisible: null == divisible
          ? _value.divisible
          : divisible // ignore: cast_nullable_to_non_nullable
              as bool,
      asset: null == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String,
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
      feeRate: null == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DispenserCloseDialogAndOpenNewAddressImpl
    implements _DispenserCloseDialogAndOpenNewAddress {
  const _$DispenserCloseDialogAndOpenNewAddressImpl(
      {required this.originalAddress,
      required this.divisible,
      required this.asset,
      required this.giveQuantity,
      required this.escrowQuantity,
      required this.mainchainrate,
      required this.feeRate});

  @override
  final String originalAddress;
  @override
  final bool divisible;
  @override
  final String asset;
  @override
  final String giveQuantity;
  @override
  final String escrowQuantity;
  @override
  final String mainchainrate;
  @override
  final int feeRate;

  @override
  String toString() {
    return 'DispenserState.closeDialogAndOpenNewAddress(originalAddress: $originalAddress, divisible: $divisible, asset: $asset, giveQuantity: $giveQuantity, escrowQuantity: $escrowQuantity, mainchainrate: $mainchainrate, feeRate: $feeRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispenserCloseDialogAndOpenNewAddressImpl &&
            (identical(other.originalAddress, originalAddress) ||
                other.originalAddress == originalAddress) &&
            (identical(other.divisible, divisible) ||
                other.divisible == divisible) &&
            (identical(other.asset, asset) || other.asset == asset) &&
            (identical(other.giveQuantity, giveQuantity) ||
                other.giveQuantity == giveQuantity) &&
            (identical(other.escrowQuantity, escrowQuantity) ||
                other.escrowQuantity == escrowQuantity) &&
            (identical(other.mainchainrate, mainchainrate) ||
                other.mainchainrate == mainchainrate) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, originalAddress, divisible,
      asset, giveQuantity, escrowQuantity, mainchainrate, feeRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispenserCloseDialogAndOpenNewAddressImplCopyWith<
          _$DispenserCloseDialogAndOpenNewAddressImpl>
      get copyWith => __$$DispenserCloseDialogAndOpenNewAddressImplCopyWithImpl<
          _$DispenserCloseDialogAndOpenNewAddressImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return closeDialogAndOpenNewAddress(originalAddress, divisible, asset,
        giveQuantity, escrowQuantity, mainchainrate, feeRate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return closeDialogAndOpenNewAddress?.call(originalAddress, divisible, asset,
        giveQuantity, escrowQuantity, mainchainrate, feeRate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (closeDialogAndOpenNewAddress != null) {
      return closeDialogAndOpenNewAddress(originalAddress, divisible, asset,
          giveQuantity, escrowQuantity, mainchainrate, feeRate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return closeDialogAndOpenNewAddress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return closeDialogAndOpenNewAddress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (closeDialogAndOpenNewAddress != null) {
      return closeDialogAndOpenNewAddress(this);
    }
    return orElse();
  }
}

abstract class _DispenserCloseDialogAndOpenNewAddress
    implements DispenserState {
  const factory _DispenserCloseDialogAndOpenNewAddress(
          {required final String originalAddress,
          required final bool divisible,
          required final String asset,
          required final String giveQuantity,
          required final String escrowQuantity,
          required final String mainchainrate,
          required final int feeRate}) =
      _$DispenserCloseDialogAndOpenNewAddressImpl;

  String get originalAddress;
  bool get divisible;
  String get asset;
  String get giveQuantity;
  String get escrowQuantity;
  String get mainchainrate;
  int get feeRate;
  @JsonKey(ignore: true)
  _$$DispenserCloseDialogAndOpenNewAddressImplCopyWith<
          _$DispenserCloseDialogAndOpenNewAddressImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DispenserWarningImplCopyWith<$Res> {
  factory _$$DispenserWarningImplCopyWith(_$DispenserWarningImpl value,
          $Res Function(_$DispenserWarningImpl) then) =
      __$$DispenserWarningImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DispenserWarningImplCopyWithImpl<$Res>
    extends _$DispenserStateCopyWithImpl<$Res, _$DispenserWarningImpl>
    implements _$$DispenserWarningImplCopyWith<$Res> {
  __$$DispenserWarningImplCopyWithImpl(_$DispenserWarningImpl _value,
      $Res Function(_$DispenserWarningImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DispenserWarningImpl implements _DispenserWarning {
  const _$DispenserWarningImpl();

  @override
  String toString() {
    return 'DispenserState.warning()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DispenserWarningImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return warning();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return warning?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (warning != null) {
      return warning();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DispenserInitial value) initial,
    required TResult Function(_DispenserLoading value) loading,
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return warning(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return warning?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
    TResult Function(_DispenserError value)? error,
    required TResult orElse(),
  }) {
    if (warning != null) {
      return warning(this);
    }
    return orElse();
  }
}

abstract class _DispenserWarning implements DispenserState {
  const factory _DispenserWarning() = _$DispenserWarningImpl;
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
    required TResult Function() successNormalFlow,
    required TResult Function() successCreateNewAddressFlow,
    required TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)
        closeDialogAndOpenNewAddress,
    required TResult Function() warning,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? successNormalFlow,
    TResult? Function()? successCreateNewAddressFlow,
    TResult? Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult? Function()? warning,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? successNormalFlow,
    TResult Function()? successCreateNewAddressFlow,
    TResult Function(
            String originalAddress,
            bool divisible,
            String asset,
            String giveQuantity,
            String escrowQuantity,
            String mainchainrate,
            int feeRate)?
        closeDialogAndOpenNewAddress,
    TResult Function()? warning,
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
    required TResult Function(_DispenserSuccessNormalFlow value)
        successNormalFlow,
    required TResult Function(_DispenserSuccessCreateNewAddressFlow value)
        successCreateNewAddressFlow,
    required TResult Function(_DispenserCloseDialogAndOpenNewAddress value)
        closeDialogAndOpenNewAddress,
    required TResult Function(_DispenserWarning value) warning,
    required TResult Function(_DispenserError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DispenserInitial value)? initial,
    TResult? Function(_DispenserLoading value)? loading,
    TResult? Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult? Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult? Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult? Function(_DispenserWarning value)? warning,
    TResult? Function(_DispenserError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DispenserInitial value)? initial,
    TResult Function(_DispenserLoading value)? loading,
    TResult Function(_DispenserSuccessNormalFlow value)? successNormalFlow,
    TResult Function(_DispenserSuccessCreateNewAddressFlow value)?
        successCreateNewAddressFlow,
    TResult Function(_DispenserCloseDialogAndOpenNewAddress value)?
        closeDialogAndOpenNewAddress,
    TResult Function(_DispenserWarning value)? warning,
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
