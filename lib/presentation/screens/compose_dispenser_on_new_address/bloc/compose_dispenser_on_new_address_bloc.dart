import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
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
              const ComposeDispenserOnNewAddressState.initial()));
    });

    on<CollectPassword>((event, emit) {
      emit(state.copyWith(
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.collectPassword()));
    });
    on<ComposeTransactions>((event, emit) async {
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
                    error: 'Invalid password')));
        return;
      }
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
      // final tx = await composeRepository.composeSendVerbose(
      //   0,
      //   [],
      //   ComposeSendParams(
      //     source: event.originalAddress,
      //     destination: newAddress.address,
      //     asset: 'HZN',
      //     quantity: event.giveQuantity,
      //   ),
      // );
      try {
        const feeRateSend = 0;
        final source = event.originalAddress;
        final destination = newAddress.address;
        final asset = event.asset;
        final quantity = event.giveQuantity;

        final composeSendResponse = await composeTransactionUseCase
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

        final composedSend = composeSendResponse.$1;
        final virtualSizeSend = composeSendResponse.$2;

        // final composeDispenserResponse = await composeTransactionUseCase
        //     .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
        //   feeRate: event.feeRate,
        //   source: destination,
        //   params: ComposeDispenserParams(
        //     source: destination,
        //     asset: asset,
        //     giveQuantity: quantity,
        //     escrowQuantity: quantity,
        //     mainchainrate: 0,
        //   ),
        //   composeFn: composeRepository.composeDispenserVerbose,
        // );

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
        print(composeSendResponse);
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

      // await createSendRepository.createSend(CreateSendParams(
      //   source: event.originalAddress,
      //   destination: newAddress.address,
      //   asset: 'HZN',
      //   quantity: 10,
      // ));
    });
  }
  int _getFeeRate(FeeOption.FeeOption feeOption) {
    FeeEstimates feeEstimates = state.feeState.feeEstimates;
    return switch (feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }
}
