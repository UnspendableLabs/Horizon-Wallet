import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_events.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

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
    final backdropBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;
    final leftSideBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;
    final rightSideBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;

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
                            ? null
                            : const RadialGradient(
                                center: Alignment.topRight,
                                radius: 1.0,
                                colors: [
                                  lightThemeBackgroundColorTopGradiant,
                                  lightThemeBackgroundColorTopGradiant
                                ],
                              ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50, width: 10),
                            Stack(
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
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 50,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        final colors = isDarkMode
                                            ? _getDarkModeColors()
                                            : _getLightModeColors();
                                        final stops = isDarkMode
                                            ? [
                                                0.003,
                                                0.1276,
                                                0.2572,
                                                0.4068,
                                                0.6062,
                                                0.8155,
                                                1.0
                                              ]
                                            : [0.0, 0.326, 0.652, 0.9879];

                                        return LinearGradient(
                                          begin: const Alignment(-0.2, -1.0),
                                          end: const Alignment(0.2, 1.0),
                                          colors: colors,
                                          stops: stops,
                                          transform: isDarkMode
                                              ? const GradientRotation(
                                                  170.88 * pi / 180)
                                              : const GradientRotation(
                                                  139.18 * pi / 180),
                                        ).createShader(bounds);
                                      },
                                      child: const Text(
                                        'Wallet',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 50,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 62,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: isDarkMode
                                            ? const [
                                                createButtonDarkGradient1,
                                                createButtonDarkGradient2,
                                                createButtonDarkGradient3,
                                                createButtonDarkGradient4,
                                              ]
                                            : const [
                                                createButtonLightGradient1,
                                                createButtonLightGradient2,
                                                createButtonLightGradient3,
                                                createButtonLightGradient4,
                                              ],
                                        stops: isDarkMode
                                            ? const [0.0, 0.325, 0.65, 1.0]
                                            : const [0.0, 0.326, 0.652, 0.9879],
                                        transform: isDarkMode
                                            ? null
                                            : const GradientRotation(
                                                139.18 * pi / 180),
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        padding: const EdgeInsets.all(20),
                                      ),
                                      onPressed: () {
                                        final session =
                                            context.read<SessionStateCubit>();
                                        session.onOnboardingCreate();
                                      },
                                      child: Text(
                                        'CREATE A NEW WALLET',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 62,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: isDarkMode
                                          ? importButtonDarkBackground
                                          : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        side: isDarkMode
                                            ? BorderSide.none
                                            : BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                    ),
                                    onPressed: () {
                                      final session =
                                          context.read<SessionStateCubit>();
                                      session.onOnboardingImport();
                                    },
                                    child: Text(
                                      'LOAD SEED PHRASE',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Column(
                        children: [
                          Text(
                            'Horizon',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 32.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              final colors = isDarkMode
                                  ? _getDarkModeColors()
                                  : _getLightModeColors();
                              final stops = isDarkMode
                                  ? [
                                      0.003,
                                      0.1276,
                                      0.2572,
                                      0.4068,
                                      0.6062,
                                      0.8155,
                                      1.0
                                    ]
                                  : [0.0, 0.326, 0.652, 0.9879];

                              return LinearGradient(
                                begin: const Alignment(-0.2, -1.0),
                                end: const Alignment(0.2, 1.0),
                                colors: colors,
                                stops: stops,
                                transform: isDarkMode
                                    ? const GradientRotation(170.88 * pi / 180)
                                    : const GradientRotation(139.18 * pi / 180),
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Wallet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      SizedBox(
                        height: 116,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 109 / 116,
                            child: AnimatedLogo(isDarkMode: isDarkMode),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 62,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: isDarkMode
                                      ? const [
                                          createButtonDarkGradient1,
                                          createButtonDarkGradient2,
                                          createButtonDarkGradient3,
                                          createButtonDarkGradient4,
                                        ]
                                      : const [
                                          createButtonLightGradient1,
                                          createButtonLightGradient2,
                                          createButtonLightGradient3,
                                          createButtonLightGradient4,
                                        ],
                                  stops: isDarkMode
                                      ? const [0.0, 0.325, 0.65, 1.0]
                                      : const [0.0, 0.326, 0.652, 0.9879],
                                  transform: isDarkMode
                                      ? null
                                      : const GradientRotation(
                                          139.18 * pi / 180),
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                ),
                                onPressed: () {
                                  final session =
                                      context.read<SessionStateCubit>();
                                  session.onOnboardingCreate();
                                },
                                child: Text(
                                  'CREATE A NEW WALLET',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 62,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: isDarkMode
                                    ? importButtonDarkBackground
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: isDarkMode
                                      ? BorderSide.none
                                      : BorderSide(
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                ),
                                padding: const EdgeInsets.all(20),
                              ),
                              onPressed: () {
                                final session =
                                    context.read<SessionStateCubit>();
                                session.onOnboardingImport();
                              },
                              child: Text(
                                'LOAD SEED PHRASE',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<Color> _getDarkModeColors() => const [
        Color(0xFF7DC2BC),
        Color(0xFF509FC0),
        Color(0xFF9B86D7),
        Color(0xFFE9A7AF),
        Color(0xFFEEB395),
        Color(0xFFEED09A),
        Color(0xFFDFD9BF),
      ];

  List<Color> _getLightModeColors() => const [
        Color(0xFF5D2B3B),
        Color(0xFF2F1C46),
        Color(0xFF1B1F38),
        Color(0xFF0B102C),
      ];
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
