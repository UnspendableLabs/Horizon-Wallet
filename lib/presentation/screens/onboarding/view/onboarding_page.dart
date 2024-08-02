import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final backgroundColor = isDarkMode ? const Color.fromRGBO(24, 24, 47, 1) : const Color.fromRGBO(224, 239, 255, 1);
    final darkBackgroundColor = isDarkMode ? const Color.fromRGBO(30, 30, 56, 1) : const Color.fromRGBO(0, 92, 193, 1);
    final lightBackgroundColor = isDarkMode ? const Color.fromRGBO(18, 18, 35, 1) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                        color: darkBackgroundColor,
                        gradient: isDarkMode
                            ? RadialGradient(
                                center: Alignment.topRight,
                                radius: 1.0,
                                colors: [
                                  const Color.fromRGBO(35, 45, 77, 1),
                                  darkBackgroundColor,
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
                                    'logo-white.svg',
                                    width: 48,
                                    height: 48,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Horizon',
                                    style: TextStyle(
                                      color: Colors.white,
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
                        color: lightBackgroundColor,
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
                                  backgroundColor: darkBackgroundColor, // Background color
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button size
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), // Text style
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingCreate();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'CREATE A NEW WALLET',
                                    style:
                                        TextStyle(color: isDarkMode ? const Color.fromRGBO(108, 210, 255, 1) : Colors.white),
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
                                  backgroundColor: isDarkMode ? Colors.transparent : backgroundColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button size
                                  textStyle: TextStyle(
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
                                  child: Text('IMPORT EXISTING',
                                      style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.black)),
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
                padding: const EdgeInsets.all(8.0), // Added padding
                child: Container(
                  padding: const EdgeInsets.all(8.0), // Added padding
                  decoration: BoxDecoration(
                    color: darkBackgroundColor, // Set darkBackgroundColor
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
                              'logo-white.svg',
                              width: 48,
                              height: 48,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Horizon',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
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
                                  backgroundColor: isDarkMode ? const Color.fromRGBO(32, 42, 67, 1) : lightBackgroundColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingCreate();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'CREATE A NEW WALLET',
                                    style:
                                        TextStyle(color: isDarkMode ? const Color.fromRGBO(108, 210, 255, 1) : Colors.black),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                onPressed: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboardingImport();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'IMPORT EXISTING',
                                    style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.white),
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
