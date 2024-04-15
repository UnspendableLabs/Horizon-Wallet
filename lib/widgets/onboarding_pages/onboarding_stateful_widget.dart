import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bloc/onboarding_bloc.dart';
import 'package:uniparty/widgets/onboarding_pages/create_wallet_flow.dart';
import 'package:uniparty/widgets/onboarding_pages/recover_wallet_flow.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    BlocProvider.of<OnboardingBloc>(context).add(InferOnboardingStepEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(listener: (context, state) {
      switch (state) {
        case OnboardingSuccess() when state.onboardingStep == OnboardingStep.done:
          Navigator.pushNamed(
            // ignore: use_build_context_synchronously
            context,
            AppRouter.walletPage,
          );
          break;
        default:
          break;
      }
    }, builder: (context, state) {
      return switch (state) {
        OnboardingInitial() || OnboardingLoading() => const Text('Loading...'),
        OnboardingSuccess(onboardingStep: final onboardingStep) => CreateOrRecover(), // TODO? match onboardingStep?
        OnboardingError() => throw ErrorDescription('Onboarding error'),
      };
    });
  }
}

class CreateOrRecover extends StatelessWidget {
  const CreateOrRecover({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[CreateWalletFlow(), RecoverWalletFlow()]);
  }
}
