import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_send.dart';
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
        const feeRateSend = 0;
        final source = event.originalAddress;
        final destination = newAddress.address;
        final asset = event.asset;
        final quantity = event.giveQuantity;
        final escrowQuantity = event.escrowQuantity;
        final mainchainrate = event.mainchainrate;

        final composeSendResponse1 = await composeTransactionUseCase
            .call<ComposeSendParams, ComposeSendResponse>(
          feeRate: feeRateSend,
          source: source,
          params: ComposeSendParams(
            source: source,
            destination: destination,
            asset: asset,
            quantity: quantity,
          ),
          composeFn: composeRepository.composeSendVerbose,
        );

        final composedSend1 = composeSendResponse1.$1;
        final virtualSizeSend1 = composeSendResponse1.$2;

        final composeDispenserResponse = await composeTransactionUseCase
            .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
          feeRate: event.feeRate,
          source: source,
          params: ComposeDispenserParams(
            source: source,
            asset: asset,
            giveQuantity: quantity,
            escrowQuantity: escrowQuantity,
            mainchainrate: mainchainrate,
            status: 0,
          ),
          composeFn: composeRepository.composeDispenserVerbose,
        );

        final composedDispenser = composeDispenserResponse.$1;
        final virtualSizeDispenser = composeDispenserResponse.$2;

        // final composedDispenser = composeDispenserResponse.$1;
        // final virtualSizeDispenser = composeDispenserResponse.$2;

        // emit(state.copyWith(
        //     composeDispenserOnNewAddressState:
        //         ComposeDispenserOnNewAddressState.success(
        //   composeTransaction: composedDispenser,
        //   fee: composedDispenser.btcFee,
        //   feeRate: event.feeRate,
        //   virtualSize: virtualSizeDispenser.virtualSize,
        //   adjustedVirtualSize: virtualSizeDispenser.adjustedVirtualSize,
        // )));
        // emit(state.copyWith(
        //     submitState: SubmitComposingTransaction<ComposeSendResponse, void>(
        //   composeTransaction: composed,
        //   fee: composed.btcFee,
        //   feeRate: feeRate,
        //   virtualSize: virtualSize.virtualSize,
        //   adjustedVirtualSize: virtualSize.adjustedVirtualSize,
        // )));
        /**
         * fee = fee_rate * (adj_size_1 + adj_size_2)
         */

        // two sends will be created, so we need to multiply the adjusted virtual size by 2
        final adjustedVirtualSizeSend =
            virtualSizeSend1.adjustedVirtualSize * 2;

        final int estimatedFee = event.feeRate *
            (adjustedVirtualSizeSend +
                virtualSizeDispenser.adjustedVirtualSize);

        final composeSendResponse2 = await composeTransactionUseCase
            .call<ComposeSendParams, ComposeSendResponse>(
          feeRate: feeRateSend,
          source: source,
          params: ComposeSendParams(
            source: source,
            destination: destination,
            asset: 'BTC',
            quantity: estimatedFee,
          ),
          composeFn: composeRepository.composeSendVerbose,
        );
        final composedSend2 = composeSendResponse2.$1;
        final virtualSizeSend2 = composeSendResponse2.$2;

        print(composedDispenser);
        emit(state.copyWith(
            composeDispenserOnNewAddressState:
                ComposeDispenserOnNewAddressState.confirm(
          composeSendTransaction1: composedSend1,
          composeSendTransaction2: composedSend2,
          composeDispenserTransaction: composedDispenser,
          fee: estimatedFee,
          feeRate: event.feeRate,
          totalVirtualSize: virtualSizeSend1.adjustedVirtualSize +
              virtualSizeSend2.adjustedVirtualSize +
              virtualSizeDispenser.adjustedVirtualSize,
          totalAdjustedVirtualSize: virtualSizeSend1.adjustedVirtualSize +
              virtualSizeSend2.adjustedVirtualSize +
              virtualSizeDispenser.adjustedVirtualSize,
        )));
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
