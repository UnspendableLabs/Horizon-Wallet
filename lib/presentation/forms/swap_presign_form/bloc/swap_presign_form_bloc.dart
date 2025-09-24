import 'package:decimal/decimal.dart';
import 'package:fpdart/fpdart.dart' show Option;
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';

class SwapPresignFormModel with FormzMixin {
  final Option<RoyaltyByAsset> royaltyByAsset;
  final String assetName;
  final List<AtomicSwap> atomicSwaps;

  final FormzSubmissionStatus submissionStatus;

  const SwapPresignFormModel({
    required this.royaltyByAsset,
    required this.atomicSwaps,
    required this.assetName,
    required this.submissionStatus,
  });

  @override
  get inputs => [];

  get transactionCount {
    return atomicSwaps.length;
  }

  AssetQuantity get totalBtc {
    return totalSwapBtc + totalRoyaltyBtc;
  }

  AssetQuantity get totalSwapBtc {
    return atomicSwaps.fold(
        AssetQuantity(divisible: true, quantity: BigInt.zero),
        (previousValue, element) => previousValue + element.price);
  }

  AssetQuantity get totalRoyaltyBtc {
    final qty = royaltyByAsset.fold<BigInt>(
      () => BigInt.zero,
      (royalty) {
        final net = totalSwapBtc.quantity; // BigInt, e.g. 17654
        final bps = royalty.royalty; // basis points, e.g. 300 = 3%

        final expectedRoyalty =
            (net * BigInt.from(bps)) ~/ BigInt.from(10000 - bps);

        return expectedRoyalty;
      },
    );

    return AssetQuantity(divisible: true, quantity: qty);
  }

  AssetQuantity get totalRecieveAsset {
    return atomicSwaps.fold(
        AssetQuantity(divisible: true, quantity: BigInt.zero),
        (previousValue, element) => previousValue + element.assetQuantity);
  }

  SwapPresignFormModel copyWith({
    FormzSubmissionStatus? submissionStatus,
    Option<RoyaltyByAsset>? royaltyByAsset,
  }) {
    return SwapPresignFormModel(
      royaltyByAsset: royaltyByAsset ?? this.royaltyByAsset,
      atomicSwaps: atomicSwaps,
      assetName: assetName,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}

sealed class SwapPresignFormEvent extends Equatable {
  const SwapPresignFormEvent();

  @override
  List<Object?> get props => [];
}

class SubmitClicked extends SwapPresignFormEvent {}

class SwapPresignFormBloc
    extends Bloc<SwapPresignFormEvent, SwapPresignFormModel> {
  SwapPresignFormBloc({
    required Option<RoyaltyByAsset> royaltyByAsset,
    required List<AtomicSwap> atomicSwaps,
    required String assetName,
  }) : super(SwapPresignFormModel(
            royaltyByAsset: royaltyByAsset,
            atomicSwaps: atomicSwaps,
            assetName: assetName,
            submissionStatus: FormzSubmissionStatus.initial)) {
    on<SubmitClicked>(_handleSubmitClicked);
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapPresignFormModel> emit,
  ) {
    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.success,
    ));
  }
}
