import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/usecases/get_fee_estimates.dart';
import 'package:horizon/presentation/common/password_input.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';

import './send_transfer_event.dart';
import './send_transfer_state.dart';

/// Drives the sats-connect `sendTransfer` RPC: compose a plain BTC send from
/// the wallet's payment address, let the user review the fee, then sign and
/// broadcast on confirmation. The fee rate is picked by the wallet (medium
/// estimate) since sats-connect's `sendTransfer` carries no fee parameter.
class SendTransferBloc extends Bloc<SendTransferEvent, SendTransferState> {
  final AddressV2 source;
  final String destination;
  final int amount; // satoshis
  final HttpConfig httpConfig;
  final bool passwordRequired;

  final GetFeeEstimatesUseCase _getFeeEstimatesUseCase;
  final ComposeTransactionUseCase _composeTransactionUseCase;
  final ComposeRepository _composeRepository;
  final SignAndBroadcastTransactionUseCase _signAndBroadcastTransactionUseCase;

  String? _rawtransaction;

  SendTransferBloc({
    required this.source,
    required this.destination,
    required this.amount,
    required this.httpConfig,
    required this.passwordRequired,
    GetFeeEstimatesUseCase? getFeeEstimatesUseCase,
    ComposeTransactionUseCase? composeTransactionUseCase,
    ComposeRepository? composeRepository,
    SignAndBroadcastTransactionUseCase? signAndBroadcastTransactionUseCase,
  })  : _getFeeEstimatesUseCase =
            getFeeEstimatesUseCase ?? GetIt.I<GetFeeEstimatesUseCase>(),
        _composeTransactionUseCase =
            composeTransactionUseCase ?? GetIt.I<ComposeTransactionUseCase>(),
        _composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        _signAndBroadcastTransactionUseCase =
            signAndBroadcastTransactionUseCase ??
                GetIt.I<SignAndBroadcastTransactionUseCase>(),
        super(const SendTransferState()) {
    on<ComposeRequested>(_onComposeRequested);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmSend>(_onConfirmSend);
    add(ComposeRequested());
  }

  void _onPasswordChanged(
      PasswordChanged event, Emitter<SendTransferState> emit) {
    // Never resurrect the review screen once a broadcast is in flight (or has
    // succeeded): doing so would re-enable the Confirm button and let a stray
    // keystroke in the still-mounted password field trigger a second
    // sign-and-broadcast of the same transaction.
    if (state.status == SendTransferStatus.broadcasting ||
        state.status == SendTransferStatus.success) {
      return;
    }
    emit(state.copyWith(
      password: PasswordInput.dirty(event.password),
      status: SendTransferStatus.review,
    ));
  }

  Future<void> _onComposeRequested(
      ComposeRequested event, Emitter<SendTransferState> emit) async {
    emit(state.copyWith(status: SendTransferStatus.composing, error: null));

    final feeResult = await _getFeeEstimatesUseCase
        .call(GetFeeEstimatesParams(httpConfig: httpConfig))
        .run();

    final num? feeRate = feeResult.fold((_) => null, (estimates) => estimates.medium);
    if (feeRate == null) {
      emit(state.copyWith(
        status: SendTransferStatus.composeFailure,
        error: 'Failed to fetch fee estimates',
      ));
      return;
    }

    final composeResult = await _composeTransactionUseCase
        .callT<ComposeSendParams, ComposeSendResponse>(
          feeRate: feeRate,
          source: source.address,
          params: ComposeSendParams(
            source: source.address,
            destination: destination,
            asset: 'BTC',
            quantity: amount,
          ),
          composeFn: _composeRepository.composeSendVerbose,
          httpConfig: httpConfig,
        )
        .run();

    composeResult.fold(
      (error) => emit(state.copyWith(
        status: SendTransferStatus.composeFailure,
        error: error,
      )),
      (resp) {
        _rawtransaction = resp.rawtransaction;
        emit(state.copyWith(
          status: SendTransferStatus.review,
          feeSats: resp.btcFee,
        ));
      },
    );
  }

  Future<void> _onConfirmSend(
      ConfirmSend event, Emitter<SendTransferState> emit) async {
    // Re-entrancy guard. Bloc's default (concurrent) transformer plus the
    // window between the first tap and the Confirm button disabling on the
    // broadcasting state means two ConfirmSend events can race. The cached
    // `_rawtransaction` would then be broadcast twice, so refuse any confirm
    // once a broadcast is in flight or has already succeeded.
    if (state.status == SendTransferStatus.broadcasting ||
        state.status == SendTransferStatus.success) {
      return;
    }

    final raw = _rawtransaction;
    if (raw == null) {
      // No composed transaction to broadcast — treat as a fatal compose failure
      // so the dApp is notified and the popup closes.
      emit(state.copyWith(
        status: SendTransferStatus.composeFailure,
        error: 'Transaction not composed',
      ));
      return;
    }

    emit(state.copyWith(status: SendTransferStatus.broadcasting, error: null));

    final decryptionStrategy =
        passwordRequired ? Password(state.password.value) : InMemoryKey();

    final result = await _signAndBroadcastTransactionUseCase
        .call(SignAndBroadcastTransactionParams(
          source: source,
          decryptionStrategy: decryptionStrategy,
          rawtransaction: raw,
          httpConfig: httpConfig,
        ))
        .run();

    result.fold(
      (error) => emit(state.copyWith(
        // Retryable: the transaction is still cached, so keep the popup open and
        // let the user fix the cause (e.g. password) and resend.
        status: SendTransferStatus.broadcastFailure,
        error: error,
      )),
      (broadcast) => emit(state.copyWith(
        status: SendTransferStatus.success,
        txid: broadcast.hash,
      )),
    );
  }
}
