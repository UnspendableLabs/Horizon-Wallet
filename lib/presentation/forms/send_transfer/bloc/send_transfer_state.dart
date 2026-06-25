import 'package:formz/formz.dart';
import 'package:horizon/presentation/common/password_input.dart';

enum SendTransferStatus { composing, review, broadcasting, success, failure }

class SendTransferState with FormzMixin {
  final SendTransferStatus status;
  final PasswordInput password;

  // Network fee of the composed transaction, in satoshis.
  final int feeSats;
  final String? txid;
  final String? error;

  const SendTransferState({
    this.status = SendTransferStatus.composing,
    this.password = const PasswordInput.pure(),
    this.feeSats = 0,
    this.txid,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [password];

  SendTransferState copyWith({
    SendTransferStatus? status,
    PasswordInput? password,
    int? feeSats,
    String? txid,
    String? error,
  }) {
    return SendTransferState(
      status: status ?? this.status,
      password: password ?? this.password,
      feeSats: feeSats ?? this.feeSats,
      txid: txid ?? this.txid,
      error: error ?? this.error,
    );
  }
}
