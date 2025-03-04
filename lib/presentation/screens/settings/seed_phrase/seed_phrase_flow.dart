import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
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
  bool _copied = false;
  bool _showPasswordPrompt = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    if (_seedPhrase != null) {
      Clipboard.setData(ClipboardData(text: _seedPhrase!));
      setState(() {
        _copied = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _copied = false;
          });
        }
      });
    }
  }

  Widget _buildWarningStep() {
    return Stack(
      children: [
        Padding(
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    setState(() {
                      _showPasswordPrompt = true;
                      _error = null;
                    });
                  },
                  buttonText: 'Continue',
                  isTransparent: true,
                ),
              ),
            ],
          ),
        ),
        if (_showPasswordPrompt)
          BlocProvider(
            create: (context) => ViewSeedPhraseBloc(
              walletRepository: GetIt.I.get<WalletRepository>(),
              encryptionService: GetIt.I.get<EncryptionService>(),
            ),
            child: BlocConsumer<ViewSeedPhraseBloc, ViewSeedPhraseState>(
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
                    _showPasswordPrompt = false;
                  });
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
                      _showPasswordPrompt = false;
                      _error = null;
                      _isLoading = false;
                    });
                  },
                  buttonText: 'Continue',
                  title: 'Enter Password',
                  errorText: _error,
                  isLoading: _isLoading,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDisplayStep() {
    if (_seedPhrase == null) return const SizedBox.shrink();

    final words = _seedPhrase!.split(' ');
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Seed Phrase',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Write down these 12 words in order and keep them safe.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDarkTheme
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: TextStyle(
                              color: isDarkTheme
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _showSeedPhrase ? words[index] : '••••',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: transparentPurple8,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSeedPhrase = !_showSeedPhrase;
                        });
                      },
                      icon: Icon(
                        _showSeedPhrase
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      label: Text(_showSeedPhrase ? 'Hide' : 'Show'),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: transparentPurple8,
                      ),
                      onPressed: _copyToClipboard,
                      icon: const Icon(
                        Icons.copy,
                        size: 20,
                      ),
                      label: Text(_copied ? 'Copied!' : 'Copy'),
                    ),
                  ],
                ),
              ],
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
