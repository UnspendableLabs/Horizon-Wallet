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

sealed class UtxoSwapInputError {}

class UtxoSwapInputErrorRequired extends UtxoSwapInputError {}

class UtxoSwapInputErrorListed extends UtxoSwapInputError {
  // eventually let's embed the swapUUID so we can render
  // a link to it in the error;

  // final String swapUUID;
  UtxoSwapInputErrorListed(
      // {required this.swapUUID}
      );
}

// enum UtxoSwapInputError { required, listed }

class SwapExistsInput
    extends FormzInput<AssetBalanceFormOption?, UtxoSwapInputError> {
  final Map<String, bool>? utxoSwapMap;
  const SwapExistsInput.pure({this.utxoSwapMap}) : super.pure(null);
  const SwapExistsInput.dirty(
      {required AssetBalanceFormOption? value, this.utxoSwapMap})
      : super.dirty(value);

  @override
  UtxoSwapInputError? validator(AssetBalanceFormOption? value) {
    if (value == null) return UtxoSwapInputErrorRequired();
    if (utxoSwapMap != null &&
        value.entry.utxo != null &&
        utxoSwapMap![value.entry.utxo] == true) {
      return UtxoSwapInputErrorListed();
    }
    return null;
  }
}

enum AssetIsUtxoInputError { isUtxo, required }

class AssetIsUtxoInput
    extends FormzInput<AssetBalanceFormOption?, AssetIsUtxoInputError> {
  const AssetIsUtxoInput.pure() : super.pure(null);

  const AssetIsUtxoInput.dirty({required AssetBalanceFormOption? value})
      : super.dirty(value);

  @override
  AssetIsUtxoInputError? validator(AssetBalanceFormOption? value) {
    if (value == null) return AssetIsUtxoInputError.required;
    if (value.entry.utxo != null) {
      return AssetIsUtxoInputError.isUtxo;
    }
    return null;
  }
}

class AssetBalanceFormModel with FormzMixin {
  final List<DisallowSelection> disallowSelections;

  final MultiAddressBalance multiAddressBalance;

  final RemoteData<Map<String, bool>> utxoSwapMap;

  final BalanceInput balanceInput;
  final SwapExistsInput swapExistsInput;
  final AssetIsUtxoInput assetIsUtxoInput;

  final FormzSubmissionStatus submissionStatus;

  AssetBalanceFormModel({
    required this.disallowSelections,
    required this.utxoSwapMap,
    required this.multiAddressBalance,
    required this.balanceInput,
    required this.swapExistsInput,
    required this.assetIsUtxoInput,
    required this.submissionStatus,
  });

  @override
  List<FormzInput> get inputs => [
        balanceInput,
        ...disallowSelections.map((a) => switch (a) {
              DisallowSelection.listingExists => swapExistsInput,
              DisallowSelection.balanceIsUtxo => assetIsUtxoInput,
            })
      ];

  AssetBalanceFormModel copyWith({
    MultiAddressBalance? multiAddressBalance,
    BalanceInput? balanceInput,
    SwapExistsInput? utxoSwapInput,
    AssetIsUtxoInput? assetIsUtxoInput,
    FormzSubmissionStatus? submissionStatus,
    RemoteData<Map<String, bool>>? utxoSwapMap,
    List<DisallowSelection>? disallowSelections,
  }) {
    return AssetBalanceFormModel(
        disallowSelections: disallowSelections ?? this.disallowSelections,
        assetIsUtxoInput: assetIsUtxoInput ?? this.assetIsUtxoInput,
        utxoSwapMap: utxoSwapMap ?? this.utxoSwapMap,
        multiAddressBalance: multiAddressBalance ?? this.multiAddressBalance,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        balanceInput: balanceInput ?? this.balanceInput,
        swapExistsInput: utxoSwapInput ?? swapExistsInput);
  }
}

enum DisallowSelection { listingExists, balanceIsUtxo }

class AssetBalanceFormBloc
    extends Bloc<AssetBalanceFormEvent, AssetBalanceFormModel> {
  final AtomicSwapRepository _atomicSwapRepository;

  final HttpConfig httpConfig;
  final List<DisallowSelection> disallowSelections;

  AssetBalanceFormBloc(
      {AtomicSwapRepository? atomicSwapRepository,
      required this.httpConfig,
      required this.disallowSelections,
      required List<String> addresses,
      required MultiAddressBalance multiAddressBalance})
      : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        super(AssetBalanceFormModel(
          utxoSwapMap: const Initial(),
          assetIsUtxoInput: const AssetIsUtxoInput.pure(),
          disallowSelections: disallowSelections,
          multiAddressBalance: multiAddressBalance,
          balanceInput: const BalanceInput.pure(),
          swapExistsInput: const SwapExistsInput.pure(),
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
    final utxoSwapMap = state.utxoSwapMap.getOrNull();
    if (utxoSwapMap == null) {
      return;
    }

    print("disallowSelections: ${state.disallowSelections}");

    emit(state.copyWith(
      balanceInput: BalanceInput.dirty(value: event.option),
      utxoSwapInput:
          SwapExistsInput.dirty(value: event.option, utxoSwapMap: utxoSwapMap),
      assetIsUtxoInput: AssetIsUtxoInput.dirty(value: event.option),
      submissionStatus: FormzSubmissionStatus.failure,
    ));
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    if (!state.isValid) return;

    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.success,
    ));
  }
}
