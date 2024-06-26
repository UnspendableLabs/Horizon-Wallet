// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shell_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ShellState {
  bool get redirect => throw _privateConstructorUsedError;
  Wallet? get wallet => throw _privateConstructorUsedError;
  List<Account> get accounts => throw _privateConstructorUsedError;
  String get currentAccountUuid => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ShellStateCopyWith<ShellState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShellStateCopyWith<$Res> {
  factory $ShellStateCopyWith(
          ShellState value, $Res Function(ShellState) then) =
      _$ShellStateCopyWithImpl<$Res, ShellState>;
  @useResult
  $Res call(
      {bool redirect,
      Wallet? wallet,
      List<Account> accounts,
      String currentAccountUuid});
}

/// @nodoc
class _$ShellStateCopyWithImpl<$Res, $Val extends ShellState>
    implements $ShellStateCopyWith<$Res> {
  _$ShellStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redirect = null,
    Object? wallet = freezed,
    Object? accounts = null,
    Object? currentAccountUuid = null,
  }) {
    return _then(_value.copyWith(
      redirect: null == redirect
          ? _value.redirect
          : redirect // ignore: cast_nullable_to_non_nullable
              as bool,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as Wallet?,
      accounts: null == accounts
          ? _value.accounts
          : accounts // ignore: cast_nullable_to_non_nullable
              as List<Account>,
      currentAccountUuid: null == currentAccountUuid
          ? _value.currentAccountUuid
          : currentAccountUuid // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShellStateImplCopyWith<$Res>
    implements $ShellStateCopyWith<$Res> {
  factory _$$ShellStateImplCopyWith(
          _$ShellStateImpl value, $Res Function(_$ShellStateImpl) then) =
      __$$ShellStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool redirect,
      Wallet? wallet,
      List<Account> accounts,
      String currentAccountUuid});
}

/// @nodoc
class __$$ShellStateImplCopyWithImpl<$Res>
    extends _$ShellStateCopyWithImpl<$Res, _$ShellStateImpl>
    implements _$$ShellStateImplCopyWith<$Res> {
  __$$ShellStateImplCopyWithImpl(
      _$ShellStateImpl _value, $Res Function(_$ShellStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redirect = null,
    Object? wallet = freezed,
    Object? accounts = null,
    Object? currentAccountUuid = null,
  }) {
    return _then(_$ShellStateImpl(
      redirect: null == redirect
          ? _value.redirect
          : redirect // ignore: cast_nullable_to_non_nullable
              as bool,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as Wallet?,
      accounts: null == accounts
          ? _value._accounts
          : accounts // ignore: cast_nullable_to_non_nullable
              as List<Account>,
      currentAccountUuid: null == currentAccountUuid
          ? _value.currentAccountUuid
          : currentAccountUuid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ShellStateImpl implements _ShellState {
  const _$ShellStateImpl(
      {required this.redirect,
      required this.wallet,
      required final List<Account> accounts,
      required this.currentAccountUuid})
      : _accounts = accounts;

  @override
  final bool redirect;
  @override
  final Wallet? wallet;
  final List<Account> _accounts;
  @override
  List<Account> get accounts {
    if (_accounts is EqualUnmodifiableListView) return _accounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accounts);
  }

  @override
  final String currentAccountUuid;

  @override
  String toString() {
    return 'ShellState(redirect: $redirect, wallet: $wallet, accounts: $accounts, currentAccountUuid: $currentAccountUuid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShellStateImpl &&
            (identical(other.redirect, redirect) ||
                other.redirect == redirect) &&
            (identical(other.wallet, wallet) || other.wallet == wallet) &&
            const DeepCollectionEquality().equals(other._accounts, _accounts) &&
            (identical(other.currentAccountUuid, currentAccountUuid) ||
                other.currentAccountUuid == currentAccountUuid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, redirect, wallet,
      const DeepCollectionEquality().hash(_accounts), currentAccountUuid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShellStateImplCopyWith<_$ShellStateImpl> get copyWith =>
      __$$ShellStateImplCopyWithImpl<_$ShellStateImpl>(this, _$identity);
}

abstract class _ShellState implements ShellState {
  const factory _ShellState(
      {required final bool redirect,
      required final Wallet? wallet,
      required final List<Account> accounts,
      required final String currentAccountUuid}) = _$ShellStateImpl;

  @override
  bool get redirect;
  @override
  Wallet? get wallet;
  @override
  List<Account> get accounts;
  @override
  String get currentAccountUuid;
  @override
  @JsonKey(ignore: true)
  _$$ShellStateImplCopyWith<_$ShellStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
