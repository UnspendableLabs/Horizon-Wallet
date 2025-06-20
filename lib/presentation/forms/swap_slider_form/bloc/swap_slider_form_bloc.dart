import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';

class SwapSliderFormModel with FormzMixin {
  final RemoteData<List<AtomicSwap>> atomicSwaps;

  SwapSliderFormModel({required this.atomicSwaps});

  @override
  List<FormzInput> get inputs => [];

  SwapSliderFormModel copyWith({
    RemoteData<List<AtomicSwap>>? atomicSwaps,
  }) {
    return SwapSliderFormModel(
      atomicSwaps: atomicSwaps ?? this.atomicSwaps,
    );
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
  final String assetName;
  final AtomicSwapRepository _atomicSwapRepository;

  SwapSliderFormBloc({
    required this.assetName,
    required this.httpConfig,
    AtomicSwapRepository? atomicSwapRepository,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        super(
          SwapSliderFormModel(
            atomicSwaps: const Initial<List<AtomicSwap>>(),
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

    final result = await _atomicSwapRepository
        .getSwapsByAssetT(
          httpConfig: httpConfig,
          asset: assetName,
        )
        .run();

    result.fold(
      (err) => emit(
        state.copyWith(atomicSwaps: Failure(err)),
      ),
      (swaps) => emit(
        state.copyWith(atomicSwaps: Success(swaps)),
      ),
    );
  }
}
