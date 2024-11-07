import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/usecase/fetch_form_data.dart';

// this number comes from the adjusted size for a similar asset send (~166) + the adjusted size for a  create dispenser (~193) + ajuste size of ~166 for a btc + wiggle room
const int ADJUSTED_VIRTUAL_SIZE = 1000;

class ComposeDispenserOnNewAddressBloc extends Bloc<
    ComposeDispenserOnNewAddressEvent, ComposeDispenserOnNewAddressStateBase> {
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ComposeRepository composeRepository;
  final BitcoindService bitcoindService;
  final UtxoRepository utxoRepository;
  final ComposeTransactionUseCase composeTransactionUseCase;

  final FetchDispenserOnNewAddressFormDataUseCase
      fetchDispenserOnNewAddressFormDataUseCase;

  ComposeDispenserOnNewAddressBloc({
    required this.accountRepository,
    required this.addressRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.composeRepository,
    required this.bitcoindService,
    required this.utxoRepository,
    required this.composeTransactionUseCase,
    required this.fetchDispenserOnNewAddressFormDataUseCase,
  }) : super(const ComposeDispenserOnNewAddressStateBase(
          composeDispenserOnNewAddressState:
              ComposeDispenserOnNewAddressState.loading(),
          feeState: FeeState.initial(),
        )) {
    on<FetchFormData>((event, emit) async {
      emit(state.copyWith(
          feeState: const FeeState.loading(),
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.loading()));
      final feeEstimates =
          await fetchDispenserOnNewAddressFormDataUseCase.call();
      emit(state.copyWith(
          feeState: FeeState.success(feeEstimates),
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.collectPassword(
                  loading: false)));
    });

    on<ComposeTransactions>((event, emit) async {
      emit(state.copyWith(
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.collectPassword(
                  loading: true)));
      final wallet = await walletRepository.getCurrentWallet();
      print('WALLET: $wallet');
      if (wallet == null) {
        emit(const ComposeDispenserOnNewAddressStateBase(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.error('Wallet not found')));
        return;
      }
      print('before decryptedPrivKey');

      String? decryptedPrivKey;
      try {
        print('before decrypt');
        decryptedPrivKey = await encryptionService.decrypt(
            wallet.encryptedPrivKey, event.password);
        print('after decrypt');
      } catch (e) {
        emit(const ComposeDispenserOnNewAddressStateBase(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.collectPassword(
                    error: 'Invalid password', loading: false)));
        return;
      }

      emit(state.copyWith(password: event.password));
      print('after decrypt');
      final List<Account> accountsInWallet =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);
      final highestIndexAccount = getHighestIndexAccount(accountsInWallet);
      final int newAccountIndex =
          int.parse(highestIndexAccount.accountIndex.replaceAll('\'', '')) + 1;
      final Account newAccount = Account(
        accountIndex: newAccountIndex.toString(),
        walletUuid: wallet.uuid,
        name: 'Account $newAccountIndex',
        uuid: uuid.v4(),
        purpose: highestIndexAccount.purpose,
        coinType: highestIndexAccount.coinType,
        importFormat: highestIndexAccount.importFormat,
      );
      print('after newAccount');
      final Address newAddress = await addressService.deriveAddressSegwit(
        privKey: decryptedPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        accountUuid: newAccount.uuid,
        purpose: newAccount.purpose,
        coin: newAccount.coinType,
        account: newAccount.accountIndex,
        change: '0',
        index: 0,
      );
      print('after newAddress');
      // await accountRepository.insert(newAccount);
      // await addressRepository.insert(newAddress);

      try {
        final source = event.originalAddress;
        final destination = newAddress.address;
        final asset = event.asset;
        final quantity = event.giveQuantity;
        final escrowQuantity = event.escrowQuantity;
        final mainchainrate = event.mainchainrate;

        // final assetSendResponse = await composeTransactionUseCase.call<ComposeSendParams, ComposeSendResponse>(
        //   feeRate: 0,
        //   source: source,
        //   params: ComposeSendParams(
        //     source: source,
        //     destination: destination,
        //     asset: asset,
        //     quantity: quantity,
        //   ),
        //   composeFn: composeRepository.composeSendVerbose,
        // );

        // final assetSend = assetSendResponse.$1;
        // final virtualSizeAssetSend = assetSendResponse.$2;

        // final decodedAssetSend = await bitcoindService.decoderawtransaction(assetSend.rawtransaction);
        // print('decodedAssetSend: $decodedAssetSend');

        final feeToCoverAllTransactions = event.feeRate * ADJUSTED_VIRTUAL_SIZE;

        final bitcoinSendResponse = await composeTransactionUseCase
            .call<ComposeSendParams, ComposeSendResponse>(
          feeRate: 0,
          source: source,
          params: ComposeSendParams(
            source: source,
            destination: destination,
            asset: 'BTC',
            quantity: feeToCoverAllTransactions,
          ),
          composeFn: composeRepository.composeSendVerbose,
        );

        final bitcoinSend = bitcoinSendResponse.$1;

        final decodedBtcSend = await bitcoindService
            .decoderawtransaction(bitcoinSend.rawtransaction);
        print('decodedBtcSend: $decodedBtcSend');

        final btcOutput = decodedBtcSend.vout[0];
        final int value = (btcOutput.value * 100000000).toInt();
        final List<Utxo> btcSendInputs = [
          Utxo(
              txid: decodedBtcSend.hash,
              vout: btcOutput.n,
              height: null,
              value: value,
              address: source)
        ];

        final assetSendResponse = await composeRepository.composeSendVerbose(
          0,
          btcSendInputs,
          ComposeSendParams(
            source: source,
            destination: destination,
            asset: asset,
            quantity: escrowQuantity,
          ),
        );

        final decodedAssetSend = await bitcoindService
            .decoderawtransaction(assetSendResponse.rawtransaction);
        print('decodedAssetSend: $decodedAssetSend');
        // final composeDispenserResponse = await composeTransactionUseCase
        //     .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
        //   feeRate: event.feeRate,
        //   source: source,
        //   params: ComposeDispenserParams(
        //     source: source,
        //     asset: asset,
        //     giveQuantity: quantity,
        //     escrowQuantity: escrowQuantity,
        //     mainchainrate: mainchainrate,
        //     status: 0,
        //   ),
        //   composeFn: composeRepository.composeDispenserVerbose,
        // );

        // final composedDispenser = composeDispenserResponse.$1;
        // final virtualSizeDispenser = composeDispenserResponse.$2;

        // two sends will be created, so we need to multiply the adjusted virtual size by 2
        // final adjustedVirtualSizeSend =
        //     virtualSizeSend1.adjustedVirtualSize * 2;

        // final int estimatedFee = event.feeRate *
        //     (adjustedVirtualSizeSend +
        //         virtualSizeDispenser.adjustedVirtualSize);

        // final composeSendResponse2 = await composeTransactionUseCase
        //     .call<ComposeSendParams, ComposeSendResponse>(
        //   feeRate: feeRateSend,
        //   source: source,
        //   params: ComposeSendParams(
        //     source: source,
        //     destination: destination,
        //     asset: 'BTC',
        //     quantity: totalFee,
        //   ),
        //   composeFn: composeRepository.composeSendVerbose,
        // );
        // final composedSend2 = composeSendResponse2.$1;
        // final virtualSizeSend2 = composeSendResponse2.$2;

        // print(composedDispenser);
        // emit(state.copyWith(
        //     composeDispenserOnNewAddressState:
        //         ComposeDispenserOnNewAddressState.confirm(
        //   newAccountName: newAccount.name,
        //   newAddress: newAddress.address,
        //   composeSendTransaction1: assetSend1,
        //   composeSendTransaction2: composedSend2,
        //   composeDispenserTransaction: composedDispenser,
        //   fee: totalFee,
        //   feeRate: event.feeRate,
        //   totalVirtualSize: virtualSizeAssetSend1.adjustedVirtualSize +
        //       virtualSizeSend2.adjustedVirtualSize +
        //       virtualSizeDispenser.adjustedVirtualSize,
        //   totalAdjustedVirtualSize: virtualSizeAssetSend1.adjustedVirtualSize +
        //       virtualSizeSend2.adjustedVirtualSize +
        //       virtualSizeDispenser.adjustedVirtualSize,
        // )));
      } catch (e) {
        emit(ComposeDispenserOnNewAddressStateBase(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.error(
                    e is ComposeTransactionException
                        ? e.message
                        : 'An unexpected error occurred: ${e.toString()}')));
        // emit(state.copyWith(
        //     submitState: SubmitInitial(
        //         loading: false,
        //         error: e is ComposeTransactionException ? e.message : 'An unexpected error occurred: ${e.toString()}')));
      }
    });
  }
}
