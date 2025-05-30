import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/asset_search_repository.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/swap_type.dart';
import 'package:horizon/domain/entities/http_config.dart';

class AssetPairFormOption {
  final String name;
  final String? description;

  final Option<MultiAddressBalance> balance;

  const AssetPairFormOption({
    required this.name,
    required this.description,
    required this.balance,
  });

  AssetPairFormOption copyWith({
    String? name,
    String? description,
    Option<MultiAddressBalance>? balance,
  }) {
    return AssetPairFormOption(
      name: name ?? this.name,
      description: description ?? this.description,
      balance: balance ?? this.balance,
    );
  }
}

abstract class AssetPairFormEvent extends Equatable {
  const AssetPairFormEvent();

  @override
  List<Object?> get props => [];
}

class GiveAssetSelected extends AssetPairFormEvent {
  final AssetPairFormOption value;
  const GiveAssetSelected({required this.value});
}

class ReceiveAssetInputClicked extends AssetPairFormEvent {
  const ReceiveAssetInputClicked();
}

class SearchInputChanged extends AssetPairFormEvent {
  final String value;
  const SearchInputChanged(this.value);
}

class ReceiveAssetSelected extends AssetPairFormEvent {
  final AssetPairFormOption value;
  const ReceiveAssetSelected({required this.value});
}

class InvertClicked extends AssetPairFormEvent {}

class SubmitClicked extends AssetPairFormEvent {}

class GiveAssetInput extends FormzInput<AssetPairFormOption?, void> {
  const GiveAssetInput.dirty({required AssetPairFormOption? value})
      : super.dirty(value);

  const GiveAssetInput.pure() : super.pure(null);

  @override
  void validator(AssetPairFormOption? value) {
    if (value == null) {
      throw Exception("give asset input is null");
    }
  }
}

class ReceiveAssetInput extends FormzInput<AssetPairFormOption?, void> {
  const ReceiveAssetInput.dirty({required AssetPairFormOption? value})
      : super.dirty(value);

  const ReceiveAssetInput.pure() : super.pure(null);

  @override
  void validator(AssetPairFormOption? value) {
    if (value == null) {
      throw Exception("receive asset input is null");
    }
  }
}

enum ReceiveAssetInputValidationError { required }

class SearchAssetInput
    extends FormzInput<String, ReceiveAssetInputValidationError> {
  const SearchAssetInput.pure() : super.pure('');
  const SearchAssetInput.dirty(super.value) : super.dirty();

  @override
  ReceiveAssetInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return ReceiveAssetInputValidationError.required;
    }
    return null;
  }
}

class AssetPairFormModel with FormzMixin {
  static final Map<String, AssetSearchResult> _privilegedSearchResults = {
    "btc": const AssetSearchResult(
      name: "BTC",
      description: "BTC",
    ),
    "xcp": const AssetSearchResult(
      name: "XCP",
      description: "XCP",
    ),
    "pepecash": const AssetSearchResult(
      name: "PEPECASH",
      description: "",
    ),
  };

  final List<AssetPairFormOption> giveAssets;
  final GiveAssetInput giveAssetInput;
  final ReceiveAssetInput receiveAssetInput;

  final RemoteData<Map<String, AssetSearchResult>> privilegedSearchResults;
  final RemoteData<List<AssetSearchResult>> searchResults;

  final bool receiveAssetModalVisible;
  final SearchAssetInput searchAssetInput;

  final FormzSubmissionStatus submissionStatus;

