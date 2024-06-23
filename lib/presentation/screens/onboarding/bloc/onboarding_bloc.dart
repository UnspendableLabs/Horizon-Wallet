import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboard_state.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_event.dart';
import 'package:logger/logger.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final mnmonicService = GetIt.I<MnemonicService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();

  OnboardingBloc() : super(OnboardingInitialState()) {
    final Logger logger = Logger();

    on<OnboardingInitial>((event, emit) async {
      logger.d('OnboardingInitial event started');

      Wallet? wallet = await walletRepository.getCurrentWallet();
      if (wallet != null) {
        List<Account> accounts = await accountRepository.getAccountsByWalletUuid(wallet.uuid);
        if (accounts.isNotEmpty) {
          logger.d('Accounts exist; send to dashboard');
          return emit(OnboardingSuccessState());
        }
      }

      logger.d('No wallet or accounts found; send to create wallet');
    });
  }
}
