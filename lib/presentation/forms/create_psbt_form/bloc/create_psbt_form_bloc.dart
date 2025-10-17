import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/common/constants.dart';

import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/presentation/forms/swap_order_form/bloc/swap_order_form_bloc.dart';
import 'package:rational/rational.dart';

BigInt _calculateMinPrice(RoyaltyByAsset royalty, BigInt dust, int voutValue) {
  final baseMinimum = [
    dust,
    BigInt.from(voutValue),
  ].reduce((max, curr) => curr > max ? curr : max);

  final royaltyPercent =
      Decimal.fromInt(royalty.royalty) / Decimal.fromInt(10000);

  final minPriceForRoyalty = (dust.toDecimal() *
          Decimal.fromInt(10000) /
          Decimal.fromInt(royalty.royalty))
      .ceil();

  final minPriceForTotalReceive = (Decimal.fromBigInt(baseMinimum) /
          (Decimal.one - royaltyPercent.toDecimal()))
      .ceil();

  return [
    minPriceForRoyalty,
    minPriceForTotalReceive,
  ].reduce((max, curr) => curr > max ? curr : max);
}

BigInt _calculateMinRoyalty(RoyaltyByAsset royalty, BigInt dust) {
  return (dust.toDecimal() *
          Decimal.fromInt(10000) /
          Decimal.fromInt(royalty.royalty))
      .ceil();
}

enum BtcPriceInputError {
  required,
  isNaN,
  isNegative,
  isLessThanDust,
  isTooSmallBecauseOfRoyalty
}

enum BtcPriceUnit {
  sats,
  btc,
}

class BtcPriceInput extends FormzInput<String, BtcPriceInputError> {
  final BigInt minPrice;
  final BtcPriceUnit unit;

  const BtcPriceInput.pure({required this.minPrice, required this.unit})
      : super.pure('');
  const BtcPriceInput.dirty({
    required String value,
    required this.minPrice,
    required this.unit,
  }) : super.dirty(value);
  @override
  BtcPriceInputError? validator(String value) {
    if (value.isEmpty) {
      return BtcPriceInputError.required;
    }

    BtcPriceInputError? royaltyError = asSats.fold(() => null, (sats) {
      if (minPrice > dust && sats < minPrice) {
        return BtcPriceInputError.isTooSmallBecauseOfRoyalty;
      }
      return null;
    });

    if (royaltyError != null) {
      return royaltyError;
    }

    BtcPriceInputError? dustError = asSats.fold(
      () => null,
      (sats) => sats < dust ? BtcPriceInputError.isLessThanDust : null,
    );

    if (dustError != null) {
      return dustError;
    }

    return asDecimal.fold(
      () => BtcPriceInputError.isNaN,
      (decimal) =>
          decimal <= Decimal.zero ? BtcPriceInputError.isNegative : null,
    );
  }

  Option<Decimal> get asDecimal {
    return Option.tryCatch(() => Decimal.parse(value));
  }

  Option<BigInt> get asSats {
    // chat, wihtha  value decimal value of 0.02, this returns 0
    if (unit == BtcPriceUnit.sats) {
      return asDecimal.map((d) => d.toBigInt());
    }
    return asDecimal.map((d) => d * Decimal.fromInt(100000000)).map(
          (d) => d.toBigInt(),
        );
  }
}

class CreatePsbtFormModel with FormzMixin {
  final RemoteData<Option<AssetQuantity>> perUnitFloorPrice;

  final Option<RoyaltyByAsset> assetRoyalty;

  final BitcoinTx utxoTransaction;
  final UtxoID utxoID;

  final BtcPriceInput btcPriceInput;
  final FormzSubmissionStatus submissionStatus;

  final bool showSignPsbtModal;
  final Option<String> unsignedPsbtHex;

  final DateTime? expiryDate;
  final String? error;
  final String? signedPsbt;

  // this is only used for display
  RemoteData<Option<AssetQuantity>> get adjustedPerUnitPrice =>
      perUnitFloorPrice.map((maybeFloor) {
        return maybeFloor.map((floor) {
          // no royalty → no adjustment
          return assetRoyalty.fold(
            () => floor,
            (roy) {
              final bps = Decimal.fromInt(roy.royalty);
              final r = bps / Decimal.fromInt(10000);
              final oneMinusR =
                  (Decimal.one - r.toDecimal(scaleOnInfinitePrecision: 8));

              if (oneMinusR <= Decimal.zero) return floor;

              final floorRaw = Decimal.fromBigInt(floor.quantity);

              final adjustedRaw = (floorRaw / oneMinusR).ceil();

              return AssetQuantity(divisible: true, quantity: adjustedRaw);
            },
          );
        });
      });

