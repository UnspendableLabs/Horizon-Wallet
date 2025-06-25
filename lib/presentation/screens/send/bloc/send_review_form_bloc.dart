import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:fpdart/fpdart.dart';

class SendReviewFormBloc
    extends Bloc<SendReviewFormEvent, SendReviewFormModel> {
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  final HttpConfig httpConfig;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final AddressV2 sourceAddress;
  SendReviewFormBloc(
      {required this.sendEntries,
      required this.httpConfig,
      required this.composeResponse,
      required this.sourceAddress,
      required this.signAndBroadcastTransactionUseCase})
      : super(SendReviewFormModel(
          submissionStatus: FormzSubmissionStatus.initial,
          sendEntries: sendEntries,
          composeResponse: composeResponse,
          signedTxHex: "",
          signedTxHash: "",
        )) {
    on<OnSignAndSubmitEvent>(_handleSignAndSubmit);
  }

  _handleSignAndSubmit(
      OnSignAndSubmitEvent event, Emitter<SendReviewFormModel> emit) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    final composeData = switch (state.composeResponse) {
      ComposeSendMpma(:final response) => response,
      ComposeSendSingle(:final response) => response,
      _ => throw Exception("invariant"),
    };

    final task =
        TaskEither<String, ({String txHex, String txHash})>.Do(($) async {
      final broadcastResponse =
          await $(signAndBroadcastTransactionUseCase.callT(
        httpConfig: httpConfig,
        decryptionStrategy: event.decryptionStrategy,
        source: sourceAddress,
        rawtransaction: composeData.rawtransaction,
      ));

      return (txHex: broadcastResponse.hex, txHash: broadcastResponse.hash);
    });

    final result = await task.run();

    result.fold(
      (error) => emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
      )),
      (success) => emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        signedTxHex: success.txHex,
        signedTxHash: success.txHash,
      )),
    );
  }
}

class SendReviewFormEvent {}

class OnSignAndSubmitEvent extends SendReviewFormEvent {
  final DecryptionStrategy decryptionStrategy;
  OnSignAndSubmitEvent({required this.decryptionStrategy});
}

class SendReviewFormModel with FormzMixin {
  final FormzSubmissionStatus submissionStatus;
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  final String signedTxHex;
  final String signedTxHash;
  SendReviewFormModel(
      {required this.submissionStatus,
      required this.sendEntries,
      required this.composeResponse,
      required this.signedTxHex,
      required this.signedTxHash});

  @override
  List<FormzInput> get inputs => [];

  SendReviewFormModel copyWith(
      {FormzSubmissionStatus? submissionStatus,
      ComposeSendUnion? composeResponse,
      List<SendEntryFormModel>? sendEntries,
      String? signedTxHex,
      String? signedTxHash}) {
    return SendReviewFormModel(
        submissionStatus: submissionStatus ?? this.submissionStatus,
        sendEntries: sendEntries ?? this.sendEntries,
        composeResponse: composeResponse ?? this.composeResponse,
        signedTxHex: signedTxHex ?? this.signedTxHex,
        signedTxHash: signedTxHash ?? this.signedTxHash);
  }
}
