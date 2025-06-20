import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';

class AtomicSwapListModel {
  final List<AtomicSwapListItemModel> items;

  AtomicSwapListModel({required this.items});
}

class AtomicSwapListItemModel {
  final Asset asset;
  final AssetQuantity quantity;
  final BigInt price;
  final BigInt pricePerUnit;

  AtomicSwapListItemModel({
    required this.asset,
    required this.quantity,
    required this.price,
    required this.pricePerUnit,
  });
}

class SwapSliderFormModel with FormzMixin {
  final String assetName;
  final RemoteData<List<AtomicSwap>> atomicSwaps;
  final RemoteData<Asset> asset;

  SwapSliderFormModel({
    required this.assetName,
    required this.atomicSwaps,
    required this.asset,
  });

  @override
  List<FormzInput> get inputs => [];

  SwapSliderFormModel copyWith({
    String? assetName,
    RemoteData<List<AtomicSwap>>? atomicSwaps,
    RemoteData<Asset>? asset,
  }) {
    return SwapSliderFormModel(
      assetName: assetName ?? this.assetName,
      atomicSwaps: atomicSwaps ?? this.atomicSwaps,
      asset: asset ?? this.asset,
    );
  }

  RemoteData<AtomicSwapListModel> get atomicSwapListModel {
    return asset.combine(atomicSwaps, (asset, atomicSwaps) {
      final swaps = atomicSwaps
          .map((swap) => AtomicSwapListItemModel(
              asset: asset,
              quantity: AssetQuantity(
                divisible: asset.divisible ?? false,
                quantity: swap.assetQuantity,
              ),
              price: swap.price,
              pricePerUnit: swap.pricePerUnit))
          .toList();

      return AtomicSwapListModel(items: swaps);
    });
  }
}

sealed class SwapSliderFormEvent extends Equatable {
  const SwapSliderFormEvent();

  @override
  List<Object?> get props => [];
}

class SwapSliderFormInitialized extends SwapSliderFormEvent {}

class SwapSliderFormBloc
    extends Bloc<SwapSliderFormEvent, SwapSliderFormModel> {
  final HttpConfig httpConfig;
  final AtomicSwapRepository _atomicSwapRepository;
  final AssetRepository _assetRepository;

  SwapSliderFormBloc({
    required String assetName,
    required this.httpConfig,
    AtomicSwapRepository? atomicSwapRepository,
    AssetRepository? assetRepository,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _assetRepository = assetRepository ?? GetIt.I<AssetRepository>(),
        super(
          SwapSliderFormModel(
            assetName: assetName,
            atomicSwaps: const Initial<List<AtomicSwap>>(),
            asset: const Initial<Asset>(),
          ),
        ) {
    on<SwapSliderFormInitialized>(_handleInitialized);

    add(SwapSliderFormInitialized());
  }

  _handleInitialized(
    SwapSliderFormInitialized event,
    Emitter<SwapSliderFormModel> emit,
  ) async {
    emit(state.copyWith(atomicSwaps: const Loading()));

    final task = TaskEither.sequenceList([
      _assetRepository.getAssetVerboseT(
        httpConfig: httpConfig,
        assetName: state.assetName,
      ),
      _atomicSwapRepository.getSwapsByAssetT(
        httpConfig: httpConfig,
        asset: state.assetName,
      )
    ]);

    final result = await task.run();

    result.fold(
      (err) => emit(
        state.copyWith(atomicSwaps: Failure(err), asset: Failure(err)),
      ),
      (result) => emit(
          // Chat is there any way to avoid this typecast?
          state.copyWith(
              asset: Success(result[0] as Asset),
              atomicSwaps: Success([
                ...result[1] as List<AtomicSwap>,
                ...result[1] as List<AtomicSwap>,
                ...result[1] as List<AtomicSwap>,
              ]))),
    );
  }
}
