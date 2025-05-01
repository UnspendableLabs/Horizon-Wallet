import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:get_it/get_it.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, RemoteDataState<bool>> {
  final Logger logger;
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final MnemonicRepository _mnemonicRepository;

  OnboardingBloc(
      {required this.logger,
      required this.walletRepository,
      required this.accountRepository,
      required this.addressRepository,
      mnemonicRepository})
      : _mnemonicRepository =
            mnemonicRepository ?? GetIt.I<MnemonicRepository>(),
        super(const RemoteDataState.initial()) {
    on<FetchOnboardingState>(_onFetchOnboardingState);
  }

  Future<void> _onFetchOnboardingState(
    FetchOnboardingState event,
    Emitter<RemoteDataState<bool>> emit,
  ) async {
    try {
      emit(const RemoteDataState.loading());

      final mnemonic = await _mnemonicRepository.get();
      if (mnemonic.isSome()) {
        emit(const RemoteDataState.error(onboardingErrorMessage));
        return;
      }

      final accounts = await accountRepository.getAll();
      if (accounts.isNotEmpty) {
        emit(const RemoteDataState.error("no accounts biotch"));
        return;
      }
      //
      // final addresses = await addressRepository.getAll();
      // if (addresses.isNotEmpty) {
      //   emit(const RemoteDataState.error(onboardingErrorMessage));
      //   return;
      // }

      emit(const RemoteDataState.success(true));
    } catch (e) {
      logger.error('Error fetching onboarding state: $e');
      emit(const RemoteDataState.error(
          'An unexpected error occurred. Please try again.'));
    }
  }
}
