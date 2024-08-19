import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

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
                            SizedBox(
                              height: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/logo-white.svg',
                                    width: 48,
                                    height: 48,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Horizon',
                                    style: TextStyle(
                                      color: mainTextWhite,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // TODO: 3d image here
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
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      leftSideBackgroundColor, // Background color
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16), // Button size
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w500), // Text style
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingCreate();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'CREATE A NEW WALLET',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? neonBlueDarkTheme
                                            : mainTextWhite),
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
                                      horizontal: 32,
                                      vertical: 16), // Button size
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ), // Text style
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingImport();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('IMPORT SEED',
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? mainTextGrey
                                              : mainTextBlack)),
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
                                      horizontal: 32,
                                      vertical: 16), // Button size
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ), // Text style
                                ),
                                onPressed: () {
                                  // final shell = context.read<ShellStateCubit>();
                                  // shell.onOnboardingImport();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('IMPORT PRIVATE KEY',
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? mainTextGrey
                                              : mainTextBlack)),
                                ),

                              ),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: leftSideBackgroundColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/logo-white.svg',
                              width: 48,
                              height: 48,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Horizon',
                              style: TextStyle(
                                color: mainTextWhite,
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isDarkMode
                                      ? navyDarkTheme
                                      : whiteLightTheme,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingCreate();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'CREATE A NEW WALLET',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? neonBlueDarkTheme
                                            : mainTextBlack),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingImport();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'IMPORT EXISTING',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? mainTextGrey
                                            : mainTextWhite),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