  CreatePsbtFormModel(
      {required this.utxoID,
      required this.btcPriceInput,
      // required this.royaltyInput,
      required this.submissionStatus,
      required this.showSignPsbtModal,
      required this.unsignedPsbtHex,
      required this.utxoTransaction,
      required this.perUnitFloorPrice,
      this.expiryDate,
      this.error,
      this.signedPsbt,
      required this.assetRoyalty});

  @override
  List<FormzInput> get inputs => [
        btcPriceInput,
      ];

  CreatePsbtFormModel copyWith(
          {Option<RoyaltyByAsset>? assetRoyalty,
          UtxoID? utxoID,
          BitcoinTx? utxoTransaction,
          BtcPriceInput? btcPriceInput,
          RemoteData<Option<AssetQuantity>>? perUnitFloorPrice,
          DateTime? expiryDate,
          FormzSubmissionStatus? submissionStatus,
          String? error,
          String? signedPsbt,
          Option<String>? unsignedPsbtHex,
          Option<bool> showSignPsbtModal = const None()}) =>
      CreatePsbtFormModel(
        perUnitFloorPrice: perUnitFloorPrice ?? this.perUnitFloorPrice,
        utxoID: utxoID ?? this.utxoID,
        utxoTransaction: utxoTransaction ?? this.utxoTransaction,
        assetRoyalty: assetRoyalty ?? this.assetRoyalty,
        unsignedPsbtHex: unsignedPsbtHex ?? this.unsignedPsbtHex,
        showSignPsbtModal:
            showSignPsbtModal.getOrElse(() => this.showSignPsbtModal),
        btcPriceInput: btcPriceInput ?? this.btcPriceInput,
        expiryDate: expiryDate ?? this.expiryDate,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        error: error ?? this.error,
        signedPsbt: signedPsbt ?? this.signedPsbt,
      );

  BigInt get minimumRoyalty {
    return assetRoyalty.fold(
        () => BigInt.zero, (royalty) => _calculateMinRoyalty(royalty, dust));
  }

  bool get relativePriceButtonsDisabled => perUnitFloorPrice.fold3(
      onFailure: (_) => true,
      onNone: () => true,
      onReplete: (opt) => opt.fold(() => true, (_) => false));

  String get relativePriceButtonTooltip => adjustedPerUnitPrice.fold3(
      onFailure: (_) => "Error deriving floor price",
      onNone: () => "",
      onReplete: (opt) => opt.fold(() => "No floor price",
          (price) => "${price.normalized()} BTC / unit"));

  bool get submitDisabled => isNotValid || submissionStatus.isInProgress;

  Vout get vout => utxoTransaction.vout[utxoID.vout];

  BigInt get minPrice => assetRoyalty.fold(() => dust, (royalty) {
        return _calculateMinPrice(royalty, dust, vout.value);
      });

  BigInt get royaltyAmount => assetRoyalty.fold(() => BigInt.zero, (royalty) {
        return (Decimal.fromBigInt(
                    btcPriceInput.asSats.getOrElse(() => BigInt.zero)) *
                Decimal.fromInt(royalty.royalty) /
                Decimal.fromInt(10000))
            .floor();
      });
}

sealed class CreatePsbtFormEvent extends Equatable {
  const CreatePsbtFormEvent();

  @override
  List<Object?> get props => [];
}

class FormDataRequested extends CreatePsbtFormEvent {}

enum RelativePriceValue {
  floor,
  plus5,
  plus10,
  plus15,
}

class RelativePriceButtonClicked extends CreatePsbtFormEvent {
  final RelativePriceValue value;

  const RelativePriceButtonClicked({required this.value});
}

class BtcPriceInputChanged extends CreatePsbtFormEvent {
  final String value;

  const BtcPriceInputChanged({required this.value});
}

class BtcPriceUnitToggle extends CreatePsbtFormEvent {
  const BtcPriceUnitToggle();
}

class SubmitClicked extends CreatePsbtFormEvent {}

class CloseSignPsbtModalClicked extends CreatePsbtFormEvent {
  const CloseSignPsbtModalClicked();
}

class SignatureCompleted extends CreatePsbtFormEvent {
  final String signedPsbtHex;

  const SignatureCompleted({required this.signedPsbtHex});
}

class ExpiryDateSelected extends CreatePsbtFormEvent {
  final DateTime? date;

  const ExpiryDateSelected({this.date});
}

