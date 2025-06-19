import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/forms/base/transaction_form_model_base.dart';
import 'package:rxdart/rxdart.dart';

sealed class SendComposeFormEvent extends Equatable {
  const SendComposeFormEvent();
  @override
  List<Object?> get props => [];
}

class AddEntry extends SendComposeFormEvent {}

class UpdateEntry extends SendComposeFormEvent {
  final int index;
  final SendEntryFormModel form;
  const UpdateEntry(this.index, this.form);
  @override
  List<Object?> get props => [index, form];
}

class RemoveEntry extends SendComposeFormEvent {
  final int index;
  const RemoveEntry(this.index);
  @override
  List<Object?> get props => [index];
}

class FeeOptionChanged extends SendComposeFormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SubmitClicked extends SendComposeFormEvent {
  const SubmitClicked();
  @override
  List<Object?> get props => [];
}

sealed class ComposeSendUnion {}

class ComposeSendMpma extends ComposeSendUnion {
  final ComposeMpmaSendResponse response;
  ComposeSendMpma(this.response);

  @override
  String toString() {
    return "ComposeSendMpma(response: $response)";
  }
}

class ComposeSendSingle extends ComposeSendUnion {
  final ComposeSendResponse response;
  ComposeSendSingle(this.response);

  @override
  String toString() {
    return "ComposeSendSingle(response: $response)";
  }
}

class SendComposeFormModel extends TransactionFormModelBase {
  final List<SendEntryFormModel> sendEntries;
  final List<MultiAddressBalance> balances;
  final String sourceAddress;

  @override
  final ComposeResponse? composeResponse;

  SendComposeFormModel({
    required super.feeEstimates,
    required super.feeOptionInput,
    required super.submissionStatus,
    required this.sourceAddress,
    super.error,
    required this.sendEntries,
    required this.balances,
    this.composeResponse,
  });

  @override
  List<FormzInput> get inputs =>
      [...sendEntries.expand((entry) => entry.inputs), feeOptionInput];

  bool get allEntriesAreValid => sendEntries.every((e) => e.isValid);

  SendComposeFormModel copyWith({
    List<SendEntryFormModel>? sendEntries,
    List<MultiAddressBalance>? balances,
    FeeEstimates? feeEstimates,
    FeeOptionInput? feeOptionInput,
    FormzSubmissionStatus? submissionStatus,
    String? error,
    String? sourceAddress,
    ComposeResponse? composeResponse,
  }) {
    return SendComposeFormModel(
      sendEntries: sendEntries ?? this.sendEntries,
      balances: balances ?? this.balances,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error ?? this.error,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      composeResponse: composeResponse ?? this.composeResponse,
    );
  }

  bool get isMpma => sendEntries.length > 1;

  Either<String, ComposeParams> get composeParams {
    if (isMpma) {
      final assets = [];
      final quantities = [];
      final destinations = [];
      for (var entry in sendEntries) {
        if (!entry.isValid) {
          return left("Invalid entry");
        }
        assets.add(entry.balanceSelectorInput.value!.asset);
        quantities.add(entry.quantityInput.valueAsBigInt.getOrElse(() => throw Exception("Invalid quantity")));
        destinations.add(entry.destinationInput.value);
      }
      return right(ComposeMpmaSendParams(
        assets: assets.join(","),
        quantities: quantities.join(","),
        destinations: destinations.join(","),
        memos: sendEntries.map((e) => e.memoInput.value).toList(),
        source: sourceAddress,
      ));
    } else {
      final entry = sendEntries.first;
      if (!entry.isValid) {
        return left("Invalid entry");
      }
      final isDivisible = entry.balanceSelectorInput.value!.assetInfo.divisible;
      final quantityNormalized = Decimal.parse(entry.quantityInput.value);
      final quantity = isDivisible
          ? quantityNormalized * Decimal.fromInt(100000000)
          : quantityNormalized;
      return right(ComposeSendParams(
        asset: entry.balanceSelectorInput.value!.asset,
        quantity: quantity.toBigInt().toInt(),
        destination: entry.destinationInput.value,
        source: sourceAddress,
        memo: entry.memoInput.value,
      ));
    }
  }
}

