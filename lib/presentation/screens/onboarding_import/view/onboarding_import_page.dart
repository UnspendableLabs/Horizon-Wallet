import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_shell.dart';
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
      child: const OnboardingImportPage(),
    );
  }
}

class OnboardingImportPage extends StatelessWidget {
  const OnboardingImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingImportBloc, OnboardingImportState>(
      listener: (context, state) {
        if (state.importState is ImportStateSuccess) {
          final session = context.read<SessionStateCubit>();
          session.initialize();
        }
      },
      builder: (context, state) {
        return OnboardingShell(
          steps: const [
            ChooseFormatStep(),
            SeedInputStep(),
            CreatePasswordStep(),
          ],
          onBack: () {
            final session = context.read<SessionStateCubit>();
            session.onOnboarding();
          },
          onNext: () {
            print('ON NEXT: ${state.currentStep}');
            if (state.currentStep == OnboardingImportStep.chooseFormat) {
              context.read<OnboardingImportBloc>().add(ImportFormatSubmitted());
            } else if (state.currentStep == OnboardingImportStep.inputSeed) {
              context
                  .read<OnboardingImportBloc>()
                  .add(MnemonicSubmittedted(mnemonic: state.mnemonic));
            }
            // This will be called when the final step is completed
            if (state.currentStep == OnboardingImportStep.inputPassword) {
              // Get password from the password prompt and submit
              // You'll need to add a way to access the password from the PasswordPrompt
              context.read<OnboardingImportBloc>().add(
                    ImportWallet(password: "password"), // Get actual password
                  );
            }
          },
          backButtonText: 'Cancel',
          nextButtonText:
              state.currentStep == OnboardingImportStep.inputPassword
                  ? 'Load Wallet'
                  : 'Continue',
          isLoading: state.importState is ImportStateLoading,
        );
      },
    );
  }
}

class ChooseFormatStep extends StatefulWidget {
  const ChooseFormatStep({super.key});

  @override
  State<ChooseFormatStep> createState() => _ChooseFormatStepState();
}

class _ChooseFormatStepState extends State<ChooseFormatStep> {
  String selectedFormat = ImportFormat.horizon.name;

  @override
  void initState() {
    super.initState();
    context.read<OnboardingImportBloc>().add(
          ImportFormatChanged(walletType: selectedFormat),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SelectableText("Choose the format of your seed phrase"),
        const SizedBox(height: 16),
        ImportFormatDropdown(
          onChanged: (String? newValue) {
            setState(() {
              selectedFormat = newValue!;
            });
            context.read<OnboardingImportBloc>().add(
                  ImportFormatChanged(walletType: selectedFormat),
                );
          },
          selectedFormat: selectedFormat,
        ),
      ],
    );
  }
}

class SeedInputStep extends StatelessWidget {
  const SeedInputStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
      builder: (context, state) {
        return SeedInputFields(
          mnemonicErrorState: state.mnemonicError,
        );
      },
    );
  }
}

class CreatePasswordStep extends StatelessWidget {
  const CreatePasswordStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
      builder: (context, state) {
        return PasswordPrompt(
          state: state,
          optionalErrorWidget: state.importState is ImportStateError
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, color: Colors.red),
                        const SizedBox(width: 4),
                        SelectableText(
                          (state.importState as ImportStateError).message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
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
    final scaffoldBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;
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
                        const Icon(Icons.info, color: Colors.red),
                        const SizedBox(width: 4),
                        SelectableText(
                          widget.mnemonicErrorState!,
                          style: const TextStyle(color: Colors.red),
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
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              label: Text(
                _showSeedPhrase ? 'Hide Seed Phrase' : 'Show Seed Phrase',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          !isSmallScreen && widget.mnemonicErrorState != null
              ? Column(
                  children: [
                    Align(
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
                            const Icon(Icons.info, color: Colors.red),
                            const SizedBox(width: 4),
                            SelectableText(
                              widget.mnemonicErrorState!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink(),
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
                color: isDarkMode ? Colors.white : Colors.black,
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
                      isDarkMode ? inputDarkBackground : inputLightBackground,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  hintText: 'Word ${index + 1}',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode ? inputDarkLabelColor : inputLightLabelColor,
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
                color: isDarkMode ? Colors.white : Colors.black,
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
                    isDarkMode ? inputDarkBackground : inputLightBackground,
                labelText: 'Word ${index + 1}',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color:
                      isDarkMode ? inputDarkLabelColor : inputLightLabelColor,
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
