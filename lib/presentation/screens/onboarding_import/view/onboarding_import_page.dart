import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_app_bar.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

class OnboardingImportPageWrapper extends StatelessWidget {
  const OnboardingImportPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingImportBloc(
              mnemonicService: GetIt.I<MnemonicService>(),
              importWalletUseCase: GetIt.I<ImportWalletUseCase>(),
              walletService: GetIt.I<WalletService>(),
            ),
        child: const OnboardingImportPage());
  }
}

class OnboardingImportPage extends StatefulWidget {
  const OnboardingImportPage({super.key});
  @override
  OnboardingImportPageState createState() => OnboardingImportPageState();
}

class OnboardingImportPageState extends State<OnboardingImportPage> {
  final TextEditingController _seedPhraseController =
      TextEditingController(text: "");

  @override
  dispose() {
    _seedPhraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 768;
    final EdgeInsetsGeometry padding = isSmallScreen
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.symmetric(
            horizontal: screenSize.width / 8,
            vertical: screenSize.height / 16,
          );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : lightBlueLightTheme;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;

    return Container(
      decoration: BoxDecoration(
        color: backdropBackgroundColor,
      ),
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(12),
        child: Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          body: BlocListener<OnboardingImportBloc, OnboardingImportState>(
            listener: (context, state) async {
              if (state.importState is ImportStateSuccess) {
                final session = context.read<SessionStateCubit>();
                // reload session to trigger redirect
                session.initialize();
              }
            },
            child: BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
                builder: (context, state) {
              print('STATE CURRENT STEP: ${state.currentStep}');
              return Container(
                decoration: BoxDecoration(
                  color: scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Scaffold(
                  backgroundColor: scaffoldBackgroundColor,
                  appBar: OnboardingAppBar(
                    isDarkMode: isDarkMode,
                    isSmallScreenWidth: isSmallScreen,
                    isSmallScreenHeight: isSmallScreen,
                    scaffoldBackgroundColor: scaffoldBackgroundColor,
                  ),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          Flexible(
                              child: switch (state.currentStep) {
                            OnboardingImportStep.chooseFormat =>
                              const ChooseFormat(),
                            OnboardingImportStep.inputSeed => SeedInputFields(
                                mnemonicErrorState: state.mnemonicError,
                              ),
                            OnboardingImportStep.inputPassword =>
                              PasswordPrompt(
                                  state: state,
                                  onPressedBack: () {
                                    final session =
                                        context.read<SessionStateCubit>();
                                    session.onOnboarding();
                                  },
                                  onPressedContinue: (password) {
                                    context
                                        .read<OnboardingImportBloc>()
                                        .add(ImportWallet(password: password));
                                  },
                                  backButtonText: 'CANCEL',
                                  continueButtonText: 'LOGIN',
                                  optionalErrorWidget: state.importState
                                          is ImportStateError
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: redErrorTextTransparent,
                                              borderRadius:
                                                  BorderRadius.circular(40.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.info,
                                                    color: redErrorText),
                                                const SizedBox(width: 4),
                                                SelectableText(
                                                  state.importState.message,
                                                  style: const TextStyle(
                                                      color: redErrorText),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : null),
                            _ => const SelectableText(
                                "invariant: invalid onboarding step"),
                          }),
                        ],
                      ),
                      if (state.importState is ImportStateLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ChooseFormat extends StatefulWidget {
  const ChooseFormat({super.key});
  @override
  State<ChooseFormat> createState() => _ChooseFormatState();
}

class _ChooseFormatState extends State<ChooseFormat> {
  String selectedFormat = ImportFormat.horizon.name;

  @override
  void initState() {
    super.initState();
    context
        .read<OnboardingImportBloc>()
        .add(ImportFormatChanged(walletType: selectedFormat));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    return Column(
      children: [
        const SelectableText("Choose the format of your seed phrase"),
        const SizedBox(height: 16),
        if (isSmallScreen) const SizedBox(height: 16),
        ImportFormatDropdown(
          onChanged: (String? newValue) {
            setState(() {
              selectedFormat = newValue!;
            });
            context
                .read<OnboardingImportBloc>()
                .add(ImportFormatChanged(walletType: selectedFormat));
          },
          selectedFormat: selectedFormat,
        ),
        const SizedBox(height: 16),
        BackContinueButtons(
          isDarkMode: isDarkMode,
          isSmallScreenWidth: isSmallScreen,
          backButtonText: 'CANCEL',
          continueButtonText: 'CONTINUE',
          onPressedBack: () {
            final session = context.read<SessionStateCubit>();
            session.onOnboarding();
          },
          onPressedContinue: () {
            context.read<OnboardingImportBloc>().add(ImportFormatSubmitted());
          },
        ),
      ],
    );
  }
}

class SeedInputFields extends StatefulWidget {
  final String? mnemonicErrorState;
  const SeedInputFields({super.key, required this.mnemonicErrorState});
  @override
  State<SeedInputFields> createState() => _SeedInputFieldsState();
}

class _SeedInputFieldsState extends State<SeedInputFields> {
  List<TextEditingController> controllers =
      List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  bool _showSeedPhrase = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          handleTabNavigation(i);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          isSmallScreen && widget.mnemonicErrorState != null
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: redErrorTextTransparent,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, color: redErrorText),
                        const SizedBox(width: 4),
                        SelectableText(
                          widget.mnemonicErrorState!,
                          style: const TextStyle(color: redErrorText),
                        ),
                      ],
                    ),
                  ),
                )
              : const Text(""),
          Expanded(
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: buildInputFields(isSmallScreen, isDarkMode),
                  )
                : buildInputFields(isSmallScreen, isDarkMode),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showSeedPhrase = !_showSeedPhrase;
                });
              },
              icon: Icon(
                _showSeedPhrase ? Icons.visibility_off : Icons.visibility,
                color: isDarkMode ? mainTextWhite : mainTextBlack,
              ),
              label: Text(
                _showSeedPhrase ? 'Hide Seed Phrase' : 'Show Seed Phrase',
                style: TextStyle(
                  color: isDarkMode ? mainTextWhite : mainTextBlack,
                ),
              ),
            ),
          ),
          BackContinueButtons(
            isDarkMode: isDarkMode,
            isSmallScreenWidth: isSmallScreen,
            backButtonText: 'CANCEL',
            continueButtonText: 'CONTINUE',
            onPressedBack: () {
              final session = context.read<SessionStateCubit>();
              session.onOnboarding();
            },
            onPressedContinue: () {
              context.read<OnboardingImportBloc>().add(MnemonicSubmitted(
                    mnemonic: controllers
                        .map((controller) => controller.text)
                        .join(' ')
                        .trim(),
                  ));
            },
            errorWidget: !isSmallScreen && widget.mnemonicErrorState != null
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: redErrorTextTransparent,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info, color: redErrorText),
                          const SizedBox(width: 4),
                          SelectableText(
                            widget.mnemonicErrorState!,
                            style: const TextStyle(color: redErrorText),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildInputFields(bool isSmallScreen, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isSmallScreen) {
          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(6,
                        (index) => buildCompactInputField(index, isDarkMode)),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: List.generate(
                        6,
                        (index) =>
                            buildCompactInputField(index + 6, isDarkMode)),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Existing code for larger screens
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(2, (columnIndex) {
                        return Expanded(
                          child: Column(
                            children: List.generate(6, (rowIndex) {
                              int index = columnIndex * 6 + rowIndex;
                              return buildInputField(index, isDarkMode);
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildCompactInputField(int index, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              "${index + 1}.",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isDarkMode ? mainTextWhite : mainTextBlack,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                obscureText: !_showSeedPhrase,
                onChanged: (value) => handleInput(value, index),
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      isDarkMode ? darkThemeInputColor : lightThemeInputColor,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  hintText: 'Word ${index + 1}',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? darkThemeInputLabelColor
                        : lightThemeInputLabelColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(int index, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              "${index + 1}. ",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: isDarkMode ? mainTextWhite : mainTextBlack,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              obscureText: !_showSeedPhrase,
              onChanged: (value) => handleInput(value, index),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDarkMode ? darkThemeInputColor : lightThemeInputColor,
                labelText: 'Word ${index + 1}',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: isDarkMode
                      ? darkThemeInputLabelColor
                      : lightThemeInputLabelColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void handleInput(String value, int index) {
    var words = value.split(RegExp(r'\s+'));
    if (words.length > 1 && index < 11) {
      for (int i = 0; i < words.length && (index + i) < 12; i++) {
        controllers[index + i].text = words[i];
        if ((index + i + 1) < 12) {
          FocusScope.of(context).requestFocus(focusNodes[index + i + 1]);
        }
      }
    }
    updateMnemonic();
  }

  void handleTabNavigation(int index) {
    int nextIndex;
    if (index % 6 == 5) {
      // Move to the next column
      nextIndex = index + 7 - 6;
    } else {
      // Move down the current column
      nextIndex = index + 1;
    }

    if (nextIndex < 12) {
      FocusScope.of(context).requestFocus(focusNodes[nextIndex]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void updateMnemonic() {
    String mnemonic =
        controllers.map((controller) => controller.text).join(' ').trim();
    context
        .read<OnboardingImportBloc>()
        .add(MnemonicChanged(mnemonic: mnemonic));
  }
}