class CreatePsbtFormBloc
    extends Bloc<CreatePsbtFormEvent, CreatePsbtFormModel> {
  final AddressV2 address;

  final String asset;
  final AssetQuantity utxoQuantity;
  final UtxoID utxoID;
  final HttpConfig httpConfig;

  final TransactionService _transactionService;

  final AtomicSwapRepository _atomicSwapRepository;

  CreatePsbtFormBloc({
    required this.asset,
    required this.utxoQuantity,
    required Option<RoyaltyByAsset> assetRoyalty,
    required this.address,
    required this.httpConfig,
    required this.utxoID,
    required BitcoinTx utxoTransaction,
    BitcoinRepository? bitcoinRepository,
    TransactionService? transactionService,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    InMemoryKeyRepository? inMemoryKeyRepository,
    EncryptionService? encryptionService,
    AddressService? addressService,
  })  : _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _atomicSwapRepository = GetIt.I<AtomicSwapRepository>(),
        super(
          CreatePsbtFormModel(
            perUnitFloorPrice: Initial(),
            utxoID: utxoID,
            utxoTransaction: utxoTransaction,
            assetRoyalty: assetRoyalty,
            showSignPsbtModal: false,
            unsignedPsbtHex: const None(),
            btcPriceInput: BtcPriceInput.pure(
                unit: BtcPriceUnit.sats,
                minPrice: assetRoyalty.fold(
                    () => dust,
                    (royalty) => _calculateMinPrice(
                        royalty,
                        dust,
                        utxoTransaction
                            .vout[utxoID.vout].value))), // temp value
            submissionStatus: FormzSubmissionStatus.initial,
          ),
        ) {
    on<BtcPriceInputChanged>(_onBtcPriceInputChanged); // handler wired up once
    on<SubmitClicked>(_onSubmitClicked);
    on<CloseSignPsbtModalClicked>(_onCloseSignPsbtModalClicked);
    on<SignatureCompleted>((event, emit) {
      emit(state.copyWith(
        showSignPsbtModal: const Option.of(false),
        signedPsbt: event.signedPsbtHex,
        submissionStatus: FormzSubmissionStatus.success,
      ));

      emit(state.copyWith(
        showSignPsbtModal: const Option.of(false),
        signedPsbt: event.signedPsbtHex,
        submissionStatus: FormzSubmissionStatus.initial,
      ));
    });
    on<ExpiryDateSelected>(_onExpiryDateSelected);
    on<RelativePriceButtonClicked>(_onRelativePriceButtonClicked);
    on<FormDataRequested>(_onFormDataRequested);
    on<BtcPriceUnitToggle>(_onBtcPriceUnitToggle);

    add(FormDataRequested());
  }

  void _onFormDataRequested(
      FormDataRequested event, Emitter<CreatePsbtFormModel> emit) async {
    emit(state.copyWith(
      perUnitFloorPrice: Loading(),
      error: null,
    ));

    final TaskEither<String, Option<AssetQuantity>> task =
        TaskEither<String, Option<AssetQuantity>>.Do(($) async {
      final swaps = await $(_atomicSwapRepository.getSwapsByAssetT(
        httpConfig: httpConfig,
        asset: asset,
        orderBy: "price",
        order: "asc",
      ));

      if (swaps.isEmpty) {
        return Option.none();
      }

      return Option.of(swaps.first.pricePerUnit);
    });

    final result = await task.run();

    final nextState = result.fold(
        (err) => state.copyWith(
            error: err.toString(), perUnitFloorPrice: Failure(err.toString())),
        (maybePrice) => state.copyWith(
              perUnitFloorPrice: Success(maybePrice),
            ));

    emit(nextState);
  }

  void _onRelativePriceButtonClicked(RelativePriceButtonClicked event,
      Emitter<CreatePsbtFormModel> emit) async {
    final TaskEither<String, Option<(AssetQuantity, String)>> task =
        TaskEither<String, Option<(AssetQuantity, String)>>.Do(($) async {
      final swaps = await $(_atomicSwapRepository.getSwapsByAssetT(
        httpConfig: httpConfig,
        asset: asset,
        orderBy: "price",
        order: "asc",
      ));

      if (swaps.isEmpty) {
        return Option.none();
      }

      final Decimal utxoQuantityDecimal =
          Decimal.parse(utxoQuantity.normalized());

      final Decimal lowUnitPrice =
          Decimal.parse(swaps.first.pricePerUnit.normalized());

      final Decimal adjustedUnitPrice = state.assetRoyalty.fold(
        () => lowUnitPrice,
        (roy) {
          final bps = Decimal.fromInt(roy.royalty); // e.g. 250 = 2.5%
          final r = bps / Decimal.fromInt(10000); // 0.025
          final oneMinusR =
              (Decimal.one - r.toDecimal(scaleOnInfinitePrecision: 8));
          if (oneMinusR <= Decimal.zero) return lowUnitPrice;
          return (lowUnitPrice / oneMinusR)
              .toDecimal(scaleOnInfinitePrecision: 9);
        },
      );

      final Decimal factor = switch (event.value) {
        RelativePriceValue.floor => Decimal.one,
        RelativePriceValue.plus5 => Decimal.parse("1.05"), // 1.05
        RelativePriceValue.plus10 => Decimal.parse("1.10"), // 1.10
        RelativePriceValue.plus15 => Decimal.parse("1.15"), // 1.15
      };

      final totalPriceDecimal =
          (adjustedUnitPrice * factor) * utxoQuantityDecimal;

      return Option.of((
        swaps.first.pricePerUnit,
        totalPriceDecimal.ceil(scale: 8).toStringAsFixed(8),
      ));
    });
    final result = await task.run();
    final nextState = result.fold(
      (_) {
        return state.copyWith(perUnitFloorPrice: Success(Option.none()));
      },
      (maybeData) => maybeData.fold(
        () => state.copyWith(perUnitFloorPrice: Success(Option.none())),
        (data) => state.copyWith(
          btcPriceInput: BtcPriceInput.dirty(
            unit: state.btcPriceInput.unit,
            minPrice: state.minPrice,
            value: data.$2,
          ),
          submissionStatus: FormzSubmissionStatus.initial,
        ),
      ),
    );

    emit(nextState);
  }

  void _onExpiryDateSelected(
      ExpiryDateSelected event, Emitter<CreatePsbtFormModel> emit) {
    emit(state.copyWith(expiryDate: event.date));
  }

  void _onBtcPriceUnitToggle(
      BtcPriceUnitToggle event, Emitter<CreatePsbtFormModel> emit) {
    final newUnit = state.btcPriceInput.unit == BtcPriceUnit.sats
        ? BtcPriceUnit.btc
        : BtcPriceUnit.sats;
    // sats to btc and btc to sats convert value

    if (state.btcPriceInput.value.isNotEmpty) {
      final newValue = newUnit == BtcPriceUnit.btc
          ? satoshisToBtc(state.btcPriceInput.asDecimal
                  .getOrElse(() => Decimal.zero)
                  .toBigInt()
                  .toInt())
              .toString()
          : state.btcPriceInput.asSats.getOrElse(() => BigInt.zero).toString();
      emit(state.copyWith(
          btcPriceInput: BtcPriceInput.dirty(
        minPrice: state.minPrice,
        value: newValue,
        unit: newUnit,
      )));
    } else {
      emit(state.copyWith(
          btcPriceInput: BtcPriceInput.pure(
        minPrice: state.minPrice,
        unit: newUnit,
      )));
    }
  }

  // give the handler an explicit return type
  void _onBtcPriceInputChanged(
    BtcPriceInputChanged event,
    Emitter<CreatePsbtFormModel> emit,
  ) {
    final btcPriceInput = BtcPriceInput.dirty(
        minPrice: state.minPrice,
        value: event.value,
        unit: state.btcPriceInput.unit);

    emit(
      state.copyWith(
        showSignPsbtModal: const Option.of(false),
        unsignedPsbtHex: const Option.none(),
        btcPriceInput: btcPriceInput, // mark it dirty
        submissionStatus: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitClicked(
    SubmitClicked event,
    Emitter<CreatePsbtFormModel> emit,
  ) async {
    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.inProgress,
      // TODO: just get rid of this
    ));

    final attachTxID = utxoID.txid;
    final voutIndex = utxoID.vout;

    final task = TaskEither<String, String>.Do(($) async {
      final tx = state.utxoTransaction;

      final priceInSats = await $(TaskEither.fromOption(
          state.btcPriceInput.asSats,
          () => "Error parsing BTC price input as sats"));

      final royaltyAmount = state.assetRoyalty.fold(
          () => BigInt.zero,
          (royalty) => (Decimal.fromBigInt(priceInSats) *
                  Decimal.fromInt(royalty.royalty) /
                  Decimal.fromInt(10000))
              .floor());

      final totalPrice = priceInSats - royaltyAmount;

      final newSalePsbtHex = await $(_transactionService.makeSalePsbtT(
          price: totalPrice,
          source: address.address,
          utxoTxid: attachTxID,
          utxoVoutIndex: voutIndex,
          utxoVout: tx.vout[voutIndex],
          httpConfig: httpConfig,
          onError: (err) => err.toString()));

      return newSalePsbtHex;
    });

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    final result = await task.run();

    final nextState = result.fold((err) {
      return state.copyWith(
          error: err.toString(),
          submissionStatus: FormzSubmissionStatus.failure);
    }, (psbtHex) {
      return state.copyWith(
        unsignedPsbtHex: Option.of(psbtHex),
        showSignPsbtModal: const Option.of(true),
      );
      // submissionStatus: FormzSubmissionStatus.success));
    });

    emit(nextState);
  }

  void _onCloseSignPsbtModalClicked(
    CloseSignPsbtModalClicked event,
    Emitter<CreatePsbtFormModel> emit,
  ) {
    emit(state.copyWith(
      showSignPsbtModal: const Option.of(false),
      unsignedPsbtHex: const None(),
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }
}
