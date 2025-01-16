import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import "package:fpdart/fpdart.dart";
import 'dart:math';

import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/domain/services/transaction_service.dart';

unwrapOrThrow<L extends Object, T>(Either<L, T> either) {
  return either.fold(
    (l) => throw l,
    (r) => r,
  );
}

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRequested extends FormEvent {
  final String txHash;

  const InitializeRequested({required this.txHash});

  @override
  List<Object?> get props => [txHash];
}

class FeeOptionChanged extends FormEvent {
  final FeeOption.FeeOption feeOption;
  const FeeOptionChanged(this.feeOption);
  @override
  List<Object?> get props => [feeOption];
}

class FormSubmitted extends FormEvent {
  BitcoinTx tx;
  String hex;
  int adjustedVirtualSize;
  int newFeeRate;

  FormSubmitted(
      {required this.tx,
      required this.hex,
      required this.adjustedVirtualSize,
      required this.newFeeRate});
}

class FormStateModel extends Equatable {
  final String txHash;

  final RemoteData<RBFData> rbfData;
  final RemoteData<FeeEstimates> feeEstimates;
  final FeeOption.FeeOption feeOption;

  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;
  final MakeRBFResponse? rbfResponse;

  const FormStateModel({
    required this.txHash,
    required this.rbfData,
    required this.feeEstimates,
    required this.feeOption,
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.rbfResponse,
  });

  FormStateModel copyWith({
    String? txHash,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
    FeeOption.FeeOption? feeOption,
    RemoteData<FeeEstimates>? feeEstimates,
    RemoteData<RBFData>? rbfData,
    MakeRBFResponse? rbfResponse,
  }) {
    return FormStateModel(
        txHash: txHash ?? this.txHash,
        rbfData: rbfData ?? this.rbfData,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        errorMessage: errorMessage ?? this.errorMessage,
        feeEstimates: feeEstimates ?? this.feeEstimates,
        feeOption: feeOption ?? this.feeOption,
        rbfResponse: rbfResponse ?? this.rbfResponse);
  }

  @override
  List<Object?> get props => [
        rbfData,
        feeEstimates,
        submissionStatus,
        errorMessage,
        feeOption,
        rbfResponse,
      ];
}

class RBFData {
  final BitcoinTx tx;
  final String hex;
  final int adjustedSize;

  RBFData({required this.tx, required this.hex, required this.adjustedSize});
}

class ReplaceByFeeFormBloc extends Bloc<FormEvent, FormStateModel> {
  final TransactionService transactionService;
  BitcoinRepository bitcoinRepository;
  GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  String txHash;

  ReplaceByFeeFormBloc({
    required this.txHash,
    required this.getFeeEstimatesUseCase,
    required this.bitcoinRepository,
    required this.transactionService,
  }) : super(FormStateModel(
          txHash: txHash,
          feeEstimates: NotAsked(),
          rbfData: NotAsked(),
          feeOption: FeeOption.Medium(),
        )) {
    on<InitializeRequested>(_onInitializeRequested);

    on<FeeOptionChanged>(_onFeeOptionChanged);

    on<FormSubmitted>(_onFormSubmitted);
  }

  _onFormSubmitted(FormSubmitted event, Emitter<FormStateModel> emit) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    try {
      int newFee = event.newFeeRate * event.adjustedVirtualSize;

      int feeBump = newFee - event.tx.fee;

      MakeRBFResponse rbfResponse = await transactionService.makeRBF(
        txHex: event.hex,
        oldFee: event.tx.fee,
        newFee: newFee,
      );


      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.success, rbfResponse: rbfResponse));


      // reset the form
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.initial, rbfResponse: null));

              
    } on TransactionServiceException catch (e) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      print(e);
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
      ));
    }
  }

  _onInitializeRequested(
      InitializeRequested event, Emitter<FormStateModel> emit) async {
    emit(state.copyWith(
      feeEstimates: Loading<FeeEstimates>(),
      rbfData: Loading<RBFData>(),
    ));

    try {
      final feeEstimates = await _fetchFeeEstimates();

      BitcoinTx bitcoinTransaction =
          unwrapOrThrow(await bitcoinRepository.getTransaction(txHash));

      String bitcoinTransactionHex =
          unwrapOrThrow(await bitcoinRepository.getTransactionHex(txHash));

      final virtualSize =
          transactionService.getVirtualSize(bitcoinTransactionHex);

      final sigOps = transactionService.countSigOps(
        rawtransaction: bitcoinTransactionHex,
      );

      final adjustedVirtualSize = max(virtualSize, sigOps * 5);

      emit(state.copyWith(
          feeEstimates: Success<FeeEstimates>(feeEstimates),
          rbfData: Success<RBFData>(RBFData(
              tx: bitcoinTransaction,
              hex: bitcoinTransactionHex,
              adjustedSize: adjustedVirtualSize))));

    } catch (e) {
      print(e);
    }
  }

  Future<void> _onFeeOptionChanged(
      FeeOptionChanged event, Emitter<FormStateModel> emit) async {
    final nextState = state.copyWith(feeOption: event.feeOption);

    emit(nextState);
  }

  Future<FeeEstimates> _fetchFeeEstimates() async {
    try {
      return await getFeeEstimatesUseCase.call();
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}
