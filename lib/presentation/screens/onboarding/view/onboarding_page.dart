import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

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
        isDarkMode ? mediumNavyDarkTheme : lightBlueLightTheme;
    final leftSideBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : royalBlueLightTheme;
    final rightSideBackgroundColor =
        isDarkMode ? darkNavyDarkTheme : whiteLightTheme;

    return Scaffold(
      bottomNavigationBar: const Footer(),
      backgroundColor: backdropBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: leftSideBackgroundColor,
                        gradient: isDarkMode
                            ? RadialGradient(
                                center: Alignment.topRight,
                                radius: 1.0,
                                colors: [
                                  blueDarkThemeGradiantColor,
                                  leftSideBackgroundColor,
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50, width: 10),
                            const Stack(
                              alignment: Alignment.center,
                              clipBehavior:
                                  Clip.none, // Ensure ALPHA is not clipped
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Horizon',
                                      style: TextStyle(
                                        color: mainTextWhite,
                                        fontSize: 50,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Wallet',
                                      style: TextStyle(
                                        color: neonBlueDarkTheme,
                                        fontSize: 50,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: Image.asset(
                                'assets/logo-blue-3d.png',
                                width: 800,
                                height: 800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: rightSideBackgroundColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButtons(context, isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: leftSideBackgroundColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Horizon',
                                  style: TextStyle(
                                    color: mainTextWhite,
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Wallet',
                                  style: TextStyle(
                                    color: neonBlueDarkTheme,
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Image.asset(
                                  'assets/logo-blue-3d.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildButtons(context, isDarkMode),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isDarkMode) {
    // Get the colors again since we're in a different scope
    final backdropBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : lightBlueLightTheme;
    final leftSideBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : royalBlueLightTheme;

    return BlocBuilder<OnboardingBloc, RemoteDataState<bool>>(
      builder: (context, state) {
        final isDisabled = state.maybeWhen(
          error: (_) => true,
          orElse: () => false,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.maybeWhen(
              error: (message) => true,
              orElse: () => false,
            )) ...[
              Text(
                state.maybeWhen(
                  error: (message) => message,
                  orElse: () => '',
                ),
                style: const TextStyle(
                  color: redErrorText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: leftSideBackgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: isDisabled
                    ? null
                    : () {
                        final session = context.read<SessionStateCubit>();
                        session.onOnboardingCreate();
                      },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'CREATE A NEW WALLET',
                    style: TextStyle(
                        color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    overlayColor: noBackgroundColor,
                    elevation: 0,
                    backgroundColor: isDarkMode
                        ? noBackgroundColor
                        : backdropBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                onPressed: isDisabled
                    ? null
                    : () {
                        final session = context.read<SessionStateCubit>();
                        session.onOnboardingImport();
                      },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'LOAD SEED PHRASE',
                    style: TextStyle(
                        color: isDarkMode ? mainTextGrey : mainTextBlack),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
