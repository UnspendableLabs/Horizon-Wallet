import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/asset_search_repository.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class AssetPairFormEvent extends Equatable {
  const AssetPairFormEvent();

  @override
  List<Object?> get props => [];
}

class GiveAssetChanged extends AssetPairFormEvent {
  final MultiAddressBalance value;
  const GiveAssetChanged({required this.value});
}

class ReceiveAssetInputClicked extends AssetPairFormEvent {
  const ReceiveAssetInputClicked();
}

class ReceiveAssetInputChanged extends AssetPairFormEvent {
  final String value;
  const ReceiveAssetInputChanged(this.value);
}

class GiveAssetInput extends FormzInput<MultiAddressBalance?, void> {
  const GiveAssetInput.dirty({required MultiAddressBalance? value})
      : super.dirty(value);

  @override
  void validator(MultiAddressBalance? value) {
    if (value == null) {
      throw Exception("give asset input is null");
    }
  }
}

enum ReceiveAssetInputValidationError { required }

class ReceiveAssetInput
    extends FormzInput<String, ReceiveAssetInputValidationError> {
  const ReceiveAssetInput.pure() : super.pure('');
  const ReceiveAssetInput.dirty(super.value) : super.dirty();

  @override
  ReceiveAssetInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return ReceiveAssetInputValidationError.required;
    }
    return null;
  }
}

class AssetPairFormModel with FormzMixin {
  static Map<String, AssetSearchResult> _privilegedSearchResults = {
    "btc": const AssetSearchResult(
      name: "BTC",
      description: "BTC",
    ),
    "xcp": const AssetSearchResult(
      name: "XCP",
      description: "XCP",
    ),
  };

  final List<MultiAddressBalance> giveAssets;
  final GiveAssetInput giveAssetInput;

  final RemoteData<List<AssetSearchResult>> privilegedSearchResults;
  final RemoteData<List<AssetSearchResult>> searchResults;

  final bool receiveAssetModalVisible;

  final ReceiveAssetInput receiveAssetInput;

  AssetPairFormModel(
      {required this.giveAssets,
      required this.giveAssetInput,
      required this.privilegedSearchResults,
      required this.searchResults,
      required this.receiveAssetModalVisible,
      required this.receiveAssetInput});

  @override
  List<FormzInput> get inputs => [giveAssetInput];

  AssetPairFormModel copyWith(
      {List<MultiAddressBalance>? giveAssets,
      GiveAssetInput? giveAssetInput,
      RemoteData<List<AssetSearchResult>>? privilegedSearchResults,
      RemoteData<List<AssetSearchResult>>? searchResults,
      Option<bool> receiveAssetModalVisible = const Option.none(),
      ReceiveAssetInput? receiveAssetInput}) {
    return AssetPairFormModel(
        privilegedSearchResults:
            privilegedSearchResults ?? this.privilegedSearchResults,
        giveAssets: giveAssets ?? this.giveAssets,
        giveAssetInput: giveAssetInput ?? this.giveAssetInput,
        searchResults: searchResults ?? this.searchResults,
        receiveAssetInput: receiveAssetInput ?? this.receiveAssetInput,
        receiveAssetModalVisible: receiveAssetModalVisible
            .getOrElse(() => this.receiveAssetModalVisible));
  }
}

class AssetPairFormBloc extends Bloc<AssetPairFormEvent, AssetPairFormModel> {
  final HttpConfig httpConfig;
  final AssetSearchRepository _assetSearchRepository;

  AssetPairFormBloc(
      {AssetSearchRepository? assetSearchRepository,
      required this.httpConfig,
      required List<MultiAddressBalance> initialGiveAssets,
      required MultiAddressBalance? initialMultiAddressBalanceEntry})
      : _assetSearchRepository =
            assetSearchRepository ?? GetIt.I<AssetSearchRepository>(),
        super(
          AssetPairFormModel(
              giveAssets: initialGiveAssets,
              giveAssetInput: GiveAssetInput.dirty(
                value: initialMultiAddressBalanceEntry,
              ),
              receiveAssetInput: ReceiveAssetInput.pure(),
              receiveAssetModalVisible: false,
              privilegedSearchResults: Success(
                AssetPairFormModel._privilegedSearchResults.values.toList(),
              ),
              searchResults: const Initial()),
        ) {
    on<GiveAssetChanged>(_handleGiveAssetChanged);
    on<ReceiveAssetInputClicked>(_handleReceiveAssetInputClicked);
    on<ReceiveAssetInputChanged>(_handleReceiveAssetInputChanged);
  }

  _handleGiveAssetChanged(
      GiveAssetChanged event, Emitter<AssetPairFormModel> emit) {
    emit(state.copyWith(
      giveAssetInput: GiveAssetInput.dirty(value: event.value),
    ));
  }

  _handleReceiveAssetInputClicked(
      ReceiveAssetInputClicked event, Emitter<AssetPairFormModel> emit) {
    emit(state.copyWith(
        receiveAssetModalVisible: Option.of(!state.receiveAssetModalVisible)));
  }

  _handleReceiveAssetInputChanged(
      ReceiveAssetInputChanged event, Emitter<AssetPairFormModel> emit) async {
    if (event.value.isEmpty) {
      emit(state.copyWith(searchResults: const Initial()));
      return;
    }

    RemoteData<List<AssetSearchResult>> receiveAssetsNext = switch (
        state.searchResults) {
      Success(value: var value) => Refreshing(value),
      _ => const Loading()
    };

    emit(state.copyWith(
        searchResults: receiveAssetsNext,
        receiveAssetInput: ReceiveAssetInput.dirty(event.value)));

    final task = _assetSearchRepository.searchT(
        httpConfig: httpConfig,
        term: event.value,
        onError: (err, __) => "Error: $err");

    final result = await task.run();

    result.fold(
      (err) {
        print(err);
        emit(state.copyWith(
          searchResults: Failure(err),
        ));
      },
      (value) => emit(state.copyWith(
        searchResults: Success(value),
      )),
    );
  }
}
