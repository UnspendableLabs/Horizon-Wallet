import "package:decimal/decimal.dart";
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

class MpmaSendSummaryViewModel extends PsbtSummaryViewModel {
  final AssetQuantity networkFee;
  final List<XCPSendSummaryViewModel> sends;
  MpmaSendSummaryViewModel({
    required this.networkFee,
    required this.sends,
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

class KeyValueSummaryViewModel extends PsbtSummaryViewModel {
  final List<MapEntry<String, String>> entries;

  final AssetQuantity networkFee;
  KeyValueSummaryViewModel({
    required this.networkFee,
    required this.entries,
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
      Dividend(
        asset: var asset,
        dividendAsset: var dividendAsset,
        quantityPerUnit: var quantityPerUnit,
      ) =>
        KeyValueSummaryViewModel(
          networkFee: networkFee,
          entries: [
            MapEntry("type", "dividend"),
            MapEntry("asset", asset),
            MapEntry("dividend asset", dividendAsset),
            MapEntry("quantity per unit", quantityPerUnit.normalizedPretty()),
          ],
        ),
      Mpma(sends: var sends) => MpmaSendSummaryViewModel(
          networkFee: networkFee,
          sends: sends
              .map((e) => XCPSendSummaryViewModel(
                    assetName: e.asset,
                    toAddress: e.toAddress,
                    quantity: e.quantity,
                    networkFee: networkFee,
                  ))
              .toList(),
        ),
      Fairminter(
        asset: var asset,
        quantity: var quantity,
        maxMintPerTx: var maxMintPerTx,
        quantityByPrice: var quantityByPrice,
        premintQuantity: var premintQuantity,
        mintedAssetCommission: var mintedAssetCommission,
        encoding: var encoding,
        inscription: var inscription,
        description: var description,
        mimeType: var mimeType,
        audio: var audio,
        media: var media,
        startBlock: var startBlock,
        endBlock: var endBlock,
        softCap: var softCap,
        softCapDeadlineBlock: var softCapDeadlineBlock,
      ) =>
        KeyValueSummaryViewModel(
          networkFee: networkFee,
          entries: ([
            MapEntry("type", "fairminter"),
            if (asset != null) MapEntry("asset", asset.toString()),
            if (quantity != null)
              MapEntry("quantity", quantity.normalizedPretty()),
            if (maxMintPerTx != null)
              MapEntry("max mint per tx", maxMintPerTx.normalizedPretty()),
            if (quantityByPrice != null)
              MapEntry("quantity by price", quantityByPrice.toString()),
            if (premintQuantity != null)
              MapEntry("premint quantity", premintQuantity.normalizedPretty()),
            if (mintedAssetCommission != null)
              MapEntry(
                  "minted asset commission", mintedAssetCommission.toString()),
            if (encoding != null) MapEntry("encoding", encoding),
            if (inscription != null) MapEntry("inscription", inscription),
            if (description != null) MapEntry("description", description),
            if (mimeType != null) MapEntry("mime type", mimeType),
            if (audio != null) MapEntry("audio", audio.toString()),
            if (media != null) MapEntry("media", media.toString()),
            if (startBlock != null)
              MapEntry("start block", startBlock.toString()),
            if (endBlock != null) MapEntry("end block", endBlock.toString()),
            if (softCap != null) MapEntry("soft cap", softCap.toString()),
            if (softCapDeadlineBlock != null)
              MapEntry(
                  "soft cap deadline block", softCapDeadlineBlock.toString()),
          ]),
        ),
      Issuance(
        asset: var asset,
        quantity: var quantity,
      ) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "issuance"),
          MapEntry("asset", asset ?? "-"),
          MapEntry("quantity", quantity?.normalizedPretty() ?? "-"),
        ]),
      IssueMore(
        asset: var asset,
        quantity: var quantity,
      ) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "issue more"),
          MapEntry("asset", asset),
          MapEntry("quantity", quantity.normalizedPretty()),
        ]),
      Reset(
        asset: var asset,
      ) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "reset"),
          MapEntry("asset", asset),
        ]),
      ChangeOwnership(
        asset: var asset,
        transferDestination: var transferDestination,
      ) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "change ownership"),
          MapEntry("asset", asset),
          MapEntry("transer destination", transferDestination),
        ]),
      ChangeDescription(asset: var asset, description: var description) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "change description"),
          MapEntry("asset", asset),
          MapEntry("description", description),
        ]),
      LockDescription(
        asset: var asset,
        // description: var description descriptin is always "LOCK"
      ) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "lock description"),
          MapEntry("asset", asset),
          // MapEntry("description", description),
        ]),
      LockQuantity(
        asset: var asset,
        // quantity: var quantity, Quantity is always 0?
      ) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "lock quantity"),
          MapEntry("asset", asset),
          // MapEntry("quantity", quantity.normalizedPretty()),
        ]),
      Destroy(asset: var asset, quantity: var quantity, tag: var tag) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "destroy"),
          MapEntry("asset", asset),
          MapEntry("quantity", quantity.normalizedPretty()),
          MapEntry("tag", tag),
        ]),
      UtxoMove(destination: var destination) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "move"),
          MapEntry("destination", destination),
        ]),
      Sweep(destination: var destination) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "sweep"),
          MapEntry("destination", destination),
        ]),
      AttachPsbt(asset: var asset, quantity: var quantity) =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "attach"),
          MapEntry("asset", asset),
          MapEntry("quantity", quantity.normalizedPretty()),
        ]),
      DetachPsbt() =>
        KeyValueSummaryViewModel(networkFee: networkFee, entries: [
          MapEntry("type", "detach"),
        ]),
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
      CancelOrder(
        asset: var asset,
        quantity: var quantity,
        xcpPrice: var price,
      ) =>
        KeyValueSummaryViewModel(
          networkFee: networkFee,
          entries: [
            MapEntry("type", "cancel order"),
            MapEntry("asset", asset),
            MapEntry("quantity", quantity.normalizedPretty()),
            MapEntry("price", "${price.normalized()} XCP  / $asset"),
          ],
        ),
      OrderPsbt(
        giveAsset: var giveAsset,
        getAsset: var getAsset,
        giveQuantity: var giveQuantity,
        getQuantity: var getQuantity,
      ) =>
        KeyValueSummaryViewModel(
          networkFee: networkFee,
          entries: [
            MapEntry("type", "order"),
            MapEntry("give_asset", giveAsset),
            MapEntry("get_asset", getAsset),
            MapEntry("give_quantity", giveQuantity.normalizedPretty()),
            MapEntry("get_quantity", getQuantity.normalizedPretty()),
          ],
        ),
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