  AssetPairFormModel(
      {required this.giveAssets,
      required this.giveAssetInput,
      required this.receiveAssetInput,
      required this.privilegedSearchResults,
      required this.searchResults,
      required this.receiveAssetModalVisible,
      required this.searchAssetInput,
      required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [giveAssetInput, receiveAssetInput];

  AssetPairFormModel copyWith({
    List<AssetPairFormOption>? giveAssets,
    GiveAssetInput? giveAssetInput,
    ReceiveAssetInput? receiveAssetInput,
    RemoteData<Map<String, AssetSearchResult>>? privilegedSearchResults,
    RemoteData<List<AssetSearchResult>>? searchResults,
    Option<bool> receiveAssetModalVisible = const Option.none(),
    SearchAssetInput? searchAssetInput,
    FormzSubmissionStatus? submissionStatus,
  }) {
    return AssetPairFormModel(
        submissionStatus: submissionStatus ?? this.submissionStatus,
        privilegedSearchResults:
            privilegedSearchResults ?? this.privilegedSearchResults,
        giveAssets: giveAssets ?? this.giveAssets,
        giveAssetInput: giveAssetInput ?? this.giveAssetInput,
        receiveAssetInput: receiveAssetInput ?? this.receiveAssetInput,
        searchResults: searchResults ?? this.searchResults,
        searchAssetInput: searchAssetInput ?? this.searchAssetInput,
        receiveAssetModalVisible: receiveAssetModalVisible
            .getOrElse(() => this.receiveAssetModalVisible));
  }

  RemoteData<List<AssetSearchResult>> get filteredPrivilegedSearchResults {
    return privilegedSearchResults.map((value) {
      return value.values
          .toList()
          .filter((a) => a.name
              .toLowerCase()
              .contains(searchAssetInput.value.toLowerCase()))
          .toList();
    });
  }

  RemoteData<List<AssetSearchResult>> get filteredSearchResults {
    return searchResults.combine(
      privilegedSearchResults,
      (results, privMap) {
        final lcPrivKeys = privMap.keys.map((k) => k.toLowerCase()).toSet();
        return results
            .where((r) => !lcPrivKeys.contains(r.name.toLowerCase()))
            .toList();
      },
    );
  }

  RemoteData<List<AssetSearchResult>> get displaySearchResults {
    return filteredPrivilegedSearchResults.combine(
        filteredSearchResults,
        (a, b) => [...a, ...b]
            .filter((a) => giveAssetInput.value?.name != a.name)
            .toList());
  }

  List<AssetPairFormOption> get displayGiveAssets {
    return giveAssets
        .where((a) => a.name != receiveAssetInput.value?.name)
        .toList();
  }

  bool get disabled {
    return receiveAssetInput.value == null || giveAssetInput.value == null;
  }

  Either<String, SwapType> get swapType {
    if (giveAssetInput.value == null || receiveAssetInput.value == null) {
      return Either.left("Give or receive asset input is null");
    }

    return switch ((
      giveAssetInput.value!.name.toLowerCase(),
      receiveAssetInput.value!.name.toLowerCase()
    )) {
      ("btc", _) => Either.of(AtomicSwapBuy()),
      (_, "btc") => Either.fromOption(
            giveAssetInput.value!.balance, () => "Insufficient balance").map(
          (balance) => AtomicSwapSell(giveBalance: balance),
        ),
      (_, _) => Either.of(CounterpartyOrder()),
    };
  }

  @override
  String toString() {
    return "AssetPairFormModel { "
        "giveAssets: $giveAssets, "
        // "receiveAssetInput: $receiveAssetInput, "
        "privilegedSearchResults: $privilegedSearchResults, "
        "searchResults: $searchResults, "
        "receiveAssetModalVisible: $receiveAssetModalVisible, "
        "searchAssetInput: $searchAssetInput }";
  }
}

class AssetPairFormBloc extends Bloc<AssetPairFormEvent, AssetPairFormModel> {
  final HttpConfig httpConfig;
  final AssetSearchRepository _assetSearchRepository;

  AssetPairFormBloc({
    AssetSearchRepository? assetSearchRepository,
    required this.httpConfig,
    required List<MultiAddressBalance> initialGiveAssets,
  })  : _assetSearchRepository =
            assetSearchRepository ?? GetIt.I<AssetSearchRepository>(),
        super(
          AssetPairFormModel(
              submissionStatus: FormzSubmissionStatus.initial,
              giveAssets: initialGiveAssets
                  .map((balance) => AssetPairFormOption(
                        name: balance.asset,
                        description: balance.assetInfo.description,
                        balance: Option.of(balance),
                      ))
                  .toList(),
              giveAssetInput: GiveAssetInput.pure(),
              receiveAssetInput: ReceiveAssetInput.pure(),
              searchAssetInput: const SearchAssetInput.pure(),
              receiveAssetModalVisible: false,
              privilegedSearchResults: Success(
                AssetPairFormModel._privilegedSearchResults,
              ),
              searchResults: const Success([])),
        ) {
    on<GiveAssetSelected>(_handleGiveAssetChanged);
    on<ReceiveAssetInputClicked>(_handleReceiveAssetInputClicked);
    on<SearchInputChanged>(_handleSearchInputChanged);
    on<ReceiveAssetSelected>(_handleReceiveAssetSelected);
    on<InvertClicked>(_handleInvertClicked);
    on<SubmitClicked>(_handleSubmitClicked);
  }

  _handleGiveAssetChanged(
      GiveAssetSelected event, Emitter<AssetPairFormModel> emit) {
    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.initial,
      giveAssetInput: GiveAssetInput.dirty(value: event.value),
    ));
  }

