import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_state.dart';

class SeedPhraseFlow extends StatefulWidget {
  const SeedPhraseFlow({super.key});

  @override
  State<SeedPhraseFlow> createState() => _SeedPhraseFlowState();
}

class _SeedPhraseFlowState extends State<SeedPhraseFlow> {
  int _currentStep = 0;
  String? _seedPhrase;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String? _error;
  bool _showSeedPhrase = false;
  bool _copied = false;

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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 20),
          Text(
            'Security Warning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your seed phrase is the key to your wallet. Keep it safe and private:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _buildWarningPoint(
            '• Never share your seed phrase with anyone',
            'Legitimate services will never ask for it',
          ),
          const SizedBox(height: 16),
          _buildWarningPoint(
            '• Store it securely offline',
            'Write it down and keep it in a safe place',
          ),
          const SizedBox(height: 16),
          _buildWarningPoint(
            '• Verify your surroundings',
            'Make sure no one can see your screen',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              child: const Text('I Understand, Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return BlocProvider(
      create: (context) => ViewSeedPhraseBloc(
        walletRepository: GetIt.I.get<WalletRepository>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
      ),
      child: BlocConsumer<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        listener: (context, state) {
          if (state is ViewSeedPhraseError) {
            setState(() {
              _error = state.error;
            });
          } else if (state is ViewSeedPhraseSuccess) {
            setState(() {
              _seedPhrase = state.seedPhrase;
              _currentStep = 2;
              _error = null;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is ViewSeedPhraseLoading;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Password',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter your wallet password to view your seed phrase.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _error,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<ViewSeedPhraseBloc>().add(
                                          Submit(
                                            password: _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

  Widget _buildWarningPoint(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Container(
              width: 48,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: transparentWhite33,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentStep + 1) / 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        pinkGradient1,
                        purpleGradient1,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: IndexedStack(
            index: _currentStep,
            children: [
              _buildWarningStep(),
              _buildPasswordStep(),
              _buildDisplayStep(),
            ],
          ),
        ),
      ],
    );
  }
}
