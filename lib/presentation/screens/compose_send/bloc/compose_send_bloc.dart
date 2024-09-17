import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/usecase/get_fee_estimates.dart';
import 'package:horizon/domain/usecase/get_max_send_quantity.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:rxdart/transformers.dart';
import "dart:async";

class ComposeSendBloc extends Bloc<ComposeSendEvent, ComposeSendState> {
  final AddressRepository addressRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final UtxoRepository utxoRepository;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionRepository transactionRepository;
  final TransactionLocalRepository transactionLocalRepository;
  final BitcoinRepository bitcoinRepository;

  ComposeSendBloc({
    required this.addressRepository,
    required this.balanceRepository,
    required this.composeRepository,
    required this.utxoRepository,
    required this.transactionService,
    required this.bitcoindService,
    required this.accountRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.transactionRepository,
    required this.transactionLocalRepository,
    required this.bitcoinRepository,
  }) : super(ComposeSendState(feeOption: FeeOption.Medium())) {
    on<ChangeFeeOption>(
      (event, emit) async {
        final value = event.value;
        emit(state.copyWith(feeOption: value, composeSendError: null));

        if (!state.sendMax) return;

        FeeEstimates? feeEstimates = state.feeState
            .maybeWhen(success: (value) => value, orElse: () => null);
        if (feeEstimates == null) {
          return;
        }

        if (state.destination == null) {
          emit(state.copyWith(
              sendMax: false,
              composeSendError: "Set destination",
              maxValue: MaxValueState.initial()));
          return;
        }

        emit(state.copyWith(maxValue: MaxValueState.loading()));

        try {
          final source = state.source!.address;
          final asset = state.asset ?? "BTC";
          final feeRate = switch (state.feeOption) {
            FeeOption.Fast() => feeEstimates.fast,
            FeeOption.Medium() => feeEstimates.medium,
            FeeOption.Slow() => feeEstimates.slow,
            FeeOption.Custom(fee: var fee) => fee,
          };

          final max = await GetMaxSendQuantity(
            source: source,
            // destination: state.destination!,
            asset: asset,
            feeRate: feeRate,
            balanceRepository: balanceRepository,
            composeRepository: composeRepository,
            transactionService: transactionService,
          ).call();

          emit(state.copyWith(maxValue: MaxValueState.success(max)));
        } catch (e) {
          emit(state.copyWith(
              sendMax: false,
              composeSendError: "Insufficient funds",
              maxValue: MaxValueState.error(e.toString())));
        }
      },
      transformer: debounce(const Duration(milliseconds: 500)),
    );

    on<ToggleSendMaxEvent>(
      (event, emit) async {
        // return early if fee estimates haven't loaded
        FeeEstimates? feeEstimates = state.feeState
            .maybeWhen(success: (value) => value, orElse: () => null);
        if (feeEstimates == null) {
          return;
        }

        // if (state.destination == null) {
        //   emit(state.copyWith(
        //       sendMax: false,
        //       composeSendError: "Set destination",
        //       maxValue: MaxValueState.initial()));
        //   return;
        // }

        final value = event.value;
        emit(state.copyWith(sendMax: value, composeSendError: null));

        if (!value) {
          emit(state.copyWith(maxValue: MaxValueState.initial()));
        }

        emit(state.copyWith(maxValue: MaxValueState.loading()));

        try {
          final source = state.source!.address;
          final asset = state.asset ?? "BTC";
          final feeRate = switch (state.feeOption) {
            FeeOption.Fast() => feeEstimates.fast,
            FeeOption.Medium() => feeEstimates.medium,
            FeeOption.Slow() => feeEstimates.slow,
            FeeOption.Custom(fee: var fee) => fee,
          };

          final max = await GetMaxSendQuantity(
            source: source,
            // destination: state.destination!,
            asset: asset,
            feeRate: feeRate,
            balanceRepository: balanceRepository,
            composeRepository: composeRepository,
            transactionService: transactionService,
          ).call();

          emit(state.copyWith(maxValue: MaxValueState.success(max)));
        } catch (e) {
          rethrow;
          emit(state.copyWith(
              sendMax: false,
              composeSendError: "Insufficient funds",
              maxValue: MaxValueState.error(e.toString())));
        }
      },
      transformer: debounce(const Duration(milliseconds: 500)),
    );

    on<ChangeAsset>((event, emit) async {
      final asset = event.asset;
      emit(state.copyWith(
          asset: asset,
          sendMax: false,
          quantity: "",
          composeSendError: null,
          feeOption: FeeOption.Medium()));
    });

    on<ChangeDestination>((event, emit) async {
      final destination = event.value;
      emit(state.copyWith(destination: destination, composeSendError: null));
    });

    on<ChangeQuantity>((event, emit) async {
      final quantity = event.value;

      emit(state.copyWith(
          quantity: quantity,
          sendMax: false,
          composeSendError: null,
          maxValue: MaxValueState.initial()));
    });

    on<FetchFormData>((event, emit) async {
      emit(state.copyWith(
        balancesState: BalancesState.loading(),
        submitState: SubmitState.initial(),
        source: event.currentAddress, // TODO: setting address this way is smell
      ));

      late List<Balance> balances;
      late FeeEstimates feeEstimates;
      try {
        List<Address> addresses = [event.currentAddress];

        balances =
            await balanceRepository.getBalancesForAddress(addresses[0].address);
      } catch (e) {
        emit(state.copyWith(
            balancesState: BalancesState.error(e.toString()),
            submitState: const SubmitState.initial()));
        return;
      }
      try {
        feeEstimates = await GetFeeEstimates(
          targets: (1, 3, 6),
          bitcoindService: bitcoindService,
        ).call();
      } catch (e) {
        emit(state.copyWith(
            feeState: FeeState.error(e.toString()),
            submitState: const SubmitState.initial()));
        return;
      }

      emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          submitState: const SubmitState.initial()));
    });
    on<ComposeTransactionEvent>((event, emit) async {
      FeeEstimates? feeEstimates = state.feeState
          .maybeWhen(success: (value) => value, orElse: () => null);

      if (feeEstimates == null) {
        return;
      }
      emit(state.copyWith(submitState: const SubmitState.loading()));

      try {
        final source = event.sourceAddress;
        final destination = event.destinationAddress;
        final quantity = event.quantity;
        final asset = event.asset;
        final feeRate = switch (state.feeOption) {
          FeeOption.Fast() => feeEstimates.fast,
          FeeOption.Medium() => feeEstimates.medium,
          FeeOption.Slow() => feeEstimates.slow,
          FeeOption.Custom(fee: var fee) => fee,
        };

        print("fee option: ${state.feeOption}");
        print("fee rate: $feeRate");

        // final send = await composeRepository.composeSendVerbose(
        //     source, destination, asset, quantity, true, 1);

        print("composing once more with dummy args");
        final send = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, 1);
        final virtualSize =
            transactionService.getVirtualSize(send.rawtransaction);

        print("virutal size 2: $virtualSize");

        print("\n\n\n\n");

        final totalFee = virtualSize * feeRate;

        final sendActual = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, totalFee);

        emit(state.copyWith(
            submitState: SubmitState.composing(SubmitStateComposingSend(
          composeSend: sendActual,
          virtualSize: virtualSize,
          fee: totalFee,
          feeRate: feeRate,
        ))));
      } catch (error) {
        emit(state.copyWith(submitState: SubmitState.error(error.toString())));
      }
    });

    on<FinalizeTransactionEvent>((event, emit) async {
      emit(state.copyWith(
          submitState: SubmitState.finalizing(SubmitStateFinalizing(
        composeSend: event.composeSend,
        fee: event.fee,
      ))));
    });

    on<SignAndBroadcastTransactionEvent>((event, emit) async {
      final finalizingState = state.submitState.maybeWhen(
          finalizing: (finalizing) => finalizing,
          orElse: () => throw Exception("Invariant: state not found"));

      emit(state.copyWith(submitState: const SubmitState.loading()));

      try {
        final sendParams = finalizingState.composeSend.params;
        final source = sendParams.source;
        final destination = sendParams.destination;
        final quantity = sendParams.quantity;
        final asset = sendParams.asset;
        final fee = finalizingState.fee;
        final password = event.password;

        // Compose a new tx with user specified fee
        final send = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, fee);

        final rawTx = send.rawtransaction;

        // final memo = event.memo;
        // final memoIsHex = event.memoIsHex;

        final utxoResponse =
            await utxoRepository.getUnspentForAddress(source, true);

        Map<String, Utxo> utxoMap = {for (var e in utxoResponse) e.txid: e};

        Address? address = await addressRepository.getAddress(source);
        Account? account =
            await accountRepository.getAccountByUuid(address!.accountUuid);
        Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);
        String? decryptedRootPrivKey;
        try {
          decryptedRootPrivKey = await encryptionService.decrypt(
              wallet!.encryptedPrivKey, password);
        } catch (e) {
          throw Exception("Incorrect password");
        }
        String addressPrivKey = await addressService.deriveAddressPrivateKey(
            rootPrivKey: decryptedRootPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            purpose: account.purpose,
            coin: account.coinType,
            account: account.accountIndex,
            change: '0',
            index: address.index,
            importFormat: account.importFormat);

        String txHex = await transactionService.signTransaction(
            rawTx, addressPrivKey, source, utxoMap);

        String txHash = await bitcoindService.sendrawtransaction(txHex);

        // for now we don't track btc sends
        if (asset.toLowerCase() != 'btc') {
          TransactionInfoVerbose txInfo =
              await transactionRepository.getInfoVerbose(txHex);

          await transactionLocalRepository.insertVerbose(txInfo.copyWith(
              hash: txHash,
              source:
                  source // TODO: set this manually as a tmp hack because it can be undefined with btc sends
              ));
        } else {
          // TODO: this is a bit of a hack
          transactionLocalRepository.insertVerbose(TransactionInfoVerbose(
            hash: txHash,
            source: source,
            destination: destination,
            btcAmount: quantity,
            domain: TransactionInfoDomainLocal(
                raw: txHex, submittedAt: DateTime.now()),
            btcAmountNormalized: quantity.toString(), //TODO: this is temporary
            fee: 0, // dummy values
            data: "",
          ));
        }

        emit(state.copyWith(submitState: SubmitState.success(txHash, source)));
      } catch (error) {
        emit(state.copyWith(submitState: SubmitState.error(error.toString())));
      }
    });
  }
}

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (Stream<Event> events, Stream<Event> Function(Event) mapper) => events
      .transform(
        StreamTransformer<Event, Event>.fromHandlers(
          handleData: (Event event, EventSink<Event> sink) => sink.add(event),
          handleDone: (EventSink<Event> sink) => sink.close(),
          handleError:
              (Object error, StackTrace stackTrace, EventSink<Event> sink) =>
                  sink.addError(error, stackTrace),
        ),
      )
      .debounceTime(duration)
      .switchMap(mapper);
}
