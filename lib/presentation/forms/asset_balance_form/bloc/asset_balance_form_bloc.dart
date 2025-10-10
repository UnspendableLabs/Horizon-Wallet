import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetBalanceFormOption {
  final BalanceV2 entry;
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

    UtxoID? utxo = switch (value.entry) {
      UtxoBalance(utxoId: var utxoId) => utxoId,
      _ => null
    };

    if (utxoSwapMap != null &&
        utxo != null &&
        utxoSwapMap![utxo.toString()] == true) {
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
    if (value.entry is UtxoBalance) {
      return AssetIsUtxoInputError.isUtxo;
    }
    return null;
  }
}

class AssetBalanceFormModel with FormzMixin {
  final List<DisallowSelection> disallowSelections;

  final AssetBalanceSummary assetBalanceSummary;

  final RemoteData<Map<String, bool>> utxoSwapMap;

  final BalanceInput balanceInput;
  final SwapExistsInput swapExistsInput;
  final AssetIsUtxoInput assetIsUtxoInput;

  final FormzSubmissionStatus submissionStatus;

  AssetBalanceFormModel({
    required this.disallowSelections,
    required this.utxoSwapMap,
    required this.assetBalanceSummary,
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
    AssetBalanceSummary? assetBalanceSummary,
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
        assetBalanceSummary: assetBalanceSummary ?? this.assetBalanceSummary,
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
      required AssetBalanceSummary assetBalanceSummary})
      : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        super(AssetBalanceFormModel(
          utxoSwapMap: const Initial(),
          assetIsUtxoInput: const AssetIsUtxoInput.pure(),
          disallowSelections: disallowSelections,
          assetBalanceSummary: assetBalanceSummary,
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

  Future<void> _handleAssetBalanceFormRequested(
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

  void _handleAssetBalanceSelected(
    AssetBalanceSelected event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    final utxoSwapMap = state.utxoSwapMap.getOrNull();
    if (utxoSwapMap == null) {
      return;
    }

    emit(state.copyWith(
      balanceInput: BalanceInput.dirty(value: event.option),
      utxoSwapInput:
          SwapExistsInput.dirty(value: event.option, utxoSwapMap: utxoSwapMap),
      assetIsUtxoInput: AssetIsUtxoInput.dirty(value: event.option),
      submissionStatus: FormzSubmissionStatus.failure,
    ));
  }

  void _handleSubmitClicked(
    SubmitClicked event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    if (!state.isValid) return;

    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.success,
    ));
  }
}
