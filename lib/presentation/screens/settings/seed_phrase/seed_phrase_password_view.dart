import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_state.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/seed_phrase_display_view.dart';

class SeedPhrasePasswordView extends StatefulWidget {
  const SeedPhrasePasswordView({super.key});

  @override
  State<SeedPhrasePasswordView> createState() => _SeedPhrasePasswordViewState();
}

class _SeedPhrasePasswordViewState extends State<SeedPhrasePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => ViewSeedPhraseBloc(
        walletRepository: GetIt.I.get<WalletRepository>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
      ),
      child: BlocConsumer<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (success) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SeedPhraseDisplayView(
                    seedPhrase: success.seedPhrase,
                  ),
                ),
              );
            },
            initial: (initial) {
              if (initial.error != null) {
                setState(() {
                  _error = initial.error;
                });
              }
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              leadingWidth: 40,
              toolbarHeight: 74,
              title: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  "Seed phrase",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 9.0, top: 18.0),
                child: BackButton(
                  color: isDarkTheme ? Colors.white : Colors.black,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            body: Padding(
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.maybeWhen(
                          loading: () => null,
                          orElse: () => () {
                            if (_formKey.currentState!.validate()) {
                              context.read<ViewSeedPhraseBloc>().add(
                                    ViewSeedPhrase(
                                      password: _passwordController.text,
                                    ),
                                  );
                            }
                          },
                        ),
                        child: state.maybeWhen(
                          loading: () => const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          orElse: () => const Text('Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
