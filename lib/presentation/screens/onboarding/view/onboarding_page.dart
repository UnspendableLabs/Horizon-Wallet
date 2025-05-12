import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/utils/app_icons.dart';
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

  Widget buildAnimationAsset(BuildContext context) {
    final Config config = GetIt.I<Config>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (config.isWebExtension) {
      final appBarAsset =
          isDarkMode ? 'app-bar-H-dark-mode.png' : 'app-bar-H-light-mode.png';
      return Image.asset(
        'assets/$appBarAsset',
        fit: BoxFit.contain,
      );
    }
    final animationAsset = isDarkMode
        ? 'logo_animation-gradient-dark.json'
        : 'logo_animation-gradient-light.json';
    return Lottie.asset(
      kDebugMode ? animationAsset : 'assets/$animationAsset',
      fit: BoxFit.contain,
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDarkMode) {

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (isDarkMode) {
                      context.read<ThemeBloc>().add(ThemeToggled());
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AppIcons.sunIcon(
                      context: context,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (!isDarkMode) {
                      context.read<ThemeBloc>().add(ThemeToggled());
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AppIcons.moonIcon(
                      context: context,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 500;

    final pageContent = Scaffold(
      bottomNavigationBar: const Footer(),
      body: Column(
        children: [
          _buildThemeToggle(context, isDarkMode),
          Expanded(
            child: Padding(
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
                        child: buildAnimationAsset(context),
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
                                    width: screenWidth > 500
                                        ? screenWidth * 0.5
                                        : null,
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
                                  width: double.infinity,
                                  child: HorizonButton(
                                    disabled: isDisabled,
                                    variant: ButtonVariant.gradient,
                                    onPressed: () {
                                      final session =
                                          context.read<SessionStateCubit>();
                                      session.onOnboardingCreate();
                                    },
                                    child: TextButtonContent(
                                      value: 'Create a new wallet',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: HorizonButton(
                                    variant: ButtonVariant.black,
                                    disabled: isDisabled,
                                    onPressed: () {
                                      final session = context
                                          .read<SessionStateCubit>();
                                      session.onOnboardingImport();
                                    },
                                    child: TextButtonContent(
                                      value: 'Load seed phrase',
                                    ),
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
          ),
        ],
      ),
    );

    if (!isWideScreen) {
      return pageContent;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
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