  _handleReceiveAssetInputClicked(
      ReceiveAssetInputClicked event, Emitter<AssetPairFormModel> emit) {
    emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.initial,
        receiveAssetModalVisible: Option.of(!state.receiveAssetModalVisible)));
  }

  _handleSearchInputChanged(
      SearchInputChanged event, Emitter<AssetPairFormModel> emit) async {
    if (event.value.isEmpty) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.initial,
          searchAssetInput: SearchAssetInput.pure(),
          searchResults: const Success([])));
      return;
    }

    RemoteData<List<AssetSearchResult>> receiveAssetsNext = switch (
        state.searchResults) {
      Success(value: var value) => Refreshing(value),
      _ => const Loading()
    };

    emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.initial,
        searchResults: receiveAssetsNext,
        searchAssetInput: SearchAssetInput.dirty(event.value)));

    final task = _assetSearchRepository.searchT(
        httpConfig: httpConfig,
        term: event.value,
        onError: (err, __) => "Error: $err");

    final result = await task.run();

    result.fold(
      (err) {
        emit(state.copyWith(
          searchResults: Failure(err),
        ));
      },
      (value) => emit(state.copyWith(
        searchResults: Success([...value]),
      )),
    );
  }

  _handleReceiveAssetSelected(
    ReceiveAssetSelected event,
    Emitter<AssetPairFormModel> emit,
  ) {
    final next = state.copyWith(
        submissionStatus: FormzSubmissionStatus.initial,
        receiveAssetInput: ReceiveAssetInput.dirty(value: event.value),
        receiveAssetModalVisible: Option.of(false));

    emit(next);
  }

  _handleInvertClicked(
    InvertClicked event,
    Emitter<AssetPairFormModel> emit,
  ) {
    if (state.receiveAssetInput.value == null ||
        state.giveAssetInput.value == null) {
      return;
    }

    final nextReceiveAsset =
        state.giveAssetInput.value!.copyWith(balance: Option.none());

    final nextGiveAsset = state.giveAssets.firstWhere(
      (a) => a.name == state.receiveAssetInput.value!.name,
      orElse: () => state.receiveAssetInput.value!,
    );

    return emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.initial,
      giveAssetInput: GiveAssetInput.dirty(value: nextGiveAsset),
      receiveAssetInput: ReceiveAssetInput.dirty(value: nextReceiveAsset),
    ));
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<AssetPairFormModel> emit,
  ) {
    // TODO: more robust validation
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    final swapType = state.swapType;

    swapType.fold(
        (error) => emit(
              state.copyWith(
                submissionStatus: FormzSubmissionStatus.failure,
              ),
            ),
        (swapType) => emit(
              state.copyWith(
                submissionStatus: FormzSubmissionStatus.success,
              ),
            ));
  }
}
