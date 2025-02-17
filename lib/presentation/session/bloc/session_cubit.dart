import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/common/constants.dart';

import './session_state.dart';

sealed class GetSessionStateResponse {}

class LoggedIn extends GetSessionStateResponse {
  Wallet wallet;
  String decryptionKey;

  LoggedIn({required this.wallet, required this.decryptionKey});
}

class LoggedOut extends GetSessionStateResponse {}

class NoWallet extends GetSessionStateResponse {}

class SessionStateCubit extends Cubit<SessionState> {
  CacheProvider cacheProvider;
  WalletRepository walletRepository;
  AccountRepository accountRepository;
  AddressRepository addressRepository;
  ImportedAddressRepository importedAddressRepository;
  AnalyticsService analyticsService;
  InMemoryKeyRepository inMemoryKeyRepository;
  final EncryptionService encryptionService;
  final SecureKVService kvService;

  SessionStateCubit(
      {required this.kvService,
      required this.cacheProvider,
      required this.walletRepository,
      required this.accountRepository,
      required this.addressRepository,
      required this.importedAddressRepository,
      required this.analyticsService,
      required this.inMemoryKeyRepository,
      required this.encryptionService})
      : super(const SessionState.initial());

  Future<GetSessionStateResponse> _getSessionState() async {
    Wallet? wallet = await walletRepository.getCurrentWallet();

    if (wallet == null) {
      return NoWallet();
    }

    final decryptionKey = await inMemoryKeyRepository.get();

    if (decryptionKey == null) {
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
      encryptionService.decryptWithKey(wallet.encryptedPrivKey, decryptionKey);

      return LoggedIn(wallet: wallet, decryptionKey: decryptionKey);
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
        case LoggedIn(wallet: var wallet, decryptionKey: var decryptionKey):
          analyticsService.trackAnonymousEvent('wallet_opened',
              properties: {'distinct_id': wallet.uuid});

          List<Account> accounts =
              await accountRepository.getAccountsByWalletUuid(wallet.uuid);

          if (accounts.isEmpty) {
            throw Exception("invariant: no accounts for this wallet");
          }

          List<Address> addresses = await addressRepository.getAll();

          if (addresses.isEmpty) {
            throw Exception("invariant: no addresses for this account");
          }

          List<ImportedAddress> importedAddresses =
              await importedAddressRepository.getAll();

          emit(SessionState.success(SessionStateSuccess(
            redirect: true,
            wallet: wallet,
            decryptionKey: decryptionKey,
            accounts: accounts,
            addresses: addresses,
            importedAddresses: importedAddresses,
          )));
          return;
      }
    } catch (error) {
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
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        emit(const SessionState.onboarding(Onboarding.initial()));
        return;
      }

      List<Account> accounts =
          await accountRepository.getAccountsByWalletUuid(wallet.uuid);

      if (accounts.isEmpty) {
        throw Exception("invariant: no accounts for this wallet");
      }

      List<Address> addresses = await addressRepository.getAll();

      if (addresses.isEmpty) {
        throw Exception("invariant: no addresses for this account");
      }

      List<ImportedAddress> importedAddresses =
          await importedAddressRepository.getAll();

      SessionStateSuccess success = state.successOrThrow();

      emit(SessionState.success(success.copyWith(
        redirect: true,
        wallet: wallet,
        accounts: accounts,
        addresses: addresses,
        importedAddresses: importedAddresses,
      )));
    } catch (error) {
      emit(SessionState.error(error.toString()));
    }
  }
}
