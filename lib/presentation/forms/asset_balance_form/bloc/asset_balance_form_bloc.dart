import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:fpdart/fpdart.dart";

abstract class AtomicSwapSellVariant {}

class AttachedAtomicSwapSell extends AtomicSwapSellVariant {
  final String address;
  final String asset;
  final String quantityNormalized;
  final int quantity;

  AttachedAtomicSwapSell({
    required this.address,
    required this.asset,
    required this.quantityNormalized,
    required this.quantity,
  });
}

class UnattachedAtomicSwapSell extends AtomicSwapSellVariant {
  final String asset;
  final String quantityNormalized;
  final int quantity;
  final String utxo;
  final String utxoAddress;

  UnattachedAtomicSwapSell({
    required this.asset,
    required this.quantityNormalized,
    required this.quantity,
    required this.utxo,
    required this.utxoAddress,
  });
}

class AssetBalanceFormOption {
  final MultiAddressBalanceEntry entry;
  const AssetBalanceFormOption({
    required this.entry,
  });
}

abstract class AssetBalanceFormEvent extends Equatable {
  const AssetBalanceFormEvent();

  @override
  List<Object?> get props => [];
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

  final BalanceInput balanceInput;

  final FormzSubmissionStatus submissionStatus;

  AssetBalanceFormModel(
      {required this.multiAddressBalance,
      required this.balanceInput,
      required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [balanceInput];

  AssetBalanceFormModel copyWith({
    MultiAddressBalance? multiAddressBalance,
    BalanceInput? balanceInput,
    FormzSubmissionStatus? submissionStatus,
  }) {
    return AssetBalanceFormModel(
      multiAddressBalance: multiAddressBalance ?? this.multiAddressBalance,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      balanceInput: balanceInput ?? this.balanceInput,
    );
  }

  Either<String, AtomicSwapSellVariant> get atomicSwapSellVariant{
    if (balanceInput.value == null) {
      return left("Balance input is null");
    }

    if (balanceInput.value!.entry.address != null) {
      return right(
        AttachedAtomicSwapSell(
          address: balanceInput.value!.entry.address!,
          asset: multiAddressBalance.asset,
          quantityNormalized: balanceInput.value!.entry.quantityNormalized,
          quantity: balanceInput.value!.entry.quantity,
        ),
      );
    }

    if (balanceInput.value!.entry.utxo != null &&
        balanceInput.value!.entry.utxoAddress != null) {
      return right(
        UnattachedAtomicSwapSell(
          asset: multiAddressBalance.asset,
          quantityNormalized: balanceInput.value!.entry.quantityNormalized,
          quantity: balanceInput.value!.entry.quantity,
          utxo: balanceInput.value!.entry.utxo!,
          utxoAddress: balanceInput.value!.entry.utxoAddress!,
        ),
      );
    }

    return left("Invalid balance input");
  }
}

class AssetBalanceFormBloc
    extends Bloc<AssetBalanceFormEvent, AssetBalanceFormModel> {
  AssetBalanceFormBloc({required MultiAddressBalance multiAddressBalance})
      : super(AssetBalanceFormModel(
          multiAddressBalance: multiAddressBalance,
          balanceInput: const BalanceInput.pure(),
          submissionStatus: FormzSubmissionStatus.initial,
        )) {
    on<AssetBalanceSelected>(_handleAssetBalanceSelected);
    on<SubmitClicked>(_handleSubmitClicked);
  }

  _handleAssetBalanceSelected(
    AssetBalanceSelected event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    emit(state.copyWith(
      balanceInput: BalanceInput.dirty(value: event.option),
    ));
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<AssetBalanceFormModel> emit,
  ) {
    if (state.balanceInput.value == null) {
      return;
    }
    // TODO: more extensive validations here

    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.success,
    ));
  }
}
