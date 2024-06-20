import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/hd_wallet_entity.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/hd_wallet_service.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:logger/logger.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final Logger logger = Logger();

  DashboardBloc() : super(DashboardState()) {
    final walletRepository = GetIt.I<WalletRepository>();
    final accountRepository = GetIt.I<AccountRepository>();
    final addressRepository = GetIt.I<AddressRepository>();
    final hdWalletService = GetIt.I<HDWalletService>();
    final dbManager = GetIt.I<DatabaseManager>();

    on<SetAccountAndWallet>((event, emit) async {
      logger.d('Processing SetAccountAndWallet event');

      try {
        Wallet? wallet = await walletRepository.getCurrentWallet();
        List<Account> accounts = await accountRepository.getAccountsByWalletUuid(wallet!.uuid!);
        emit(state.copyWith(
            walletState: WalletStateSuccess(currentWallet: wallet),
            accountState: AccountStateSuccess(currentAccount: accounts[0], accounts: accounts)));

        logger.d('SetAccountAndWallet event processed successfully. current Account: ${accounts[0].name}');
      } catch (e, stackTrace) {
        logger.e({'message': 'Failed to process SetAccountAndWallet event', 'error': e, 'stackTrace': stackTrace});

        emit(state.copyWith(
            walletState: WalletStateError(message: 'Failed to process SetAccountAndWallet event'),
            accountState: AccountStateError()));
      }
    });

    on<GetAddresses>((event, emit) async {
      logger.d('Processing GetAddresses event');

      emit(state.copyWith(addressState: AddressStateLoading()));
      try {
        final account = state.accountState.currentAccount;
        final addresses = await addressRepository.getAllByAccountUuid(account!.uuid!);
        emit(state.copyWith(addressState: AddressStateSuccess(currentAddress: addresses[0], addresses: addresses)));

        logger.d('GetAddresses event processed successfully. Current address: ${addresses[0].address}');
      } catch (e, stackTrace) {
        logger.e({'message': 'Failed to process GetAddresses event', 'error': e, 'stackTrace': stackTrace});

        emit(state.copyWith(addressState: AddressStateError(message: 'Failed to process GetAddresses event')));
      }
    });

    on<ChangeAddress>((event, emit) async {
      logger.d('Processing ChangeAddress event');

      emit(state.copyWith(addressState: AddressStateLoading()));
      try {
        List<Address> addresses = await addressRepository.getAllByAccountUuid(event.address.accountUuid!);
        emit(state.copyWith(addressState: AddressStateSuccess(currentAddress: event.address, addresses: addresses)));

        logger.d('ChangeAddress event processed successfully. Current address: ${event.address.address}');
      } catch (e, stackTrace) {
        logger.e({'message': 'Failed to process ChangeAddress event', 'error': e, 'stackTrace': stackTrace});

        emit(state.copyWith(addressState: AddressStateError(message: 'Failed to process ChangeAddress event')));
      }
    });

    // just an initial idea for adding a new account -- not ready
    on<AddAccount>((event, emit) async {
      logger.d('Processing AddAccount event');

      emit(state.copyWith(accountState: AccountStateLoading()));
      try {
        Wallet wallet = state.walletState.currentWallet;
        List<Account> allAccounts = await accountRepository.getAccountsByWalletUuid(wallet!.uuid!);
        List<Account> filteredAccounts = allAccounts.where((account) {
          return account.purpose == event.purpose && account.coinType == event.coinType;
        }).toList();
        int accountIndex = filteredAccounts.length;

        AccountAddressEntity entity = await hdWalletService.addNewAccountAndAddress(
            encryptedRootWif: wallet.wif,
            walletUuid: wallet.uuid,
            password: '', // TODO: how to get password here?
            purpose: event.purpose,
            coinType: event.coinType,
            accountIndex: accountIndex);

        await accountRepository.insert(entity.account);
        await addressRepository.insert(entity.address);

        emit(state.copyWith(accountState: AccountStateSuccess(currentAccount: entity.account, accounts: allAccounts)));
      } catch (e, stackTrace) {
        logger.e({'message': 'Failed to process AddAccount event', 'error': e, 'stackTrace': stackTrace});
      }
    });

    on<DeleteWallet>((event, emit) async {
      logger.d('Processing DeleteWallet event');

      try {
        await addressRepository.deleteAllAddresses();
        await walletRepository.deleteAllWallets();
        await accountRepository.deleteAllAccounts();

        // Uncomment the next line to delete the database entirely
        // await dbManager.database.deleteDatabase();

        logger.d('DeleteWallet event processed successfully');
      } catch (e, stackTrace) {
        logger.e({'message': 'Failed to process DeleteWallet event', 'error': e, 'stackTrace': stackTrace});
      }
    });
  }
}
