// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_mpma_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MpmaEntry {
  MaxValueState get maxValue => throw _privateConstructorUsedError;
  bool get sendMax => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  String? get asset => throw _privateConstructorUsedError;
  String get quantity => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MpmaEntryCopyWith<MpmaEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MpmaEntryCopyWith<$Res> {
  factory $MpmaEntryCopyWith(MpmaEntry value, $Res Function(MpmaEntry) then) =
      _$MpmaEntryCopyWithImpl<$Res, MpmaEntry>;
  @useResult
  $Res call(
      {MaxValueState maxValue,
      bool sendMax,
      String? source,
      String? destination,
      String? asset,
      String quantity});

  $MaxValueStateCopyWith<$Res> get maxValue;
}

/// @nodoc
class _$MpmaEntryCopyWithImpl<$Res, $Val extends MpmaEntry>
    implements $MpmaEntryCopyWith<$Res> {
  _$MpmaEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxValue = null,
    Object? sendMax = null,
    Object? source = freezed,
    Object? destination = freezed,
    Object? asset = freezed,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as MaxValueState,
      sendMax: null == sendMax
          ? _value.sendMax
          : sendMax // ignore: cast_nullable_to_non_nullable
              as bool,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MaxValueStateCopyWith<$Res> get maxValue {
    return $MaxValueStateCopyWith<$Res>(_value.maxValue, (value) {
      return _then(_value.copyWith(maxValue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MpmaEntryImplCopyWith<$Res>
    implements $MpmaEntryCopyWith<$Res> {
  factory _$$MpmaEntryImplCopyWith(
          _$MpmaEntryImpl value, $Res Function(_$MpmaEntryImpl) then) =
      __$$MpmaEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MaxValueState maxValue,
      bool sendMax,
      String? source,
      String? destination,
      String? asset,
      String quantity});

  @override
  $MaxValueStateCopyWith<$Res> get maxValue;
}

/// @nodoc
class __$$MpmaEntryImplCopyWithImpl<$Res>
    extends _$MpmaEntryCopyWithImpl<$Res, _$MpmaEntryImpl>
    implements _$$MpmaEntryImplCopyWith<$Res> {
  __$$MpmaEntryImplCopyWithImpl(
      _$MpmaEntryImpl _value, $Res Function(_$MpmaEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxValue = null,
    Object? sendMax = null,
    Object? source = freezed,
    Object? destination = freezed,
    Object? asset = freezed,
    Object? quantity = null,
  }) {
    return _then(_$MpmaEntryImpl(
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as MaxValueState,
      sendMax: null == sendMax
          ? _value.sendMax
          : sendMax // ignore: cast_nullable_to_non_nullable
              as bool,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MpmaEntryImpl implements _MpmaEntry {
  const _$MpmaEntryImpl(
      {required this.maxValue,
      required this.sendMax,
      this.source,
      this.destination,
      this.asset,
      required this.quantity});

  @override
  final MaxValueState maxValue;
  @override
  final bool sendMax;
  @override
  final String? source;
  @override
  final String? destination;
  @override
  final String? asset;
  @override
  final String quantity;

  @override
  String toString() {
    return 'MpmaEntry(maxValue: $maxValue, sendMax: $sendMax, source: $source, destination: $destination, asset: $asset, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MpmaEntryImpl &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.sendMax, sendMax) || other.sendMax == sendMax) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.asset, asset) || other.asset == asset) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, maxValue, sendMax, source, destination, asset, quantity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MpmaEntryImplCopyWith<_$MpmaEntryImpl> get copyWith =>
      __$$MpmaEntryImplCopyWithImpl<_$MpmaEntryImpl>(this, _$identity);
}

abstract class _MpmaEntry implements MpmaEntry {
  const factory _MpmaEntry(
      {required final MaxValueState maxValue,
      required final bool sendMax,
      final String? source,
      final String? destination,
      final String? asset,
      required final String quantity}) = _$MpmaEntryImpl;

  @override
  MaxValueState get maxValue;
  @override
  bool get sendMax;
  @override
  String? get source;
  @override
  String? get destination;
  @override
  String? get asset;
  @override
  String get quantity;
  @override
  @JsonKey(ignore: true)
  _$$MpmaEntryImplCopyWith<_$MpmaEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ComposeMpmaState {
// Inherited properties
  FeeState get feeState => throw _privateConstructorUsedError;
  BalancesState get balancesState => throw _privateConstructorUsedError;
  FeeOption get feeOption => throw _privateConstructorUsedError;
  SubmitState get submitState =>
      throw _privateConstructorUsedError; // Specific properties
  List<MpmaEntry> get entries => throw _privateConstructorUsedError;
  String? get composeSendError => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ComposeMpmaStateCopyWith<ComposeMpmaState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeMpmaStateCopyWith<$Res> {
  factory $ComposeMpmaStateCopyWith(
          ComposeMpmaState value, $Res Function(ComposeMpmaState) then) =
      _$ComposeMpmaStateCopyWithImpl<$Res, ComposeMpmaState>;
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      List<MpmaEntry> entries,
      String? composeSendError});

  $FeeStateCopyWith<$Res> get feeState;
  $BalancesStateCopyWith<$Res> get balancesState;
}

/// @nodoc
class _$ComposeMpmaStateCopyWithImpl<$Res, $Val extends ComposeMpmaState>
    implements $ComposeMpmaStateCopyWith<$Res> {
  _$ComposeMpmaStateCopyWithImpl(this._value, this._then);

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
    Object? entries = null,
    Object? composeSendError = freezed,
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
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<MpmaEntry>,
      composeSendError: freezed == composeSendError
          ? _value.composeSendError
          : composeSendError // ignore: cast_nullable_to_non_nullable
              as String?,
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
}

/// @nodoc
abstract class _$$ComposeMpmaStateImplCopyWith<$Res>
    implements $ComposeMpmaStateCopyWith<$Res> {
  factory _$$ComposeMpmaStateImplCopyWith(_$ComposeMpmaStateImpl value,
          $Res Function(_$ComposeMpmaStateImpl) then) =
      __$$ComposeMpmaStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FeeState feeState,
      BalancesState balancesState,
      FeeOption feeOption,
      SubmitState submitState,
      List<MpmaEntry> entries,
      String? composeSendError});

  @override
  $FeeStateCopyWith<$Res> get feeState;
  @override
  $BalancesStateCopyWith<$Res> get balancesState;
}

/// @nodoc
class __$$ComposeMpmaStateImplCopyWithImpl<$Res>
    extends _$ComposeMpmaStateCopyWithImpl<$Res, _$ComposeMpmaStateImpl>
    implements _$$ComposeMpmaStateImplCopyWith<$Res> {
  __$$ComposeMpmaStateImplCopyWithImpl(_$ComposeMpmaStateImpl _value,
      $Res Function(_$ComposeMpmaStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeState = null,
    Object? balancesState = null,
    Object? feeOption = null,
    Object? submitState = null,
    Object? entries = null,
    Object? composeSendError = freezed,
  }) {
    return _then(_$ComposeMpmaStateImpl(
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
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<MpmaEntry>,
      composeSendError: freezed == composeSendError
          ? _value.composeSendError
          : composeSendError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ComposeMpmaStateImpl extends _ComposeMpmaState {
  const _$ComposeMpmaStateImpl(
      {required this.feeState,
      required this.balancesState,
      required this.feeOption,
      required this.submitState,
      required final List<MpmaEntry> entries,
      this.composeSendError})
      : _entries = entries,
        super._();

// Inherited properties
  @override
  final FeeState feeState;
  @override
  final BalancesState balancesState;
  @override
  final FeeOption feeOption;
  @override
  final SubmitState submitState;
// Specific properties
  final List<MpmaEntry> _entries;
// Specific properties
  @override
  List<MpmaEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final String? composeSendError;

  @override
  String toString() {
    return 'ComposeMpmaState(feeState: $feeState, balancesState: $balancesState, feeOption: $feeOption, submitState: $submitState, entries: $entries, composeSendError: $composeSendError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeMpmaStateImpl &&
            (identical(other.feeState, feeState) ||
                other.feeState == feeState) &&
            (identical(other.balancesState, balancesState) ||
                other.balancesState == balancesState) &&
            (identical(other.feeOption, feeOption) ||
                other.feeOption == feeOption) &&
            (identical(other.submitState, submitState) ||
                other.submitState == submitState) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.composeSendError, composeSendError) ||
                other.composeSendError == composeSendError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      feeState,
      balancesState,
      feeOption,
      submitState,
      const DeepCollectionEquality().hash(_entries),
      composeSendError);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeMpmaStateImplCopyWith<_$ComposeMpmaStateImpl> get copyWith =>
      __$$ComposeMpmaStateImplCopyWithImpl<_$ComposeMpmaStateImpl>(
          this, _$identity);
}

abstract class _ComposeMpmaState extends ComposeMpmaState {
  const factory _ComposeMpmaState(
      {required final FeeState feeState,
      required final BalancesState balancesState,
      required final FeeOption feeOption,
      required final SubmitState submitState,
      required final List<MpmaEntry> entries,
      final String? composeSendError}) = _$ComposeMpmaStateImpl;
  const _ComposeMpmaState._() : super._();

  @override // Inherited properties
  FeeState get feeState;
  @override
  BalancesState get balancesState;
  @override
  FeeOption get feeOption;
  @override
  SubmitState get submitState;
  @override // Specific properties
  List<MpmaEntry> get entries;
  @override
  String? get composeSendError;
  @override
  @JsonKey(ignore: true)
  _$$ComposeMpmaStateImplCopyWith<_$ComposeMpmaStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MaxValueState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int maxValue) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int maxValue)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int maxValue)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_MaxValueInitial value) initial,
    required TResult Function(_MaxValueLoading value) loading,
    required TResult Function(_MaxValueSuccess value) success,
    required TResult Function(_MaxValueError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MaxValueInitial value)? initial,
    TResult? Function(_MaxValueLoading value)? loading,
    TResult? Function(_MaxValueSuccess value)? success,
    TResult? Function(_MaxValueError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MaxValueInitial value)? initial,
    TResult Function(_MaxValueLoading value)? loading,
    TResult Function(_MaxValueSuccess value)? success,
    TResult Function(_MaxValueError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaxValueStateCopyWith<$Res> {
  factory $MaxValueStateCopyWith(
          MaxValueState value, $Res Function(MaxValueState) then) =
      _$MaxValueStateCopyWithImpl<$Res, MaxValueState>;
}

/// @nodoc
class _$MaxValueStateCopyWithImpl<$Res, $Val extends MaxValueState>
    implements $MaxValueStateCopyWith<$Res> {
  _$MaxValueStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MaxValueInitialImplCopyWith<$Res> {
  factory _$$MaxValueInitialImplCopyWith(_$MaxValueInitialImpl value,
          $Res Function(_$MaxValueInitialImpl) then) =
      __$$MaxValueInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MaxValueInitialImplCopyWithImpl<$Res>
    extends _$MaxValueStateCopyWithImpl<$Res, _$MaxValueInitialImpl>
    implements _$$MaxValueInitialImplCopyWith<$Res> {
  __$$MaxValueInitialImplCopyWithImpl(
      _$MaxValueInitialImpl _value, $Res Function(_$MaxValueInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MaxValueInitialImpl implements _MaxValueInitial {
  const _$MaxValueInitialImpl();

  @override
  String toString() {
    return 'MaxValueState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MaxValueInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int maxValue) success,
    required TResult Function(String error) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int maxValue)? success,
    TResult? Function(String error)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int maxValue)? success,
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
    required TResult Function(_MaxValueInitial value) initial,
    required TResult Function(_MaxValueLoading value) loading,
    required TResult Function(_MaxValueSuccess value) success,
    required TResult Function(_MaxValueError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MaxValueInitial value)? initial,
    TResult? Function(_MaxValueLoading value)? loading,
    TResult? Function(_MaxValueSuccess value)? success,
    TResult? Function(_MaxValueError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MaxValueInitial value)? initial,
    TResult Function(_MaxValueLoading value)? loading,
    TResult Function(_MaxValueSuccess value)? success,
    TResult Function(_MaxValueError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _MaxValueInitial implements MaxValueState {
  const factory _MaxValueInitial() = _$MaxValueInitialImpl;
}

/// @nodoc
abstract class _$$MaxValueLoadingImplCopyWith<$Res> {
  factory _$$MaxValueLoadingImplCopyWith(_$MaxValueLoadingImpl value,
          $Res Function(_$MaxValueLoadingImpl) then) =
      __$$MaxValueLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MaxValueLoadingImplCopyWithImpl<$Res>
    extends _$MaxValueStateCopyWithImpl<$Res, _$MaxValueLoadingImpl>
    implements _$$MaxValueLoadingImplCopyWith<$Res> {
  __$$MaxValueLoadingImplCopyWithImpl(
      _$MaxValueLoadingImpl _value, $Res Function(_$MaxValueLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MaxValueLoadingImpl implements _MaxValueLoading {
  const _$MaxValueLoadingImpl();

  @override
  String toString() {
    return 'MaxValueState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MaxValueLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int maxValue) success,
    required TResult Function(String error) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int maxValue)? success,
    TResult? Function(String error)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int maxValue)? success,
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
    required TResult Function(_MaxValueInitial value) initial,
    required TResult Function(_MaxValueLoading value) loading,
    required TResult Function(_MaxValueSuccess value) success,
    required TResult Function(_MaxValueError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MaxValueInitial value)? initial,
    TResult? Function(_MaxValueLoading value)? loading,
    TResult? Function(_MaxValueSuccess value)? success,
    TResult? Function(_MaxValueError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MaxValueInitial value)? initial,
    TResult Function(_MaxValueLoading value)? loading,
    TResult Function(_MaxValueSuccess value)? success,
    TResult Function(_MaxValueError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _MaxValueLoading implements MaxValueState {
  const factory _MaxValueLoading() = _$MaxValueLoadingImpl;
}

/// @nodoc
abstract class _$$MaxValueSuccessImplCopyWith<$Res> {
  factory _$$MaxValueSuccessImplCopyWith(_$MaxValueSuccessImpl value,
          $Res Function(_$MaxValueSuccessImpl) then) =
      __$$MaxValueSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int maxValue});
}

/// @nodoc
class __$$MaxValueSuccessImplCopyWithImpl<$Res>
    extends _$MaxValueStateCopyWithImpl<$Res, _$MaxValueSuccessImpl>
    implements _$$MaxValueSuccessImplCopyWith<$Res> {
  __$$MaxValueSuccessImplCopyWithImpl(
      _$MaxValueSuccessImpl _value, $Res Function(_$MaxValueSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxValue = null,
  }) {
    return _then(_$MaxValueSuccessImpl(
      null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MaxValueSuccessImpl implements _MaxValueSuccess {
  const _$MaxValueSuccessImpl(this.maxValue);

  @override
  final int maxValue;

  @override
  String toString() {
    return 'MaxValueState.success(maxValue: $maxValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaxValueSuccessImpl &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue));
  }

  @override
  int get hashCode => Object.hash(runtimeType, maxValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MaxValueSuccessImplCopyWith<_$MaxValueSuccessImpl> get copyWith =>
      __$$MaxValueSuccessImplCopyWithImpl<_$MaxValueSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int maxValue) success,
    required TResult Function(String error) error,
  }) {
    return success(maxValue);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int maxValue)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(maxValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int maxValue)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(maxValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_MaxValueInitial value) initial,
    required TResult Function(_MaxValueLoading value) loading,
    required TResult Function(_MaxValueSuccess value) success,
    required TResult Function(_MaxValueError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MaxValueInitial value)? initial,
    TResult? Function(_MaxValueLoading value)? loading,
    TResult? Function(_MaxValueSuccess value)? success,
    TResult? Function(_MaxValueError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MaxValueInitial value)? initial,
    TResult Function(_MaxValueLoading value)? loading,
    TResult Function(_MaxValueSuccess value)? success,
    TResult Function(_MaxValueError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _MaxValueSuccess implements MaxValueState {
  const factory _MaxValueSuccess(final int maxValue) = _$MaxValueSuccessImpl;

  int get maxValue;
  @JsonKey(ignore: true)
  _$$MaxValueSuccessImplCopyWith<_$MaxValueSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MaxValueErrorImplCopyWith<$Res> {
  factory _$$MaxValueErrorImplCopyWith(
          _$MaxValueErrorImpl value, $Res Function(_$MaxValueErrorImpl) then) =
      __$$MaxValueErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$MaxValueErrorImplCopyWithImpl<$Res>
    extends _$MaxValueStateCopyWithImpl<$Res, _$MaxValueErrorImpl>
    implements _$$MaxValueErrorImplCopyWith<$Res> {
  __$$MaxValueErrorImplCopyWithImpl(
      _$MaxValueErrorImpl _value, $Res Function(_$MaxValueErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$MaxValueErrorImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MaxValueErrorImpl implements _MaxValueError {
  const _$MaxValueErrorImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'MaxValueState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaxValueErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MaxValueErrorImplCopyWith<_$MaxValueErrorImpl> get copyWith =>
      __$$MaxValueErrorImplCopyWithImpl<_$MaxValueErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int maxValue) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int maxValue)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int maxValue)? success,
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
    required TResult Function(_MaxValueInitial value) initial,
    required TResult Function(_MaxValueLoading value) loading,
    required TResult Function(_MaxValueSuccess value) success,
    required TResult Function(_MaxValueError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MaxValueInitial value)? initial,
    TResult? Function(_MaxValueLoading value)? loading,
    TResult? Function(_MaxValueSuccess value)? success,
    TResult? Function(_MaxValueError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MaxValueInitial value)? initial,
    TResult Function(_MaxValueLoading value)? loading,
    TResult Function(_MaxValueSuccess value)? success,
    TResult Function(_MaxValueError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _MaxValueError implements MaxValueState {
  const factory _MaxValueError(final String error) = _$MaxValueErrorImpl;

  String get error;
  @JsonKey(ignore: true)
  _$$MaxValueErrorImplCopyWith<_$MaxValueErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
