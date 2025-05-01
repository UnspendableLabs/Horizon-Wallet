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
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/common/widgets/numbered_grid.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_shell.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding/view/seed_input.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

class NumberedWordGrid extends StatelessWidget {
  final String text;
  final int wordsPerRow;
  final double borderRadius;
  final EdgeInsets itemMargin;
  final bool isSmallScreen;

  const NumberedWordGrid({
    super.key,
    required this.text,
    this.wordsPerRow = 3,
    this.borderRadius = 8.0,
    this.itemMargin =
        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    List<String> words = text.split(' ');
    int totalWords = words.length;
    int rowCount = (totalWords / wordsPerRow).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        int startIndex = rowIndex * wordsPerRow;
        int endIndex = min((rowIndex + 1) * wordsPerRow, totalWords);
        List<String> rowWords = words.sublist(startIndex, endIndex);

        return Row(
          children: rowWords.asMap().entries.map((entry) {
            int wordIndex = startIndex + entry.key;
            String word = entry.value;
            return Expanded(
              child: Container(
                margin: itemMargin,
                child: Container(
                  width: 105,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: customTheme.inputBorderColor),
                    color: customTheme.inputBackground,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          "${wordIndex + 1}.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: theme.inputDecorationTheme.hintStyle?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 12,
                              color: customTheme.inputTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
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
  final _seedInputKey = GlobalKey<SeedInputState>();

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
              mnemonicErrorState: state.mnemonicError,
              seedInputKey: _seedInputKey,
              onInputChanged: () => setState(() {
                /* trigger rebuild */
              }),
            ),
            PasswordPrompt(
              key: _passwordStepKey,
              onValidationChanged: () => setState(() {}),
              optionalErrorWidget: createStateError != null
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: red1,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText(
                              createStateError,
                              style: const TextStyle(color: red1),
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
                _seedInputKey.currentState?.clearInputs();
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
                  _seedInputKey.currentState?.getMnemonic();

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
      final isValid = _seedInputKey.currentState?.isValidMnemonic() ?? false;
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
    final isSmallScreen = MediaQuery.of(context).size.width < 500;
    return BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
      builder: (context, state) {
        return state.createMnemonicState.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (mnemonic) => Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20.0 : 40.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 170,
                      child: SelectableText(
                        'Seed Phrase',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      'Please write down your seed phrase and store it in a secure location. It is the only way to recover your wallet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: isSmallScreen ? 20.0 : 40.0),
                    child: NumberedGrid(
                      isSmallScreen: isSmallScreen,
                      text: mnemonic,
                      itemMargin: const EdgeInsets.all(5.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (config.network == Network.testnet4 ||
                      config.network == Network.testnet)
                    HorizonButton(
                      width: 150,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: mnemonic));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seed phrase copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },  
                      child: TextButtonContent(value: "Copy"),
                      icon: const Icon(Icons.copy),
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
  final GlobalKey<SeedInputState> seedInputKey;

  const SeedInputFields({
    super.key,
    this.mnemonicErrorState,
    this.onInputChanged,
    required this.seedInputKey,
  });

  @override
  State<SeedInputFields> createState() => _SeedInputFieldsState();
}

class _SeedInputFieldsState extends State<SeedInputFields> {
  @override
  Widget build(BuildContext context) {
    return SeedInput(
      key: widget.seedInputKey,
      showTitle: true,
      title: 'Seed Phrase Confirmation',
      subtitle:
          'To ensure you have securely saved your seed phrase, please enter it below.',
      errorMessage: widget.mnemonicErrorState?.message,
      incorrectIndexes: widget.mnemonicErrorState?.incorrectIndexes,
      onInputChanged: widget.onInputChanged,
      onInputsUpdated: (mnemonic) {
        context
            .read<OnboardingCreateBloc>()
            .add(MnemonicConfirmedChanged(mnemonic: mnemonic));
      },
    );
  }
}
