import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';

part 'shell_state.freezed.dart';

@freezed
class ShellState with _$ShellState {
  const factory ShellState({
    required bool initialized,
    required Wallet wallet,
    required List<Account> accounts,
  }) = _ShellState;
}
