import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

class SwapPresignFormModel with FormzMixin {
  final List<AtomicSwap> atomicSwaps;

  const SwapPresignFormModel({required this.atomicSwaps});

  @override
  get inputs => [];

  get transactionCount {
    return atomicSwaps.length;
  }

  AssetQuantity get totalBtc {
    return atomicSwaps.fold(
        AssetQuantity(divisible: true, quantity: BigInt.zero),
        (previousValue, element) => previousValue + element.price);
  }

  AssetQuantity get totalRecieveAsset {
    return atomicSwaps.fold(
        AssetQuantity(divisible: true, quantity: BigInt.zero),
        (previousValue, element) => previousValue + element.assetQuantity);
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
    required List<AtomicSwap> atomicSwaps,
  }) : super(SwapPresignFormModel(atomicSwaps: atomicSwaps));
}

