import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:get_it/get_it.dart';

// TODO: this will need to be updated to accomodate migration

class OnboardingBloc extends Bloc<OnboardingEvent, RemoteDataState<bool>> {
  final Logger logger;
  final MnemonicRepository _mnemonicRepository;

  OnboardingBloc({required this.logger, mnemonicRepository})
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

      await _mnemonicRepository.get();

      emit(const RemoteDataState.success(true));
    } catch (e) {
      logger.error('Error fetching onboarding state: $e');
      emit(const RemoteDataState.error(onboardingErrorMessage));
    }
  }
}
