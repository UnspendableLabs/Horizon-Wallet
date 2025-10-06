import "package:decimal/decimal.dart";
import "package:flutter/material.dart";
import "package:formz/formz.dart";
import "package:horizon/domain/entities/asset_quantity.dart";
import 'package:horizon/domain/entities/psbt_type.dart';
import "./sign_psbt_bloc.dart";

enum PasswordValidationError { empty }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.isNotEmpty ? null : PasswordValidationError.empty;
  }
}

sealed class PsbtSummaryViewModel {}

class AtomicSwapListingFeeSummaryViewModel extends PsbtSummaryViewModel {
  final AssetQuantity serviceFee;
  final AssetQuantity networkFee;

  AtomicSwapListingFeeSummaryViewModel({
    required this.serviceFee,
    required this.networkFee,
  });
}

class AtomicSwapSellSummaryViewModel extends PsbtSummaryViewModel {
  AtomicSwapSellSummaryViewModel();
}

class AtomicSwapBuySummaryViewModel extends PsbtSummaryViewModel {
  final AssetQuantity networkFee;
  final AssetQuantity? royaltyFee;
  AtomicSwapBuySummaryViewModel({
    required this.networkFee,
    required this.royaltyFee,
  });
}

class BtcSendSummaryViewModel extends PsbtSummaryViewModel {
  final String toAddress;
  final AssetQuantity networkFee;
  final AssetQuantity btc;
  BtcSendSummaryViewModel({
    required this.toAddress,
    required this.networkFee,
    required this.btc,
  });
}

class XCPSendSummaryViewModel extends PsbtSummaryViewModel {
  final String assetName;
  final String toAddress;
  final AssetQuantity quantity;
  final AssetQuantity networkFee;
  XCPSendSummaryViewModel({
    required this.assetName,
    required this.toAddress,
    required this.quantity,
    required this.networkFee,
  });
}

class OrderSummaryViewModel extends PsbtSummaryViewModel {
  final AssetQuantity networkFee;
  final String giveAsset;
  final String getAsset;

  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;
  OrderSummaryViewModel({
    required this.networkFee,
    required this.giveAsset,
    required this.getAsset,
    required this.giveQuantity,
    required this.getQuantity,
  });
}

class OpaquePsbtSummaryViewModel extends PsbtSummaryViewModel {
  final AssetQuantity networkFee;
  OpaquePsbtSummaryViewModel({
    required this.networkFee,
  });
}

class SignPsbtState with FormzMixin {
  final PsbtType psbtType;
  final List<String> addresses;
  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signedPsbt;
  final String? error;

  final List<AssetDebit>? debits;
  final List<AssetCredit>? credits;
  final List<AugmentedInput>? augmentedInputs;
  final List<AugmentedOutput>? augmentedOutputs;
  final bool isFormDataLoaded;

  SignPsbtState({
    required this.psbtType,
    required this.addresses,
    this.debits,
    this.credits,
    this.augmentedInputs,
    this.augmentedOutputs,
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signedPsbt,
    this.error,
    this.isFormDataLoaded = false,
  });

  @override
  List<FormzInput> get inputs => [password];

  PsbtSummaryViewModel get psbtSummaryViewModel {
    return switch (psbtType) {
      AtomicSwapListingFee() => AtomicSwapListingFeeSummaryViewModel(
          // service fee is the value of the first output
          serviceFee: augmentedOutputs?.first.vout.value != null
              ? AssetQuantity.fromNormalizedString(
                  divisible: true,
                  input: augmentedOutputs!.first.vout.value.toString())
              : AssetQuantity.empty(divisible: true),
          networkFee: networkFee,
        ),
      AtomicSwapSellPsbt() => AtomicSwapSellSummaryViewModel(),
      AtomicSwapBuyPsbt(royalty: var royaltyFee) =>
        AtomicSwapBuySummaryViewModel(
            networkFee: networkFee, royaltyFee: royaltyFee),
      BtcSendPsbt(toAddress: var toAddress, sats: var sats) =>
        BtcSendSummaryViewModel(
            networkFee: networkFee,
            toAddress: toAddress,
            btc: AssetQuantity(divisible: true, quantity: sats)),
      XCPSendPsbt(
        asset: var asset,
        toAddress: var toAddress,
        quantity: var quantity
      ) =>
        XCPSendSummaryViewModel(
            networkFee: networkFee,
            toAddress: toAddress,
            quantity: quantity,
            assetName: asset),
      OrderPsbt(
        giveAsset: var giveAsset,
        getAsset: var getAsset,
        giveQuantity: var giveQuantity,
        getQuantity: var getQuantity,
      ) =>
        OrderSummaryViewModel(
            networkFee: networkFee,
            giveAsset: giveAsset,
            getAsset: getAsset,
            giveQuantity: giveQuantity,
            getQuantity: getQuantity),
      OpaquePsbt() => OpaquePsbtSummaryViewModel(
          networkFee: networkFee,
        ),
    };
  }

  AssetQuantity get totalInputs {
    final sumInputs =
        augmentedInputs?.fold(BigInt.zero, (previousValue, element) {
              return previousValue +
                  BigInt.parse(element.prevOut.value.toString());
            }) ??
            BigInt.zero;

    return AssetQuantity(divisible: true, quantity: sumInputs);
  }

  AssetQuantity get totalOutputs {
    final sumOutputs =
        augmentedOutputs?.fold(Decimal.zero, (previousValue, element) {
              return previousValue +
                  Decimal.parse(element.vout.value.toString());
            }) ??
            Decimal.zero;

    return AssetQuantity.fromNormalizedString(
        divisible: true, input: (sumOutputs).toString());
  }

  AssetQuantity get networkFee {
    return totalInputs - totalOutputs;
  }

  AssetQuantity get change {
    final changeOutputs = augmentedOutputs
        ?.where((element) => element.isUserOwned(addresses.toSet()))
        .fold(Decimal.zero, (previousValue, element) {
      return previousValue + Decimal.parse(element.vout.value.toString());
    });

    return AssetQuantity.fromNormalizedString(
        divisible: true, input: (changeOutputs ?? Decimal.zero).toString());
  }

  AssetQuantity get net {
    return totalOutputs - change + networkFee;
  }

  SignPsbtState copyWith({
    List<String>? addresses,
    PsbtType? psbtType,
    List<AssetDebit>? debits,
    List<AssetCredit>? credits,
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signedPsbt,
    String? error,
    bool? isFormDataLoaded,
    List<AugmentedInput>? augmentedInputs,
    List<AugmentedOutput>? augmentedOutputs,
    BigInt? networkFee,
    BigInt? change,
  }) {
    return SignPsbtState(
      addresses: addresses ?? this.addresses,
      psbtType: psbtType ?? this.psbtType,
      debits: debits ?? this.debits,
      credits: credits ?? this.credits,
      augmentedOutputs: augmentedOutputs ?? this.augmentedOutputs,
      augmentedInputs: augmentedInputs ?? this.augmentedInputs,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      signedPsbt: signedPsbt ?? this.signedPsbt,
      error: error ?? this.error,
      isFormDataLoaded: isFormDataLoaded ?? this.isFormDataLoaded,
    );
  }
}
