import 'dart:math' show pi, sin;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

// Move these to the top of the file, outside of any class
const List<Color> darkModeColors = [
  Color(0xFFDFD9BF), // Beige
  Color(0xFFEED09A), // Light orange
  Color(0xFFEEB395), // Peach
  Color(0xFFE9A7AF), // Pink
  Color(0xFF9B86D7), // Purple
];

const List<Color> lightModeColors = [
  Color(0xFF5D2B3B),
  Color(0xFF2F1C46),
  Color(0xFF1B1F38),
  Color(0xFF0B102C),
];

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
                                    HorizonTitle(
                                      isDarkMode: isDarkMode,
                                      fontSize: 50,
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
                                      SelectableText(
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
                                      const SizedBox(height: 20),
                                    ],
                                    HorizonGradientButton(
                                      onPressed: isDisabled
                                          ? null
                                          : () {
                                              final session = context
                                                  .read<SessionStateCubit>();
                                              session.onOnboardingCreate();
                                            },
                                      buttonText: 'CREATE A NEW WALLET',
                                      isDarkMode: isDarkMode,
                                    ),
                                    const SizedBox(height: 10),
                                    HorizonOutlinedButton(
                                      onPressed: isDisabled
                                          ? null
                                          : () {
                                              final session = context
                                                  .read<SessionStateCubit>();
                                              session.onOnboardingImport();
                                            },
                                      buttonText: 'LOAD SEED PHRASE',
                                      isDarkMode: isDarkMode,
                                    ),
                                  ],
                                );
                              },
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
            // Mobile layout
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Spacer(flex: 1), // Add space at top
                  // Logo section - increased size
                  Expanded(
                    flex: 4, // Increased flex to make logo section bigger
                    child: Center(
                      child: SizedBox(
                        width: 109,
                        height: 116,
                        child: AnimatedLogo(isDarkMode: isDarkMode),
                      ),
                    ),
                  ),
                  const Spacer(
                      flex: 1), // Add flexible space between logo and buttons
                  // Buttons section - moved closer to bottom
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 32), // Add padding at bottom
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Changed from MainAxisAlignment.center
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
                                  SelectableText(
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
                                  const SizedBox(height: 20),
                                ],
                                HorizonGradientButton(
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
                                const SizedBox(height: 10),
                                HorizonOutlinedButton(
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
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
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
                ? [0.003, 0.1276, 0.2572, 0.4068, 0.6062]
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

class HorizonTitle extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;

  const HorizonTitle({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<ImageShader?>(
          future: _createShaderFromImage(context, constraints),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error loading shader: ${snapshot.error}');
            }

            return ShaderMask(
              shaderCallback: (bounds) {
                if (isDarkMode && snapshot.hasData && snapshot.data != null) {
                  return snapshot.data!;
                }
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    createButtonLightGradient1,
                    createButtonLightGradient2,
                    createButtonLightGradient3,
                    createButtonLightGradient4,
                  ],
                  stops: [0.0, 0.326, 0.652, 0.9879],
                  transform: GradientRotation(139.18 * pi / 180),
                ).createShader(bounds);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Horizon ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<ui.Image?> _loadImage(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  Future<ImageShader?> _createShaderFromImage(
      BuildContext context, BoxConstraints constraints) async {
    final image = await _loadImage('rainbow-gradiant.png');
    if (image == null) return null;

    // Calculate the total width needed for both text elements
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Horizon ',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'Wallet',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final matrix4 = Matrix4.identity();
    // Scale the image to match the text width and height
    matrix4.scale(
      textPainter.width / image.width,
      textPainter.height / image.height,
    );

    return ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      matrix4.storage,
    );
  }
}
