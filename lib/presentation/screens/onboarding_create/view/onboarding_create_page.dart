// ignore_for_file: type_literal_in_constant_pattern

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_shell.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

class NumberedWordGrid extends StatelessWidget {
  final String text;
  final int rowsPerColumn;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets itemMargin;

  const NumberedWordGrid({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.rowsPerColumn = 6,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.itemMargin =
        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    List<String> words = text.split(' ');
    int totalWords = words.length;
    int columnCount = (totalWords / rowsPerColumn).ceil();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columnCount, (columnIndex) {
        int startIndex = columnIndex * rowsPerColumn;
        int endIndex = min((columnIndex + 1) * rowsPerColumn, totalWords);
        List<String> columnWords = words.sublist(startIndex, endIndex);

        return Expanded(
          child: _buildColumn(columnWords, startIndex: startIndex + 1),
        );
      }),
    );
  }

  Widget _buildColumn(List<String> words, {required int startIndex}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: words.asMap().entries.map((entry) {
        int index = entry.key + startIndex;
        String word = entry.value;
        return Container(
          margin: itemMargin,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '$index. $word',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class OnboardingCreatePageWrapper extends StatelessWidget {
  const OnboardingCreatePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCreateBloc(
        mnmonicService: GetIt.I<MnemonicService>(),
        walletService: GetIt.I<WalletService>(),
        importWalletUseCase: GetIt.I<ImportWalletUseCase>(),
      )..add(MnemonicGenerated()),
      child: const OnboardingCreatePage(),
    );
  }
}

class OnboardingCreatePage extends StatefulWidget {
  const OnboardingCreatePage({super.key});

  @override
  State<OnboardingCreatePage> createState() => _OnboardingCreatePageState();
}

class _OnboardingCreatePageState extends State<OnboardingCreatePage> {
  final _passwordStepKey = GlobalKey<PasswordPromptState>();
  final _confirmStepKey = GlobalKey<_SeedInputFieldsState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCreateBloc, OnboardingCreateState>(
      listener: (context, state) {
        state.createState.maybeWhen(
          success: () {
            final session = context.read<SessionStateCubit>();
            session.initialize();
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final createStateError = state.createState.maybeWhen(
          error: (message) => message,
          orElse: () => null,
        );
        final isLoading = state.createState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return OnboardingShell(
          steps: [
            const ShowMnemonicStep(),
            SeedInputFields(
              key: _confirmStepKey,
              mnemonicErrorState: state.mnemonicError,
              onInputChanged: () => setState(() {
                /* trigger rebuild */
              }),
            ),
            PasswordPrompt(
              key: _passwordStepKey,
              state: state,
              optionalErrorWidget: createStateError != null
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
                              createStateError,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
          ],
          onBack: () {
            if (state.currentStep == OnboardingCreateStep.showMnemonic) {
              final session = context.read<SessionStateCubit>();
              session.onOnboarding();
            } else {
              // Clear password state if we're going back from password step
              if (state.currentStep == OnboardingCreateStep.createPassword) {
                _passwordStepKey.currentState?.clearPassword();
                context
                    .read<OnboardingCreateBloc>()
                    .add(ConfirmMnemonicBackPressed());
              }
              // Clear mnemonic errors if going back from confirm step
              if (state.currentStep == OnboardingCreateStep.confirmMnemonic) {
                _confirmStepKey.currentState?.clearInputs();
                context.read<OnboardingCreateBloc>().add(MnemonicBackPressed());
              }
            }
          },
          onNext: () {
            if (state.currentStep == OnboardingCreateStep.showMnemonic) {
              context.read<OnboardingCreateBloc>().add(MnemonicCreated());
            } else if (state.currentStep ==
                OnboardingCreateStep.confirmMnemonic) {
              final confirmedMnemonic =
                  _confirmStepKey.currentState?.getMnemonic();

              context.read<OnboardingCreateBloc>().add(
                    MnemonicConfirmed(mnemonic: confirmedMnemonic!.split(' ')),
                  );
            } else if (state.currentStep ==
                OnboardingCreateStep.createPassword) {
              // Get password from the password prompt
              final passwordState = _passwordStepKey.currentState;
              if (passwordState != null && passwordState.isValid) {
                context.read<OnboardingCreateBloc>().add(
                      WalletCreated(password: passwordState.password),
                    );
              }
            }
          },
          backButtonText: 'Cancel',
          nextButtonText:
              state.currentStep == OnboardingCreateStep.createPassword
                  ? 'Create Wallet'
                  : 'Continue',
          isLoading: isLoading,
          nextButtonEnabled: _getNextButtonEnabled(state),
        );
      },
    );
  }

  bool _getNextButtonEnabled(OnboardingCreateState state) {
    // if all mnemonic fields are filled on confirm step and there are no errors, return true
    if (state.currentStep == OnboardingCreateStep.confirmMnemonic) {
      final isValid = _confirmStepKey.currentState?.isValidMnemonic() ?? false;
      final noErrors = state.mnemonicError == null;
      return noErrors && isValid;

      // if password is filled on create password step and there are no errors, return true
    } else if (state.currentStep == OnboardingCreateStep.createPassword) {
      final isValid = _passwordStepKey.currentState?.isValid ?? false;
      final errors = state.createState.maybeWhen(
        error: (message) => true,
        orElse: () => false,
      );
      return isValid && !errors;
    } else {
      // if all steps are valid, return true
      return true;
    }
  }
}

class ShowMnemonicStep extends StatelessWidget {
  const ShowMnemonicStep({super.key});

  @override
  Widget build(BuildContext context) {
    final Config config = GetIt.I<Config>();

    return BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
      builder: (context, state) {
        return state.createMnemonicState.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (mnemonic) => Column(
            children: [
              Column(
                children: [
                  NumberedWordGrid(
                    text: mnemonic,
                    backgroundColor: Theme.of(context).cardColor,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                  ),
                  const SizedBox(height: 16),
                  if (config.network == Network.testnet4 ||
                      config.network == Network.testnet)
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: mnemonic));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seed phrase copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('COPY'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          error: (message) => SelectableText(message),
        );
      },
    );
  }
}

class SeedInputFields extends StatefulWidget {
  final MnemonicErrorState? mnemonicErrorState;
  final VoidCallback? onInputChanged;

  const SeedInputFields({
    super.key,
    this.mnemonicErrorState,
    this.onInputChanged,
  });

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
    final backdropBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;

    return Container(
      color: backdropBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              textAlign: TextAlign.center,
              'Please confirm your seed phrase',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
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
                          widget.mnemonicErrorState!.message,
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
                              widget.mnemonicErrorState!.message,
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
          // Existing code for larger screens...
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: widget.mnemonicErrorState != null &&
                            widget.mnemonicErrorState?.incorrectIndexes !=
                                null &&
                            widget.mnemonicErrorState!.incorrectIndexes!
                                .contains(index)
                        ? const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                            style: BorderStyle.solid)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: widget.mnemonicErrorState != null &&
                            widget.mnemonicErrorState?.incorrectIndexes !=
                                null &&
                            widget.mnemonicErrorState!.incorrectIndexes!
                                .contains(index)
                        ? const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                            style: BorderStyle.solid)
                        : BorderSide.none,
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: widget.mnemonicErrorState != null &&
                          widget.mnemonicErrorState?.incorrectIndexes != null &&
                          widget.mnemonicErrorState!.incorrectIndexes!
                              .contains(index)
                      ? const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                          style: BorderStyle.solid)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: widget.mnemonicErrorState != null &&
                          widget.mnemonicErrorState?.incorrectIndexes != null &&
                          widget.mnemonicErrorState!.incorrectIndexes!
                              .contains(index)
                      ? const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                          style: BorderStyle.solid)
                      : BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
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
    // Notify parent through callback
    widget.onInputChanged?.call();

    // Update mnemonic in bloc
    updateMnemonic();
  }

  void updateMnemonic() {
    String mnemonic =
        controllers.map((controller) => controller.text).join(' ').trim();
    context
        .read<OnboardingCreateBloc>()
        .add(MnemonicConfirmedChanged(mnemonic: mnemonic));
  }

  bool isValidMnemonic() {
    final allFilled =
        controllers.every((controller) => controller.text.trim().isNotEmpty);

    return allFilled;
  }

  String getMnemonic() {
    return controllers
        .map((controller) => controller.text.trim())
        .where((word) => word.isNotEmpty)
        .join(' ');
  }

  void clearInputs() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      _showSeedPhrase = false;
    });
  }
}
