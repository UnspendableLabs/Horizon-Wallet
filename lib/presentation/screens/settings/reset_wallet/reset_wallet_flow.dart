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
  bool _toggleRecognized = false;
  final _formKey = GlobalKey<FormState>();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(() {
      setState(() {});
    });
  }

  Widget _buildWarningStep() {
    final mutedWarningStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: transparentWhite66,
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Warning icon and text group
          Container(
            margin: const EdgeInsets.all(0.0),
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
                const SizedBox(height: 10),
                Text(
                  "All wallet data will be permanently deleted. You can only recover your wallet using your seed phrase.",
                  style: mutedWarningStyle,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Text("\u2022", style: mutedWarningStyle),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                        "If you have multiple accounts, note the total number—you'll need to recreate them manually.",
                        style: mutedWarningStyle),
                  ),
                ]),
                Row(children: [
                  Text("\u2022", style: mutedWarningStyle),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                        "Imported private keys won't be restored—be sure to back them up separately.",
                        style: mutedWarningStyle),
                  ),
                ])
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Warning box container
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: red1),
            ),
            child: Column(
              children: [
                _buildWarningPoint(
                  'Double check seed phrase backup',
                  AppIcons.eyeOpenIcon(context: context),
                ),
                _buildWarningPoint(
                  'Save imported private keys',
                  AppIcons.lockIcon(context: context),
                ),
                Container(
                  height: 64,
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: transparentBlack66,
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
                                'I understand the risk',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            HorizonToggle(
                              value: _toggleRecognized,
                              onChanged: (_) {
                                setState(() {
                                  _toggleRecognized = !_toggleRecognized;
                                });
                              },
                              type: HorizonToggleType.error,
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
            child: HorizonButton(
              variant: ButtonVariant.red,
              disabled: !_toggleRecognized,
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              child: TextButtonContent(value: "Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return BlocProvider(
      create: (context) => ResetBloc(
        addressRepository: GetIt.I.get<AddressRepositoryDeprecated>(),
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
                            'Final\nConfirmation',
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: HorizonButton(
                      variant: ButtonVariant.red,
                      disabled: _confirmationController.text != 'RESET WALLET',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ResetBloc>().add(ResetEvent());
                        }
                      },
                      child: TextButtonContent(value: "Reset Wallet"),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              _buildFinalStep(),
            ],
          ),
        ),
      ],
    );
  }
}