class SendComposeFormBloc
    extends Bloc<SendComposeFormEvent, SendComposeFormModel> {
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final HttpConfig httpConfig;
  SendComposeFormBloc(
      {required List<SendEntryFormModel> initialEntries,
      required List<MultiAddressBalance> initialBalances,
      required FeeEstimates feeEstimates,
      required String sourceAddress,
      required this.httpConfig})
      : composeTransactionUseCase = GetIt.I<ComposeTransactionUseCase>(),
        composeRepository = GetIt.I<ComposeRepository>(),
        super(SendComposeFormModel(
          sendEntries: initialEntries,
          balances: initialBalances,
          feeEstimates: feeEstimates,
          feeOptionInput: FeeOptionInput.pure(),
          submissionStatus: FormzSubmissionStatus.initial,
          sourceAddress: sourceAddress,
        )) {
    on<AddEntry>(_onAddEntry);
    on<RemoveEntry>(_onRemoveEntry);
    on<FeeOptionChanged>(_onFeeOptionChanged);
    on<SubmitClicked>(_onSubmitClicked);
    on<UpdateEntry>(
      _onUpdateEntry,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
  }

  void _onUpdateEntry(UpdateEntry event, Emitter<SendComposeFormModel> emit) {
    List<SendEntryFormModel> newEntries = List.from(state.sendEntries);
    newEntries[event.index] = event.form;
    emit(state.copyWith(sendEntries: newEntries));
  }

  void _onFeeOptionChanged(
      FeeOptionChanged event, Emitter<SendComposeFormModel> emit) {
    emit(state.copyWith(feeOptionInput: FeeOptionInput.dirty(event.value)));
  }

  void _onAddEntry(AddEntry event, Emitter<SendComposeFormModel> emit) {
    final newEntries = List<SendEntryFormModel>.from(state.sendEntries)
      ..add(SendEntryFormModel(
        destinationInput: const DestinationInput.pure(),
        quantityInput: QuantityInput.pure(
            maxQuantity: BigInt.zero, divisible: false),
        balanceSelectorInput: const BalanceSelectorInput.pure(),
        memoInput: const MemoInput.pure(),
      ));
    emit(state.copyWith(sendEntries: newEntries));
  }

  void _onRemoveEntry(RemoveEntry event, Emitter<SendComposeFormModel> emit) {
    final newEntries = List<SendEntryFormModel>.from(state.sendEntries)
      ..removeAt(event.index);
    emit(state.copyWith(sendEntries: newEntries));
  }

  void _onSubmitClicked(
      SubmitClicked event, Emitter<SendComposeFormModel> emit) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    final task = TaskEither<String, ComposeResponse>.Do(($) async {
      final composeParams = await $(TaskEither.fromEither(state.composeParams));

      final composeT = switch (composeParams) {
        ComposeMpmaSendParams() => composeTransactionUseCase.callT(
            feeRate: state
                .getSatsPerVByte, // this is already defined on TransactionFormModelBase
            source: state.sourceAddress,
            params: composeParams,
            composeFn: composeRepository.composeMpmaSend,
            httpConfig: httpConfig,
          ),
        ComposeSendParams() => composeTransactionUseCase.callT(
            feeRate: state
                .getSatsPerVByte, // this is already defined on TransactionFormModelBase
            source: state.sourceAddress,
            params: composeParams,
            composeFn: composeRepository.composeSendVerbose,
            httpConfig: httpConfig,
          ),
        _ => throw Exception("invariant"),
      };

      return await $(composeT);
    });

    final result = await task.run();

    result.fold(
      (error) => emit(state.copyWith(
        error: error,
        submissionStatus: FormzSubmissionStatus.failure,
      )),
      (composeResponse) => emit(state.copyWith(
        composeResponse: composeResponse,
        submissionStatus: FormzSubmissionStatus.success,
      )),
    );
  }
}
