import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
// import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/base_path.dart';
// import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/address.dart';
// import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_v2_repository.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
// import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/common/constants.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import "package:fpdart/fpdart.dart";

import './session_state.dart';

sealed class GetSessionStateResponse {}

class LoggedIn extends GetSessionStateResponse {
  String decryptionKey;

  LoggedIn({required this.decryptionKey});
}

class LoggedOut extends GetSessionStateResponse {}

class NoWallet extends GetSessionStateResponse {}

class SessionStateCubit extends Cubit<SessionState> {
  CacheProvider cacheProvider;
  // WalletRepository walletRepository;
  // AccountRepository accountRepository;
  SettingsRepository _settingsRepository;
  WalletConfigRepository _walletConfigRepository;
  AccountV2Repository _accountV2Repository;
  AddressV2Repository _addressV2Repository;
  ImportedAddressRepository importedAddressRepository;
  AnalyticsService analyticsService;
  InMemoryKeyRepository inMemoryKeyRepository;
  final EncryptionService encryptionService;
  final SecureKVService kvService;
  final MnemonicRepository _mnemonicRepository;

  SessionStateCubit({
    required this.kvService,
    required this.cacheProvider,
    // required this.walletRepository,
    // required this.accountRepository,

    SettingsRepository? settingsRepository,
    WalletConfigRepository? walletConfigRepository,
    AccountV2Repository? accountV2Repository,
    AddressV2Repository? addressV2Repository,
    required this.importedAddressRepository,
    required this.analyticsService,
    required this.inMemoryKeyRepository,
    required this.encryptionService,
    mnemonicRepository,
  })  : _settingsRepository =
            settingsRepository ?? GetIt.I<SettingsRepository>(),
        _accountV2Repository =
            accountV2Repository ?? GetIt.I<AccountV2Repository>(),
        _mnemonicRepository =
            mnemonicRepository ?? GetIt.I<MnemonicRepository>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _addressV2Repository =
            addressV2Repository ?? GetIt.I<AddressV2Repository>(),
        super(const SessionState.initial());

  Future<GetSessionStateResponse> _getSessionState() async {
    final mnemonic = await _mnemonicRepository.get().run();

    if (mnemonic.isNone()) {
      return NoWallet();
    }

    final mnemonicKey = await inMemoryKeyRepository.getMnemonicKey().run();

    if (mnemonicKey.isNone()) {
      return LoggedOut();
    }

    final storedDeadlineString =
        await kvService.read(key: kInactivityDeadlineKey);

    if (storedDeadlineString != null && storedDeadlineString.isNotEmpty) {
      final storedDeadline = DateTime.tryParse(storedDeadlineString);
      if (storedDeadline != null) {
        // If the deadline has past, session is invali
        if (DateTime.now().isAfter(storedDeadline)) {
          // logout effects
          await inMemoryKeyRepository.delete();
          await kvService.delete(key: kInactivityDeadlineKey);

          return LoggedOut();
        }
      }
    }

    try {
      encryptionService.decryptWithKey(
          mnemonic.getOrThrow(), mnemonicKey.getOrThrow());

      return LoggedIn(decryptionKey: mnemonicKey.getOrThrow());
    } catch (e) {
      return LoggedOut();
    }
  }

  void initialize() async {
    emit(const SessionState.loading());

    try {
      final sessionState = await _getSessionState();

      switch (sessionState) {
        case NoWallet():
          emit(const SessionState.onboarding(Onboarding.initial()));
          return;
        case LoggedOut():
          emit(const SessionState.loggedOut());
          return;
        case LoggedIn(decryptionKey: var decryptionKey):
          WalletConfig walletConfig =
              await _walletConfigRepository.getCurrent();
          // TODO: we may need to handle to restore something here
          // analyticsService.trackAnonymousEvent('wallet_opened',
          //     properties: {'distinct_id': wallet.uuid});

          List<AccountV2> accounts =
              await _accountV2Repository.getByWalletConfig(
            walletConfigID: walletConfig.uuid,
          );

          String? currentAccountHash =
              cacheProvider.getString("current-account-hash");

          // TODO: save selected account index
          AccountV2 currentAccount = accounts.firstWhereOrNull(
                (account) => account.hash == currentAccountHash,
              ) ??
              accounts.first;

          // TODO: the arg here doesn't matter
          List<AddressV2> addresses =
              await _addressV2Repository.getByAccount(currentAccount);

          // if (addresses.isEmpty) {
          //   throw Exception("invariant: no addresses for this account");
          // }

          List<ImportedAddress> importedAddresses =
              await importedAddressRepository.getAll();

          emit(SessionState.success(SessionStateSuccess(
            redirect: true,
            // wallet: wallet,
            walletConfig: walletConfig,
            decryptionKey: decryptionKey,
            accounts: accounts,
            addresses: addresses,
            importedAddresses: importedAddresses,
            currentAccount: currentAccount,
          )));
          return;
      }
    } catch (error) {
      print(error);
      emit(SessionState.error(error.toString()));
    }
  }

