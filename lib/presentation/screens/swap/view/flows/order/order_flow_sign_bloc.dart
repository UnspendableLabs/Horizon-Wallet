import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/http_config.dart' hide Custom;
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/forms/base/transaction_form_model_base.dart';
import 'package:rxdart/rxdart.dart';

enum FeeOptionError { invalid }

class FeeOptionInput extends FormzInput<FeeOption, FeeOptionError> {
  FeeOptionInput.pure() : super.pure(Medium());
  const FeeOptionInput.dirty(super.value) : super.dirty();
  @override
  FeeOptionError? validator(FeeOption value) {
    return switch (value) {
      Custom(fee: var value) => value < 0 ? FeeOptionError.invalid : null,
      _ => null
    };
  }
}

sealed class OrderComposeFormEvent extends Equatable {
  const OrderComposeFormEvent();
  @override
  List<Object?> get props => [];
}

class FeeOptionChanged extends OrderComposeFormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SubmitClicked extends OrderComposeFormEvent {
  const SubmitClicked();
  @override
  List<Object?> get props => [];
}

class CloseSignModalClicked extends OrderComposeFormEvent {
  const CloseSignModalClicked();
  @override
  List<Object?> get props => [];
}

class OrderReviewFormModel with FormzMixin {
  final String giveAsset;
  final String getAsset;
  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;
  final FeeEstimates feeEstimates;

  final String sourceAddress;
  final bool showSignPsbtModal;
  final FormzSubmissionStatus signatureStatus;
  final FeeOptionInput feeOptionInput;
  final Option<String> error;
  final Option<ComposeOrderResponse> composeResponse;

  @override
  get inputs => [
        feeOptionInput,
      ];

  OrderReviewFormModel({
    required this.showSignPsbtModal,
    required this.feeEstimates,
    required this.feeOptionInput,
    required this.signatureStatus,
    required this.sourceAddress,
    required this.error,
    required this.giveAsset,
    required this.getAsset,
    required this.giveQuantity,
    required this.getQuantity,
    required this.composeResponse,
  });

  OrderReviewFormModel copyWith({
    String? giveAsset,
    String? getAsset,
    AssetQuantity? giveQuantity,
    AssetQuantity? getQuantity,
    List<SendEntryFormModel>? sendEntries,
    List<MultiAddressBalance>? balances,
    FeeEstimates? feeEstimates,
    FeeOptionInput? feeOptionInput,
    FormzSubmissionStatus? signatureStatus,
    Option<String>? error,
    String? sourceAddress,
    Option<ComposeOrderResponse>? composeResponse,
    bool? showSignPsbtModal,
  }) {
    return OrderReviewFormModel(
      composeResponse: composeResponse ?? this.composeResponse,
      showSignPsbtModal: showSignPsbtModal ?? this.showSignPsbtModal,
      signatureStatus: signatureStatus ?? this.signatureStatus,
      giveAsset: giveAsset ?? this.giveAsset,
      getAsset: getAsset ?? this.getAsset,
      giveQuantity: giveQuantity ?? this.giveQuantity,
      getQuantity: getQuantity ?? this.getQuantity,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      error: error ?? this.error,
      sourceAddress: sourceAddress ?? this.sourceAddress,
    );
  }

  num get getSatsPerVByte => switch (feeOptionInput.value) {
        Slow() => feeEstimates.slow,
        Medium() => feeEstimates.medium,
        Fast() => feeEstimates.fast,
        Custom(fee: var value) => value
      };
}

class OrderComposeFormBloc
    extends Bloc<OrderComposeFormEvent, OrderReviewFormModel> {
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final HttpConfig httpConfig;

  OrderComposeFormBloc({
    required String giveAsset,
    required String getAsset,
    required AssetQuantity giveQuantity,
    required AssetQuantity getQuantity,
    required FeeEstimates feeEstimates,
    required String sourceAddress,
    required this.httpConfig,
    TransactionService? transactionService,
  })  : composeTransactionUseCase = GetIt.I<ComposeTransactionUseCase>(),
        composeRepository = GetIt.I<ComposeRepository>(),
        super(OrderReviewFormModel(
          composeResponse: const None(),
          error: const Option.none(),
          showSignPsbtModal: false,
          giveAsset: giveAsset,
          getAsset: getAsset,
          giveQuantity: giveQuantity,
          getQuantity: getQuantity,
          feeEstimates: feeEstimates,
          feeOptionInput: FeeOptionInput.pure(),
          signatureStatus: FormzSubmissionStatus.initial,
          sourceAddress: sourceAddress,
        )) {
    on<SubmitClicked>(_onSubmitClicked);
    on<FeeOptionChanged>(_onFeeOptionChanged);
    on<CloseSignModalClicked>(
      (event, emit) => emit(state.copyWith(
        showSignPsbtModal: false,
        signatureStatus: FormzSubmissionStatus.initial,
      )),
    );
  }

  void _onFeeOptionChanged(
      FeeOptionChanged event, Emitter<OrderReviewFormModel> emit) {
    emit(state.copyWith(feeOptionInput: FeeOptionInput.dirty(event.value)));
  }

  void _onSubmitClicked(
      SubmitClicked event, Emitter<OrderReviewFormModel> emit) async {
    emit(state.copyWith(
      signatureStatus: FormzSubmissionStatus.inProgress,
    ));

    final task = TaskEither<String, ComposeOrderResponse>.Do(($) async {
      final composeResponse = $(composeTransactionUseCase.callT(
        feeRate: state
            .getSatsPerVByte, // this is already defined on TransactionFormModelBase
        source: state.sourceAddress,
        params: ComposeOrderParams(
          source: state.sourceAddress,
          giveAsset: state.giveAsset,
          giveQuantity: state.giveQuantity.quantity.toInt(),
          getAsset: state.getAsset,
          getQuantity: state.getQuantity.quantity.toInt(),
        ),
        composeFn: composeRepository.composeOrder,
        httpConfig: httpConfig,
      ));

      return composeResponse;
    });

    final result = await task.run();

    result.fold(
      (error) => emit(state.copyWith(
        error: Option.of(error),
        signatureStatus: FormzSubmissionStatus.initial,
      )),
      (composeResponse) => emit(state.copyWith(
        signatureStatus: FormzSubmissionStatus.inProgress,
        showSignPsbtModal: true,
        composeResponse: Option.of(composeResponse),
      )),
    );
  }
}
