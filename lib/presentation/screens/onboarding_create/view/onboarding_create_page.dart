// ignore_for_file: type_literal_in_constant_pattern

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_app_bar.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

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
              config: GetIt.I<Config>(),
              mnmonicService: GetIt.I<MnemonicService>(),
              walletRepository: GetIt.I<WalletRepository>(),
              walletService: GetIt.I<WalletService>(),
              accountRepository: GetIt.I<AccountRepository>(),
              addressRepository: GetIt.I<AddressRepository>(),
              encryptionService: GetIt.I<EncryptionService>(),
              addressService: GetIt.I<AddressService>(),
            ),
        child: const OnboardingCreatePage());
  }
}

class OnboardingCreatePage extends StatefulWidget {
  const OnboardingCreatePage({super.key});
  @override
  OnboardingCreatePageState createState() => OnboardingCreatePageState();
}

class OnboardingCreatePageState extends State<OnboardingCreatePage> {
  final TextEditingController _passwordController =
      TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController =
      TextEditingController(text: "");

  @override
  dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
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

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
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
            child: BlocListener<OnboardingCreateBloc, OnboardingCreateState>(
              listener: (context, state) {
                if (state.createState is CreateStateSuccess) {
                  final shell = context.read<ShellStateCubit>();
                  // reload shell to trigger redirect
                  shell.initialize();
                }
              },
              child: BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          OnboardingAppBar(
                            isDarkMode: isDarkMode,
                            isSmallScreenWidth: isSmallScreen,
                            isSmallScreenHeight: isSmallScreen,
                            scaffoldBackgroundColor: scaffoldBackgroundColor,
                          ),
                          Flexible(
                            child: BlocBuilder<OnboardingCreateBloc,
                                OnboardingCreateState>(
                              builder: (context, state) {
                                return switch (state.createState) {
                                  CreateStateNotAsked => const Mnemonic(),
                                  CreateStateMnemonicUnconfirmed =>
                                    ConfirmSeedInputFields(
                                      mnemonicErrorState: state.mnemonicError,
                                    ),
                                  _ => PasswordPrompt(
                                      state: state,
                                      onPressedBack: () {
                                        final shell =
                                            context.read<ShellStateCubit>();
                                        shell.onOnboarding();
                                      },
                                      onPressedContinue: (password) {
                                        context
                                            .read<OnboardingCreateBloc>()
                                            .add(CreateWallet(
                                                password: password));
                                      },
                                      backButtonText: 'CANCEL',
                                      continueButtonText: 'CONTINUE',
                                    ),
                                };
                              },
                            ),
                          ),
                        ],
                      ),
                      if (state.createState is CreateStateLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Mnemonic extends StatefulWidget {
  const Mnemonic({super.key});

  @override
  State<Mnemonic> createState() => _MnemonicState();
}

class _MnemonicState extends State<Mnemonic> {
  @override
  void initState() {
    super.initState();
    final state = BlocProvider.of<OnboardingCreateBloc>(context).state;
    if (state.mnemonicState is! GenerateMnemonicStateUnconfirmed) {
      BlocProvider.of<OnboardingCreateBloc>(context).add(GenerateMnemonic());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreenWidth = screenSize.width < 768;
    final Config config = GetIt.I<Config>();

    return BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
      builder: (context, state) {
        return Container(
          color: scaffoldBackgroundColor,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: Column(
                          children: [
                            if (state.mnemonicState
                                is GenerateMnemonicStateLoading)
                              const CircularProgressIndicator()
                            else if (state.mnemonicState
                                    is GenerateMnemonicStateGenerated ||
                                state.mnemonicState
                                    is GenerateMnemonicStateUnconfirmed)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    NumberedWordGrid(
                                      text: state.mnemonicState.mnemonic,
                                      backgroundColor: isDarkMode
                                          ? darkThemeInputColor
                                          : lightThemeInputColor,
                                      textColor: isDarkMode
                                          ? mainTextWhite
                                          : mainTextBlack,
                                    ),
                                    if (config.network == Network.testnet)
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.copy,
                                        ),
                                        label: const Text('COPY'),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: state
                                                  .mnemonicState.mnemonic));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Seed phrase copied to clipboard'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Please write down your seed phrase in a secure location. It is the only way to recover your wallet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            BackContinueButtons(
                              isDarkMode: isDarkMode,
                              isSmallScreenWidth: isSmallScreenWidth,
                              onPressedBack: () {
                                final shell = context.read<ShellStateCubit>();
                                shell.onOnboarding();
                              },
                              onPressedContinue: () {
                                context
                                    .read<OnboardingCreateBloc>()
                                    .add(UnconfirmMnemonic());
                              },
                              backButtonText: 'BACK',
                              continueButtonText: 'CONTINUE',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ConfirmSeedInputFields extends StatefulWidget {
  final MnemonicErrorState? mnemonicErrorState;
  const ConfirmSeedInputFields({required this.mnemonicErrorState, super.key});
  @override
  State<ConfirmSeedInputFields> createState() => _ConfirmSeedInputFieldsState();
}

class _ConfirmSeedInputFieldsState extends State<ConfirmSeedInputFields> {
  List<TextEditingController> controllers =
      List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      color: isDarkMode ? mainTextWhite : mainTextBlack),
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
                            const Icon(Icons.info, color: redErrorText),
                            const SizedBox(width: 4),
                            SelectableText(
                              widget.mnemonicErrorState!.message,
                              style: const TextStyle(color: redErrorText),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Text(""),
              buildInputFields(isSmallScreen, isDarkMode),
              if (isSmallScreen) const SizedBox(height: 16),
              BackContinueButtons(
                  isDarkMode: isDarkMode,
                  isSmallScreenWidth: isSmallScreen,
                  onPressedBack: () {
                    context
                        .read<OnboardingCreateBloc>()
                        .add(GoBackToMnemonic());
                  },
                  onPressedContinue: () {
                    context.read<OnboardingCreateBloc>().add(ConfirmMnemonic(
                        mnemonic: controllers
                            .map((controller) => controller.text)
                            .toList()));
                  },
                  backButtonText: 'BACK',
                  continueButtonText: 'CONTINUE',
                  errorWidget: !isSmallScreen &&
                          widget.mnemonicErrorState != null
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
                                  widget.mnemonicErrorState!.message,
                                  style: const TextStyle(color: redErrorText),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputFields(bool isSmallScreen, bool isDarkMode) {
    if (isSmallScreen) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(
                      6, (index) => buildCompactInputField(index, isDarkMode)),
                ),
              ),
              Expanded(
                child: Column(
                  children: List.generate(6,
                      (index) => buildCompactInputField(index + 6, isDarkMode)),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Existing code for larger screens
      return Row(
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
      );
    }
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: widget.mnemonicErrorState != null &&
                            widget.mnemonicErrorState?.incorrectIndexes !=
                                null &&
                            widget.mnemonicErrorState!.incorrectIndexes!
                                .contains(index)
                        ? const BorderSide(
                            color: redErrorText,
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
                            color: redErrorText,
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: widget.mnemonicErrorState != null &&
                          widget.mnemonicErrorState?.incorrectIndexes != null &&
                          widget.mnemonicErrorState!.incorrectIndexes!
                              .contains(index)
                      ? const BorderSide(
                          color: redErrorText,
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
                          color: redErrorText,
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
    updateMnemonic();
  }

  void updateMnemonic() {
    List<String> mnemonic =
        controllers.map((controller) => controller.text).toList();
    context
        .read<OnboardingCreateBloc>()
        .add(ConfirmMnemonicChanged(mnemonic: mnemonic));
  }
}
