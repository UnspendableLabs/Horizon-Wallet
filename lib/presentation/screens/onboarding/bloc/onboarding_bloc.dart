import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, RemoteDataState<bool>> {
  final Logger logger;
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;

  OnboardingBloc({
    required this.logger,
    required this.walletRepository,
    required this.accountRepository,
    required this.addressRepository,
  }) : super(const RemoteDataState.initial()) {
    on<FetchOnboardingState>(_onFetchOnboardingState);
  }

  Future<void> _onFetchOnboardingState(
    FetchOnboardingState event,
    Emitter<RemoteDataState<bool>> emit,
  ) async {
    try {
      emit(const RemoteDataState.loading());

      final currentWallet = await walletRepository.getCurrentWallet();
      if (currentWallet != null) {
        emit(const RemoteDataState.error(onboardingErrorMessage));
        return;
      }

      final accounts = await accountRepository.getAllAccounts();
      if (accounts.isNotEmpty) {
        emit(const RemoteDataState.error(onboardingErrorMessage));
        return;
      }

      final addresses = await addressRepository.getAll();
      if (addresses.isNotEmpty) {
        emit(const RemoteDataState.error(onboardingErrorMessage));
        return;
      }

      emit(const RemoteDataState.success(true));
    } catch (e) {
      logger.error('Error fetching onboarding state: $e');
    }
  }
}
