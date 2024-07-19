import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';

import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';

class ComposeIssuanceBloc
    extends Bloc<ComposeIssuanceEvent, ComposeIssuanceState> {
  ComposeIssuanceBloc() : super(const ComposeIssuanceState()) {
    final AddressRepository addressRepository =
        GetIt.I.get<AddressRepository>();
    final BalanceRepository balanceRepository =
        GetIt.I.get<BalanceRepository>();
    final composeRepository = GetIt.I.get<ComposeRepository>();
    final UtxoRepository utxoRepository = GetIt.I.get<UtxoRepository>();
    final AccountRepository accountRepository =
        GetIt.I.get<AccountRepository>();
    final WalletRepository walletRepository = GetIt.I.get<WalletRepository>();
    final EncryptionService encryptionService =
        GetIt.I.get<EncryptionService>();
    final AddressService addressService = GetIt.I.get<AddressService>();
    final TransactionService transactionService =
        GetIt.I.get<TransactionService>();
    final BitcoindService bitcoindService = GetIt.I.get<BitcoindService>();
    final transactionRepository = GetIt.I.get<TransactionRepository>();

    on<FetchFormData>((event, emit) async {
      emit(const ComposeIssuanceState(
          addressesState: AddressesState.loading(),
          balancesState: BalancesState.loading(),
          submitState: SubmitState.initial()));

      try {
        List<Address> addresses =
            await addressRepository.getAllByAccountUuid(event.accountUuid);
        List<Balance> balances =
            await balanceRepository.getBalancesForAddress(addresses[0].address);
        emit(ComposeIssuanceState(
          addressesState: AddressesState.success(addresses),
          balancesState: BalancesState.success(balances),
        ));
      } catch (e) {
        emit(ComposeIssuanceState(
          addressesState: AddressesState.error(e.toString()),
          balancesState: BalancesState.error(e.toString()),
        ));
      }
    });

    on<FetchBalances>((event, emit) async {
      emit(state.copyWith(balancesState: const BalancesState.loading()));
      try {
        List<Balance> balances =
            await balanceRepository.getBalancesForAddress(event.address);
        emit(state.copyWith(balancesState: BalancesState.success(balances)));
      } catch (e) {
        emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
      }
    });

    on<CreateIssuanceEvent>((event, emit) async {
      final source = event.sourceAddress;
      final quantity = event.quantity;
      final name = event.name;
      final password = event.password;
      final divisible = event.divisible;
      final lock = event.lock;
      final reset = event.reset;
      final description = event.description;
      final transferDestination = event.transferDestination;

      emit(state.copyWith(submitState: const SubmitState.loading()));
      try {
        ComposeIssuance issuance = await composeRepository.composeIssuance(
            source,
            name,
            quantity,
            divisible,
            lock,
            reset,
            description,
            transferDestination);

        final utxoResponse = await utxoRepository.getUnspentForAddress(source);

        Map<String, Utxo> utxoMap = {for (var e in utxoResponse) e.txid: e};

        Address? address = await addressRepository.getAddress(source);
        Account? account =
            await accountRepository.getAccountByUuid(address!.accountUuid);
        Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);
        String decryptedRootPrivKey =
            await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
        String addressPrivKey = await addressService.deriveAddressPrivateKey(
            rootPrivKey: decryptedRootPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            purpose: account.purpose,
            coin: account.coinType,
            account: account.accountIndex,
            change: '0', // TODO make sure change is stored
            index: address.index);

        String txHex = await transactionService.signTransaction(
            issuance.rawtransaction, addressPrivKey, source, utxoMap);

        String txHash = await bitcoindService.sendrawtransaction(txHex);

        TransactionUnpacked unpacked =
            await transactionRepository.unpack(txHex);

        await transactionRepository.insert(
          source: source,
          hash: txHash,
          hex: txHex,
          unpacked: unpacked,
        );

        emit(state.copyWith(submitState: SubmitState.success(txHex)));
      } catch (error) {
        if (error is DioException) {
          emit(state.copyWith(
              submitState: SubmitState.error(
                  "${error.response!.data.keys.first} ${error.response!.data.values.first}")));
        } else {
          emit(
              state.copyWith(submitState: SubmitState.error(error.toString())));
        }
      }
    });
  }
}
