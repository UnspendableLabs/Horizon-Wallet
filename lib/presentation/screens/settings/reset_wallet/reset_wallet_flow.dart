import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_bloc.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_event.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_state.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/utils/app_icons.dart';

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

  @override
  void dispose() {
    _confirmationController.dispose();
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
                AppIcons.warningIcon(color: red1, height: 48, width: 48),
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
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Warning box container
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
                  'All wallet data will be irreversibly deleted. You can recover your wallet only with your seed phrase.',
                  AppIcons.eyeOpenIcon(context: context),
                ),
                _buildWarningPoint(
                  'Imported private keys won\'t reload when you recover your wallet. Make sure you have them written down.',
                  AppIcons.lockIcon(context: context),
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
                  _currentStep = 1;
                });
              },
              buttonText: 'Continue',
              isTransparent: true,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 335,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: yellow1,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcons.warningIcon(color: yellow1, height: 24, width: 24),
                const SizedBox(height: 8),
                SelectableText(
                  textAlign: TextAlign.center,
                  'Please confirm that you understand the consequences of resetting your wallet and that you have written down your seed phrase and imported private keys.',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  height: 64,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context)
                              .inputDecorationTheme
                              .outlineBorder
                              ?.color ??
                          transparentBlack8,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'I understand and confirm',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            HorizonToggle(
                              value: _hasConfirmedUnderstanding,
                              onChanged: (_) {
                                setState(() {
                                  _hasConfirmedUnderstanding =
                                      !_hasConfirmedUnderstanding;
                                });
                              },
                              backgroundColor: yellow1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: HorizonOutlinedButton(
              onPressed: _hasConfirmedUnderstanding
                  ? () {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  : null,
              buttonText: 'Continue',
              isTransparent: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return BlocProvider(
      create: (context) => ResetBloc(
        addressRepository: GetIt.I.get<AddressRepository>(),
        importedAddressRepository: GetIt.I.get<ImportedAddressRepository>(),
        transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
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
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Warning icon and text group
                  Container(
                    margin: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        AppIcons.warningIcon(
                            color: red1, height: 48, width: 48),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 220,
                          child: Text(
                            'Final Confirmation',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: red1,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                      'This action is irreversible, and your wallet data will be permanently deleted.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 24),
                  HorizonTextField(
                    key: const Key('resetConfirmationTextField'),
                    controller: _confirmationController,
                    hintText: 'Type "RESET WALLET" to confirm',
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
                    height: 56,
                    child: HorizonOutlinedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ResetBloc>().add(ResetEvent());
                        }
                      },
                      buttonText: 'Reset Wallet',
                      isTransparent: false,
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

  Widget _buildWarningPoint(String title, Widget icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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
              _buildConfirmationStep(),
              _buildFinalStep(),
            ],
          ),
        ),
      ],
    );
  }
}
