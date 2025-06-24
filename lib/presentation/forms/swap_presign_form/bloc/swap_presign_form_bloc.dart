import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

class SwapPresignFormModel with FormzMixin {
  final String assetName;
  final List<AtomicSwap> atomicSwaps;

  final FormzSubmissionStatus submissionStatus;

  const SwapPresignFormModel({
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
    return atomicSwaps.fold(
        AssetQuantity(divisible: true, quantity: BigInt.zero),
        (previousValue, element) => previousValue + element.price);
  }

  AssetQuantity get totalRecieveAsset {
    return atomicSwaps.fold(
        AssetQuantity(divisible: true, quantity: BigInt.zero),
        (previousValue, element) => previousValue + element.assetQuantity);
  }

  SwapPresignFormModel copyWith({
    FormzSubmissionStatus? submissionStatus,
  }) {
    return SwapPresignFormModel(
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
    required List<AtomicSwap> atomicSwaps,
    required String assetName,
  }) : super(SwapPresignFormModel(
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

