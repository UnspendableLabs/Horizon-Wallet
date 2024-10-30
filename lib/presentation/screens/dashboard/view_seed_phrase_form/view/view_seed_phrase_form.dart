import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_bloc.dart';

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

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('ViewSeedPhraseForm');
  }
}
