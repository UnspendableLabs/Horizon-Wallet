import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_state.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

class ResetWalletFlow extends StatefulWidget {
  const ResetWalletFlow({super.key});

  @override
  State<ResetWalletFlow> createState() => _ResetWalletFlowState();
}

class _ResetWalletFlowState extends State<ResetWalletFlow> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _confirmationController = TextEditingController();
  bool _hasConfirmedUnderstanding = false;
  String? _error;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
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
            'Warning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
              children: const [
                TextSpan(text: 'All wallet data will be '),
                TextSpan(
                  text: 'irreversibly deleted',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(text: '. You can recover your wallet '),
                TextSpan(
                  text: 'only',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: ' with your seed phrase.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildWarningPoint(
            '• Multiple accounts',
            'Write down the total number—you\'ll need to recreate them manually after recovery.',
          ),
          const SizedBox(height: 12),
          _buildWarningPoint(
            '• Imported private keys',
            'Won\'t reload when you recover your wallet—make sure you have them written down.',
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
              child: const Text('I Understand'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: _hasConfirmedUnderstanding,
            onChanged: (value) {
              setState(() {
                _hasConfirmedUnderstanding = value ?? false;
              });
            },
            title: const Text(
              "I understand the consequences of this action and confirm I have written down my seed phrase, imported private keys, and account count.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _hasConfirmedUnderstanding
                  ? () {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return BlocProvider(
      create: (context) => ResetBloc(
        walletRepository: GetIt.I.get<WalletRepository>(),
        accountRepository: GetIt.I.get<AccountRepository>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
        importedAddressRepository: GetIt.I.get<ImportedAddressRepository>(),
        analyticsService: GetIt.I.get<AnalyticsService>(),
        cacheProvider: GetIt.I.get<CacheProvider>(),
        inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
        kvService: GetIt.I.get<SecureKVService>(),
      ),
      child: BlocConsumer<ResetBloc, ResetState>(
        listener: (context, state) {
          if (state.status == ResetStatus.completed) {
            context.read<SessionStateCubit>().onOnboarding();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Final Confirmation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This action is irreversible, and your wallet data will be permanently deleted.',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _confirmationController,
                    decoration: InputDecoration(
                      labelText: 'Type "RESET WALLET" to confirm',
                      errorText: _error,
                    ),
                    validator: (value) {
                      if (value != 'RESET WALLET') {
                        return 'Please type "RESET WALLET" exactly';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ResetBloc>().add(ResetEvent());
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reset Wallet'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                color: Colors.red,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.withOpacity(0.8),
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
              _buildConfirmationStep(),
              _buildFinalStep(),
            ],
          ),
        ),
      ],
    );
  }
}