  void initialized() {
    final state_ = state.when(
        initial: () => state,
        loading: () => state,
        error: (_) => state,
        loggedOut: () => state,
        onboarding: (_) => state,
        success: (stateInner) =>
            SessionState.success(stateInner.copyWith(redirect: false)));

    emit(state_);
  }

  void onNetworkChanged(Network network, [VoidCallback? cb]) async {
    WalletConfig current = await _walletConfigRepository.getCurrent();

    WalletConfig walletConfig = await _walletConfigRepository.findOrCreate(
      basePath: current.basePath,
      network: network,
      seedDerivation: current.seedDerivation,
    );

    await _settingsRepository.setWalletConfigID(walletConfig.uuid);

    List<AccountV2> accounts = await _accountV2Repository.getByWalletConfig(
      walletConfigID: walletConfig.uuid,
    );

    String? currentAccountHash =
        cacheProvider.getString("current-account-hash");

    // TODO: save selected account index
    AccountV2 currentAccount = accounts.firstWhereOrNull(
          (account) => account.hash == currentAccountHash,
        ) ??
        accounts.first;

    List<AddressV2> addresses =
        await _addressV2Repository.getByAccount(currentAccount);

    // TODO: need to think through imported addresses
    List<ImportedAddress> importedAddresses =
        await importedAddressRepository.getAll();
    SessionStateSuccess success = state.successOrThrow();

    emit(SessionState.success(success.copyWith(
      redirect: false, // not sure about this....
      // wallet: wallet,
      accounts: accounts,
      addresses: addresses,
      importedAddresses: importedAddresses, // TODO: imported addresses
      currentAccount: currentAccount,
    )));

    if (cb != null) {
      cb();
    }
  }

  void onWalletConfigChanged(WalletConfig config, [VoidCallback? cb]) async {

    print("onWalletConfigChanged ${config.uuid}");

    await _settingsRepository.setWalletConfigID(config.uuid);

    print("after onWalletConfigChanged ${config.uuid}");

    refresh();

    if (cb != null) {
      cb();
    }
  }

  void onAccountChanged(AccountV2 account, [VoidCallback? cb]) async {
    List<AddressV2> addresses =
        await _addressV2Repository.getByAccount(account);

    final current = state.successOrThrow();

    final next = current.copyWith(
      addresses: addresses,
      currentAccount: account,
    );

    // // TODO: it would be nice to not to have to do this effectful thing here
    cacheProvider.setString(
      "current-account-hash",
      account.hash,
    );

    emit(SessionState.success(next));

    if (cb != null) {
      cb();
    }
  }

  void onOnboarding() {
    emit(const SessionState.onboarding(Onboarding.initial()));
  }

  void onOnboardingCreate() {
    emit(const SessionState.onboarding(Onboarding.create()));
  }

  void onOnboardingImport() {
    emit(const SessionState.onboarding(Onboarding.import()));
  }

  void onOnboardingImportPK() {
    emit(const SessionState.onboarding(Onboarding.importPK()));
  }

  void onLogout() async {
    // logout effects
    await inMemoryKeyRepository.delete();
    await kvService.delete(key: kInactivityDeadlineKey);

    emit(const SessionState.loggedOut());
  }

  void refresh() async {
    // this seems to be called when you create a new account
    try {
      final mnemonic = await _mnemonicRepository.get().run();

      if (mnemonic.isNone()) {
        emit(const SessionState.onboarding(Onboarding.initial()));
        return;
      }

      WalletConfig walletConfig = await _walletConfigRepository.getCurrent();

      List<AccountV2> accounts = await _accountV2Repository.getByWalletConfig(
        walletConfigID: walletConfig.uuid,
      );

      String? currentAccountHash =
          cacheProvider.getString("current-account-hash");

      // TODO: save selected account index
      AccountV2 currentAccount = accounts.firstWhereOrNull(
            (account) => account.hash == currentAccountHash,
          ) ??
          accounts.first;
      // List<AccountV2> accounts = await _accountV2Repository.getAll();

      // if (accounts.isEmpty) {
      //   throw Exception("invariant: no accounts for this wallet");
      // }

      List<AddressV2> addresses =
          await _addressV2Repository.getByAccount(currentAccount);

      // if (addresses.isEmpty) {
      //   throw Exception("invariant: no addresses for this account");
      // }

      List<ImportedAddress> importedAddresses =
          await importedAddressRepository.getAll();

      SessionStateSuccess success = state.successOrThrow();

      emit(SessionState.success(success.copyWith(
        redirect: false, // not sure about this....
        // wallet: wallet,
        accounts: accounts,
        addresses: addresses,
        importedAddresses: importedAddresses,
        walletConfig: walletConfig,
      )));

      // cacheProvider.setString(
      //   "current-account-uuid",
      //   accounts.last.uuid,
      // );
    } catch (error) {
      emit(SessionState.error(error.toString()));
    }
  }
}

class SessionRepository {
  final SessionStateCubit sessionCubit;
  SessionState state;

  SessionRepository({required this.sessionCubit})
      : state = sessionCubit.state,
        super() {
    sessionCubit.stream.listen(_onSessionStateChanged);
  }

  void _onSessionStateChanged(SessionState newState) {
    state = newState;
  }

  SessionStateSuccess get success => sessionCubit.state.successOrThrow();
}
