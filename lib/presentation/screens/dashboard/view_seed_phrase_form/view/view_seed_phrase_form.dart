import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_state.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ViewSeedPhraseFormWrapper extends StatelessWidget {
  const ViewSeedPhraseFormWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewSeedPhraseBloc(
        walletRepository: GetIt.I.get<WalletRepository>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
      ),
      child: const ViewSeedPhraseForm(),
    );
  }
}

class ViewSeedPhraseForm extends StatefulWidget {
  const ViewSeedPhraseForm({super.key});

  @override
  State<ViewSeedPhraseForm> createState() => _ViewSeedPhraseFormState();
}

class _ViewSeedPhraseFormState extends State<ViewSeedPhraseForm> {
  final passwordFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool _showSeedPhrase = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewSeedPhraseBloc, ViewSeedPhraseState>(
      builder: (context, state) {
        void handleSubmit() {
          if (passwordFormKey.currentState!.validate()) {
            context
                .read<ViewSeedPhraseBloc>()
                .add(ViewSeedPhrase(password: passwordController.text));
          }
        }

        return state.maybeWhen(
          initial: (initial) => Form(
            key: passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HorizonUI.HorizonTextFormField(
                  controller: passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  label: 'Password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onEditingComplete: handleSubmit,
                ),
                if (initial.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      initial.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                HorizonUI.HorizonDialogSubmitButton(
                  textChild: const Text('CONFIRM'),
                  onPressed: handleSubmit,
                )
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (success) => Form(
            key: passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                HorizonUI.HorizonTextFormField(
                  label: 'Seed phrase',
                  controller: TextEditingController(text: success.seedPhrase),
                  enabled: false,
                  obscureText: !_showSeedPhrase,
                  suffix: IconButton(
                    icon: Icon(
                      _showSeedPhrase ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSeedPhrase = !_showSeedPhrase;
                      });
                    },
                  ),
                  fitText: true,
                ),
              ],
            ),
          ),
          error: (error) => Text(error),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
