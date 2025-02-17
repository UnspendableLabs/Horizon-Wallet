// ignore_for_file: type_literal_in_constant_pattern

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
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
    this.wordsPerRow = 3,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.itemMargin =
        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  });

  @override
  Widget build(BuildContext context) {
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
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromRGBO(254, 251, 249, 0.08)
                          : Colors.transparent,
                    ),
                    color: backgroundColor,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          "${wordIndex + 1}.",
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: FontWeight.bold,
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
                              fontSize: 16,
                              color: textColor,
                              fontWeight: FontWeight.bold,
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
              state: state,
              onValidationChanged: () => setState(() {}),
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
