import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                              child: AnimatedLogo(isDarkMode: isDarkMode),
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
                                child: AnimatedLogo(isDarkMode: isDarkMode),
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
              SelectableText(
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

class AnimatedLogo extends StatefulWidget {
  final bool isDarkMode;

  const AnimatedLogo({super.key, required this.isDarkMode});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define color stops for both themes
  final List<Color> darkModeColors = [
    const Color(0xFFDFD9BF),
    const Color(0xFFEED09A),
    const Color(0xFFEEB395),
    const Color(0xFFE9A7AF),
    const Color(0xFF9B86D7),
    const Color(0xFF509FC0),
    const Color(0xFF7DC2BC),
  ];

  final List<Color> lightModeColors = [
    const Color(0xFF5D2B3B),
    const Color(0xFF2F1C46),
    const Color(0xFF1B1F38),
    const Color(0xFF0B102C),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          seconds: 6), // Increased duration for smoother transition
      vsync: this,
    );

    // Start the animation after a frame to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final colors = widget.isDarkMode ? darkModeColors : lightModeColors;
            final baseStops = widget.isDarkMode
                ? [0.003, 0.1276, 0.2572, 0.4068, 0.6062, 0.8155, 1.0]
                : [0.0, 0.326, 0.652, 0.9879];

            // Create interpolated stops based on animation value
            final shiftedStops = baseStops.map((stop) {
              // Use sine function to create smooth back-and-forth movement
              final shift = sin(_controller.value * pi) *
                  0.2; // Adjust 0.2 to control movement amount
              return (stop + shift).clamp(0.0, 1.0);
            }).toList();

            return LinearGradient(
              begin: const Alignment(-0.2, -1.0),
              end: const Alignment(0.2, 1.0),
              colors: colors,
              stops: shiftedStops,
              transform: widget.isDarkMode
                  ? const GradientRotation(170.88 * pi / 180)
                  : const GradientRotation(139.18 * pi / 180),
            ).createShader(bounds);
          },
          child: SvgPicture.asset(
            widget.isDarkMode
                ? 'assets/horizon-H-dark-mode.svg'
                : 'assets/horizon-H-light-mode.svg',
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
