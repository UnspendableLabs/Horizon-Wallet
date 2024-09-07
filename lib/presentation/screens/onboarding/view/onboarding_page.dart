import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/common/footer.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  bool _isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
    });
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                Positioned(
                                  top: 95,
                                  right: -50,
                                  child: Text(
                                    'BETA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      leftSideBackgroundColor, // Background color
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
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
                                        horizontal: 32, vertical: 16),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    )),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingImport();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'IMPORT SEED',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? mainTextGrey
                                            : mainTextBlack),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              child: Column(
                                children: [
                                  if (_isMenuExpanded)
                                    ElevatedButton(
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
                                        ),
                                      ),
                                      onPressed: () {
                                        final shell =
                                            context.read<ShellStateCubit>();
                                        shell.onOnboardingImportPK();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'IMPORT PRIVATE KEY',
                                          style: TextStyle(
                                              color: isDarkMode
                                                  ? mainTextGrey
                                                  : mainTextBlack),
                                        ),
                                      ),
                                    ),
                                  if (_isMenuExpanded)
                                    const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      overlayColor: noBackgroundColor,
                                      elevation: 0,
                                      backgroundColor: noBackgroundColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      shape: const CircleBorder(
                                        side: BorderSide(
                                            color: mainTextGreyTransparent),
                                      ),
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: _toggleMenu,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(
                                        _isMenuExpanded
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: mainTextGreyTransparent,
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
                      const Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none, // Ensure ALPHA is not clipped
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 50),
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
                          Positioned(
                            top: 145, // Adjust this value to move ALPHA down
                            right:
                                -50, // Adjust this value to position ALPHA correctly
                            child: Text(
                              'BETA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/logo-blue-3d.png',
                          width: 900,
                          height: 900,
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
                                      fontWeight: FontWeight.w700),
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
                                      fontWeight: FontWeight.w700),
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingImport();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'IMPORT SEED PHRASE',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? mainTextGrey
                                            : mainTextWhite),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              child: Column(
                                children: [
                                  if (_isMenuExpanded)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        overlayColor: Colors.transparent,
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 16),
                                        textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () {
                                        final shell =
                                            context.read<ShellStateCubit>();
                                        shell.onOnboardingImportPK();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'IMPORT PRIVATE KEY',
                                          style: TextStyle(
                                              color: isDarkMode
                                                  ? mainTextGrey
                                                  : mainTextWhite),
                                        ),
                                      ),
                                    ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      overlayColor: noBackgroundColor,
                                      elevation: 0,
                                      backgroundColor: noBackgroundColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      shape: const CircleBorder(
                                        side: BorderSide(
                                            color: mainTextGreyTransparent),
                                      ),
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: _toggleMenu,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(
                                        _isMenuExpanded
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: mainTextGreyTransparent,
                                      ),
                                    ),
                                  ),
                                ],
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
