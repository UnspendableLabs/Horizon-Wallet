import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(
        logger: GetIt.I.get<Logger>(),
        walletRepository: GetIt.I.get<WalletRepository>(),
        accountRepository: GetIt.I.get<AccountRepository>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
      )..add(FetchOnboardingState()),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor =
        isDarkMode ? darkThemeBackgroundColor : lightThemeBackgroundColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 500;

    final pageContent = Scaffold(
      bottomNavigationBar: const Footer(),
      backgroundColor: backdropBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 30 : 16),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 4,
              child: Center(
                child: SizedBox(
                  width: 109,
                  height: 116,
                  child: Lottie.asset(
                    'logo_animation-gradient.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<OnboardingBloc, RemoteDataState<bool>>(
                    builder: (context, state) {
                      final isDisabled = state.maybeWhen(
                        error: (_) => true,
                        orElse: () => false,
                      );
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.maybeWhen(
                            error: (message) => true,
                            orElse: () => false,
                          )) ...[
                            SizedBox(
                              width:
                                  screenWidth > 768 ? screenWidth * 0.5 : null,
                              child: SelectableText(
                                state.maybeWhen(
                                  error: (message) => message,
                                  orElse: () => '',
                                ),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          SizedBox(
                            width: screenWidth > 768 ? screenWidth * 0.5 : null,
                            child: HorizonGradientButton(
                              onPressed: isDisabled
                                  ? null
                                  : () {
                                      final session =
                                          context.read<SessionStateCubit>();
                                      session.onOnboardingCreate();
                                    },
                              buttonText: 'Create a new wallet',
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: screenWidth > 768 ? screenWidth * 0.5 : null,
                            child: HorizonOutlinedButton(
                              isTransparent: true,
                              onPressed: isDisabled
                                  ? null
                                  : () {
                                      final session =
                                          context.read<SessionStateCubit>();
                                      session.onOnboardingImport();
                                    },
                              buttonText: 'Load seed phrase',
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!isWideScreen) {
      return pageContent;
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Container(
          width: 500,
          height: 812,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: pageContent,
          ),
        ),
      ),
    );
  }
}
