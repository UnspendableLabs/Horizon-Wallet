import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_shell.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding/view/seed_input.dart';
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

class OnboardingImportPage extends StatefulWidget {
  const OnboardingImportPage({super.key});

  @override
  State<OnboardingImportPage> createState() => _OnboardingImportPageState();
}

class _OnboardingImportPageState extends State<OnboardingImportPage> {
  final _passwordStepKey = GlobalKey<PasswordPromptState>();
  final _seedInputKey = GlobalKey<SeedInputState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingImportBloc, OnboardingImportState>(
      listener: (context, state) {
        state.importState.maybeWhen(
          orElse: () => false,
          success: () {
            final session = context.read<SessionStateCubit>();
            session.initialize();
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.importState.maybeWhen(
          orElse: () => false,
          loading: () => true,
        );
        final error = state.importState.maybeWhen(
          orElse: () => false,
          error: (error) => error,
        );

        return OnboardingShell(
          steps: [
            const ChooseFormatStep(),
            SeedInputStep(seedInputKey: _seedInputKey),
            PasswordPrompt(
              key: _passwordStepKey,
              state: state,
              onValidationChanged: () => setState(() {}),
              optionalErrorWidget: error
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
                              error,
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
            if (state.currentStep == OnboardingImportStep.chooseFormat) {
              final session = context.read<SessionStateCubit>();
              session.onOnboarding();
            } else if (state.currentStep == OnboardingImportStep.inputSeed) {
              _seedInputKey.currentState?.clearInputs();
              context
                  .read<OnboardingImportBloc>()
                  .add(ImportFormatBackPressed());
            } else if (state.currentStep ==
                OnboardingImportStep.inputPassword) {
              _passwordStepKey.currentState?.clearPassword();
              context.read<OnboardingImportBloc>().add(SeedInputBackPressed());
            }
          },
          onNext: () {
            if (state.currentStep == OnboardingImportStep.chooseFormat) {
              context.read<OnboardingImportBloc>().add(ImportFormatSubmitted());
            } else if (state.currentStep == OnboardingImportStep.inputSeed) {
              context
                  .read<OnboardingImportBloc>()
                  .add(MnemonicSubmitted(mnemonic: state.mnemonic));
            } else if (state.currentStep ==
                OnboardingImportStep.inputPassword) {
              final passwordState = _passwordStepKey.currentState;
              if (passwordState != null && passwordState.isValid) {
                context.read<OnboardingImportBloc>().add(
                      ImportWallet(password: passwordState.password),
                    );
              }
            }
          },
          backButtonText: 'Cancel',
          nextButtonText:
              state.currentStep == OnboardingImportStep.inputPassword
                  ? 'Load Wallet'
                  : 'Continue',
          isLoading: isLoading,
          nextButtonEnabled: _getNextButtonEnabled(state),
        );
      },
    );
  }

  bool _getNextButtonEnabled(OnboardingImportState state) {
    if (state.currentStep == OnboardingImportStep.inputSeed) {
      final isValid = _seedInputKey.currentState?.isValidMnemonic() ?? false;
      final noErrors = state.mnemonicError == null;
      return noErrors && isValid;
    } else if (state.currentStep == OnboardingImportStep.inputPassword) {
      final error = state.importState.maybeWhen(
        orElse: () => false,
        error: (error) => error,
      );
      final isValid = _passwordStepKey.currentState?.isValid ?? false;
      return isValid && !error;
    } else {
      return true;
    }
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
  final GlobalKey<SeedInputState> seedInputKey;

  const SeedInputStep({
    super.key,
    required this.seedInputKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
      builder: (context, state) {
        return SeedInput(
          key: seedInputKey,
          errorMessage: state.mnemonicError,
          onInputChanged: () => context.findRenderObject()?.markNeedsPaint(),
          onInputsUpdated: (mnemonic) {
            context
                .read<OnboardingImportBloc>()
                .add(MnemonicChanged(mnemonic: mnemonic));
          },
        );
      },
    );
  }
}
