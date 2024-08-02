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
    final lightBackgroundColor = isDarkMode ? const Color.fromRGBO(18, 18, 35, 1) : const Color.fromRGBO(0, 92, 193, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
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
                                      fontWeight: FontWeight.w600,
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
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 8, 8, 8),
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
                            OutlinedButton(
                              onPressed: () {
                                final shell = context.read<ShellStateCubit>();
                                shell.onOnboardingCreate();
                              },
                              child: const Text('Create a new wallet'),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton(
                              onPressed: () {
                                final shell = context.read<ShellStateCubit>();
                                shell.onOnboardingImport();
                              },
                              child: const Text('Import existing'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'logo-black.svg',
                    width: 45,
                    height: 45,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Horizon',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SvgPicture.asset(
                    'logo-3d.svg',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: lightBackgroundColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            final shell = context.read<ShellStateCubit>();
                            shell.onOnboardingCreate();
                          },
                          child: const Text('Create a new wallet'),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                            final shell = context.read<ShellStateCubit>();
                            shell.onOnboardingImport();
                          },
                          child: const Text('Import existing'),
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
