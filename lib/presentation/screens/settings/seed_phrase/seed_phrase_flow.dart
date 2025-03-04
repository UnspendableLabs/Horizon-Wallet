import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/widgets/numbered_grid.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_bloc.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_state.dart';

class SeedPhraseFlow extends StatefulWidget {
  const SeedPhraseFlow({super.key});

  @override
  State<SeedPhraseFlow> createState() => _SeedPhraseFlowState();
}

class _SeedPhraseFlowState extends State<SeedPhraseFlow> {
  int _currentStep = 0;
  String? _seedPhrase;
  final _passwordController = TextEditingController();
  String? _error;
  bool _showSeedPhrase = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildWarningStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Warning icon and text group
          Container(
            margin: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: red1,
                  size: 48,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 170,
                  child: Text(
                    'Before you continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: red1,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please write down your seed phrase and store it in a secure location. It is the only way to recover your wallet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Warning boxes container
          Container(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: red1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWarningPoint(
                  'View this in private',
                  const Icon(Icons.visibility_outlined, size: 12),
                ),
                _buildWarningPoint(
                  'Do not share with anyone',
                  const Icon(Icons.lock_outline, size: 12),
                ),
                _buildWarningPoint(
                  'Never enter it to any website or applications',
                  const Icon(Icons.shield_outlined, size: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: HorizonOutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return BlocProvider(
                      create: (context) => ViewSeedPhraseBloc(
                        walletRepository: GetIt.I.get<WalletRepository>(),
                        encryptionService: GetIt.I.get<EncryptionService>(),
                      ),
                      child:
                          BlocConsumer<ViewSeedPhraseBloc, ViewSeedPhraseState>(
                        listener: (context, state) {
                          if (state is ViewSeedPhraseLoading) {
                            setState(() {
                              _isLoading = true;
                            });
                          } else if (state is ViewSeedPhraseError) {
                            setState(() {
                              _error = state.error;
                              _isLoading = false;
                            });
                          } else if (state is ViewSeedPhraseSuccess) {
                            setState(() {
                              _seedPhrase = state.seedPhrase;
                              _currentStep = 1;
                              _error = null;
                              _isLoading = false;
                            });
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        builder: (context, state) {
                          return HorizonPasswordPrompt(
                            onPasswordSubmitted: (password) async {
                              context.read<ViewSeedPhraseBloc>().add(
                                    Submit(
                                      password: password,
                                    ),
                                  );
                            },
                            onCancel: () {
                              setState(() {
                                _error = null;
                                _isLoading = false;
                              });
                              Navigator.of(dialogContext).pop();
                            },
                            buttonText: 'Continue',
                            title: 'Enter Password',
                            errorText: _error,
                            isLoading: _isLoading,
                          );
                        },
                      ),
                    );
                  },
                );
              },
              buttonText: 'Continue',
              isTransparent: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayStep() {
    if (_seedPhrase == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumberedGrid(
            text: _showSeedPhrase
                ? _seedPhrase!
                : '•••• •••• •••• •••• •••• •••• •••• •••• •••• •••• •••• ••••',
            itemMargin: const EdgeInsets.all(5.0),
          ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton.icon(
                style: Theme.of(context).textButtonTheme.style?.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        transparentPurple8,
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                      ),
                    ),
                onPressed: () {
                  setState(() {
                    _showSeedPhrase = !_showSeedPhrase;
                  });
                },
                icon: Icon(
                  color: Theme.of(context).iconTheme.color,
                  _showSeedPhrase
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                label: Text(
                  _showSeedPhrase ? 'Hide Phrase' : 'Show Phrase',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningPoint(String title, Icon icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 4),
          SelectableText(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _currentStep,
            children: [
              _buildWarningStep(),
              _buildDisplayStep(),
            ],
          ),
        ),
      ],
    );
  }
}
