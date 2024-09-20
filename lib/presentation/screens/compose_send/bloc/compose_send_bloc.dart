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
  }) : super(ComposeSendState(
            feeOption: FeeOption.Medium(),
            submitState: const SubmitInitial())) {
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
              submitState: const SubmitInitial(),
              composeSendError: "Set destination",
              maxValue: const MaxValueState.initial()));
          return;
        }

        emit(state.copyWith(maxValue: const MaxValueState.loading()));

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
        emit(state.copyWith(
            submitState: const SubmitInitial(),
            sendMax: value,
            composeSendError: null));

        if (!value) {
          emit(state.copyWith(maxValue: const MaxValueState.initial()));
        }

        emit(state.copyWith(maxValue: const MaxValueState.loading()));

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
    );

    on<ChangeAsset>((event, emit) async {
      final asset = event.asset;
      emit(state.copyWith(
          submitState: const SubmitInitial(),
          asset: asset,
          sendMax: false,
          quantity: "",
          composeSendError: null,
          feeOption: FeeOption.Medium()));
    });

    on<ChangeDestination>((event, emit) async {
      final destination = event.value;
      emit(state.copyWith(
          submitState: const SubmitInitial(),
          destination: destination,
          composeSendError: null));
    });

    on<ChangeQuantity>((event, emit) async {
      final quantity = event.value;

      emit(state.copyWith(
          submitState: const SubmitInitial(),
          quantity: quantity,
          sendMax: false,
          composeSendError: null,
          maxValue: const MaxValueState.initial()));
    });

    on<FetchFormData>((event, emit) async {
      emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        submitState: const SubmitInitial(),
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
            submitState: const SubmitInitial()));
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
            submitState: const SubmitInitial()));
        return;
      }

      emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          submitState: const SubmitInitial()));
    });
    on<ComposeTransactionEvent>((event, emit) async {
      FeeEstimates? feeEstimates = state.feeState
          .maybeWhen(success: (value) => value, orElse: () => null);

      if (feeEstimates == null) {
        return;
      }
      // TODO: figure out what to do
      emit(state.copyWith(submitState: const SubmitInitial(loading: true)));

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

        /* it's possible that we could bypass this step
           by:
           1) getting the utxo set for the source address
           2) manualy compute the inputs
           3) use formula which is f(inputs, outputs) => virtual_size

           But note: not totally necessary to do this for now


          What we do want to do NOW, is pass in the utxos
          to the compose handler by txhash:vout  ( the utxo index)


          1) get all of the utxos
          2) use some algorithm to determine which ones to select ( talk to ouziel, adam )
          3) pass in the utxos to the compose handler


        final send = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, 1, selected_utxos);


        ... late on somewhere

                                                                KEY
                                                                 |
        utxoQueryStringParam = selected_utxos.map(u => `${u.txid}:${u.vout}`).join(',')


        questions:
            - do we need to worry about the outputs? ( i don't think so)
            - should we prefer confirmed over unconfirmed? ( i assume yes )

        */

        final utxos = await utxoRepository.getUnspentForAddress(source);
        print('SOURCE: $source');
        final utxoQueryStringParam = utxos.map((u) => "${u.txid}:${u.vout}").join(',');

        // this is a dummy transaction that helps us to compute
        // the transaction virtual size which we multiply
        // by sats / vbyte to get the final fee
        final send = await composeRepository.composeSendVerbose(
            // this should be sped up because it doesn't need to pull all utxos
            source,
            destination,
            asset,
            quantity,
            true,
            1,
            null,
            utxoQueryStringParam);
        final virtualSize =
            transactionService.getVirtualSize(send.rawtransaction);

        final totalFee = virtualSize * feeRate;

        final sendActual = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, totalFee, null, utxoQueryStringParam);


        emit(state.copyWith(
            submitState: SubmitComposing(SubmitStateComposingSend(
          composeSend: sendActual,
          virtualSize: virtualSize,
          fee: totalFee,
          feeRate: feeRate,
        ))));
      } catch (error) {
        emit(state.copyWith(
            submitState:
                SubmitInitial(loading: false, error: error.toString())));
      }
    });

    on<FinalizeTransactionEvent>((event, emit) async {
      emit(state.copyWith(
          submitState: SubmitFinalizing(
              loading: false,
              error: null,
              composeSend: event.composeSend,
              fee: event.fee)));
    });

    on<SignAndBroadcastTransactionEvent>((event, emit) async {
      try {
        if (state.submitState is! SubmitFinalizing) {
          return;
        }

        final sendParams = (state.submitState as SubmitFinalizing).composeSend;
        final fee = (state.submitState as SubmitFinalizing).fee;

        emit(state.copyWith(
            submitState: SubmitFinalizing(
                loading: true,
                error: null,
                composeSend: sendParams,
                fee: fee)));

        final source = sendParams.params.source;
        final destination = sendParams.params.destination;
        final quantity = sendParams.params.quantity;
        final asset = sendParams.params.asset;
        final password = event.password;
        final utxoResponse = await utxoRepository.getUnspentForAddress(source);

        final utxoQueryStringParam = utxoResponse.map((u) => "${u.txid}:${u.vout}").join(',');

        // Compose a new tx with user specified fee
        final send = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, fee, null, utxoQueryStringParam);

        final rawTx = send.rawtransaction;


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

        emit(state.copyWith(
            submitState:
                SubmitSuccess(transactionHex: txHash, sourceAddress: source)));
      } catch (error) {
        final sendParams = (state.submitState as SubmitFinalizing).composeSend;
        final fee = (state.submitState as SubmitFinalizing).fee;

        emit(state.copyWith(
            submitState: SubmitFinalizing(
                loading: false,
                error: error.toString(),
                composeSend: sendParams,
                fee: fee)));
      }
    });
  }
}
