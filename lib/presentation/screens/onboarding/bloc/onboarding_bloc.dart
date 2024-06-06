import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboard_state.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_event.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final mnmonicService = GetIt.I<MnemonicService>();
  final addressService = GetIt.I<AddressService>();
  final walletService = GetIt.I<WalletService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();

  OnboardingBloc() : super(OnboardingInitialState()) {
    on<OnboardingInitial>((event, emit) async {
      final account = await accountRepository.getCurrentAccount();
      if (account != null) {
        final wallets = await walletRepository.getWalletsByAccountUuid(account.uuid!);
        if (wallets.isNotEmpty) {
          emit(OnboardingSuccessState());
        }
      }
    });
  }
}
