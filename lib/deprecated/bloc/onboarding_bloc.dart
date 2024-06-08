import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/deprecated/services/key_value_store_service.dart';

sealed class OnboardingEvent {}

class InferOnboardingStepEvent extends OnboardingEvent {}

enum OnboardingStep {
  unknown,
  createOrRestore,
  done,
}

sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

final class OnboardingSuccess extends OnboardingState {
  final OnboardingStep onboardingStep;
  const OnboardingSuccess({required this.onboardingStep});
}

final class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError({required this.message});
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<InferOnboardingStepEvent>((event, emit) async {
      emit(const OnboardingLoading());
      String? walletData = await GetIt.I.get<KeyValueService>().get(STORED_WALLET_DATA_KEY);
      if (walletData != null) {
        emit(const OnboardingSuccess(onboardingStep: OnboardingStep.done));
        return;
      }
      emit(const OnboardingSuccess(onboardingStep: OnboardingStep.createOrRestore));
    });
  }
}
