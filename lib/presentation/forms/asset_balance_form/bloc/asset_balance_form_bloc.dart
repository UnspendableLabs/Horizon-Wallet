import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetBalanceFormOption {
  final MultiAddressBalanceEntry entry;
  const AssetBalanceFormOption({
    required this.entry,
  });
}

sealed class AssetBalanceFormEvent extends Equatable {
  const AssetBalanceFormEvent();

  @override
  List<Object?> get props => [];
}

class AssetBalanceFormRequested extends AssetBalanceFormEvent {
  final List<String> addresses;

  const AssetBalanceFormRequested({
    required this.addresses,
  });
}

class AssetBalanceSelected extends AssetBalanceFormEvent {
  final AssetBalanceFormOption option;

  const AssetBalanceSelected({
    required this.option,
  });

  @override
  List<Object?> get props => [option];
}

class SubmitClicked extends AssetBalanceFormEvent {
  const SubmitClicked();
  @override
  List<Object?> get props => [];
}

enum BalanceInputError { required }

class BalanceInput
    extends FormzInput<AssetBalanceFormOption?, BalanceInputError> {
  const BalanceInput.dirty({required AssetBalanceFormOption? value})
      : super.dirty(value);

  const BalanceInput.pure() : super.pure(null);

  @override
  BalanceInputError? validator(AssetBalanceFormOption? value) {
    if (value == null) {
      return BalanceInputError.required;
    }
    return null;
  }
}

class AssetBalanceFormModel with FormzMixin {
  final MultiAddressBalance multiAddressBalance;

  final RemoteData<Map<String, bool>> utxoSwapMap;

  final BalanceInput balanceInput;

  final FormzSubmissionStatus submissionStatus;

  AssetBalanceFormModel(
      {required this.utxoSwapMap,
      required this.multiAddressBalance,
      required this.balanceInput,
      required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [balanceInput];

  AssetBalanceFormModel copyWith({
    MultiAddressBalance? multiAddressBalance,
    BalanceInput? balanceInput,
    FormzSubmissionStatus? submissionStatus,
    RemoteData<Map<String, bool>>? utxoSwapMap,
  }) {
    return AssetBalanceFormModel(
      utxoSwapMap: utxoSwapMap ?? this.utxoSwapMap,
      multiAddressBalance: multiAddressBalance ?? this.multiAddressBalance,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      balanceInput: balanceInput ?? this.balanceInput,
    );
  }
}

class AssetBalanceFormBloc
    extends Bloc<AssetBalanceFormEvent, AssetBalanceFormModel> {
  final AtomicSwapRepository _atomicSwapRepository;

  final HttpConfig httpConfig;

  AssetBalanceFormBloc(
      {AtomicSwapRepository? atomicSwapRepository,
      required this.httpConfig,
      required List<String> addresses,
      required MultiAddressBalance multiAddressBalance})
      : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        super(AssetBalanceFormModel(
          utxoSwapMap: const Initial(),
          multiAddressBalance: multiAddressBalance,
          balanceInput: const BalanceInput.pure(),
          submissionStatus: FormzSubmissionStatus.initial,
        )) {
    on<AssetBalanceFormRequested>(_handleAssetBalanceFormRequested);
    on<AssetBalanceSelected>(_handleAssetBalanceSelected);
    on<SubmitClicked>(_handleSubmitClicked);

    // TODO: technically we could refetch on a timer
    add(AssetBalanceFormRequested(addresses: addresses));
  }

  _handleAssetBalanceFormRequested(
    AssetBalanceFormRequested event,
    Emitter<AssetBalanceFormModel> emit,
  ) async {
    emit(state.copyWith(utxoSwapMap: const Loading()));

    final task = TaskEither<String, Map<String, bool>>.Do(($) async {
      final tasks = event.addresses.map((address) {
        return _atomicSwapRepository.getUtxoSwapMapT(
            httpConfig: httpConfig,
            sellerAddress: address,
            onError: (error, stacktrace) {
              return "There was an error fetching the utxo swap map";
            });
      });

      return await $(TaskEither.sequenceList(tasks.toList())
          .map((listOfMaps) => listOfMaps.fold<Map<String, bool>>(
                {},
                (acc, map) => {...acc, ...map},
              )));
    });

    final result = await task.run();

    final nextState = result.fold(
      (error) => state.copyWith(utxoSwapMap: Failure(error)),
      (utxoSwapMap) => state.copyWith(utxoSwapMap: Success(utxoSwapMap)),
    );

    emit(nextState);
  }

  _handleAssetBalanceSelected(
    AssetBalanceSelected event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    if (state.utxoSwapMap.getOrNull() == null) {
      return;
    }

    emit(state.copyWith(
      balanceInput: BalanceInput.dirty(value: event.option),
    ));
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    if (state.utxoSwapMap.getOrNull() == null) {
      return;
    }

    if (state.balanceInput.value == null) {
      return;
    }

    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.success,
    ));
  }
}
