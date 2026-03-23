import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "./bloc/settings_advanced_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/usecases/export_encrypted_bls_private_key.dart';
import 'package:horizon/domain/usecases/validate_password.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/utils/app_icons.dart';

import "../settings_view.dart" show SettingsItem;

String _userFacingBlsExportError(Object error) {
  if (error is UnsupportedError) {
    return 'Exporting an encrypted BLS key is only available in the web app.';
  }
  return 'Could not export the encrypted BLS key. Please try again.';
}

Future<String?> _promptWalletPasswordForBlsExport(BuildContext rootContext) {
  String? errorText;
  bool isLoading = false;

  return showDialog<String?>(
    context: rootContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return HorizonPasswordPrompt(
            onPasswordSubmitted: (password) async {
              setState(() {
                isLoading = true;
                errorText = null;
              });

              final valid = await ValidatePasswordUseCase().call(password);

              if (!valid) {
                setState(() {
                  errorText = 'Invalid Password';
                  isLoading = false;
                });
                return;
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop<String>(password);
              }
            },
            onCancel: () {
              Navigator.of(dialogContext).pop<String?>(null);
            },
            buttonText: 'Continue',
            title: 'Enter Password',
            errorText: errorText,
            isLoading: isLoading,
          );
        },
      );
    },
  );
}

Future<String?> _promptExportPasswordForBls(BuildContext rootContext) {
  String? errorText;
  bool isLoading = false;

  return showDialog<String?>(
    context: rootContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return HorizonPasswordPrompt(
            title: 'Export password',
            subtitle:
                'For stronger security, prefer a password that is different from your wallet password.',
            onPasswordSubmitted: (password) async {
              setState(() {
                isLoading = true;
                errorText = null;
              });

              final trimmed = password.trim();
              if (trimmed.isEmpty) {
                setState(() {
                  errorText = 'Enter a password';
                  isLoading = false;
                });
                return;
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop<String>(trimmed);
              }
            },
            onCancel: () {
              Navigator.of(dialogContext).pop<String?>(null);
            },
            buttonText: 'Continue',
            errorText: errorText,
            isLoading: isLoading,
          );
        },
      );
    },
  );
}

Future<void> _showBlsExportResultDialog(BuildContext rootContext, String hex) {
  return showDialog<void>(
    context: rootContext,
    builder: (dialogContext) {
      final theme = Theme.of(rootContext);
      return AlertDialog(
        title: Text(
          'Encrypted BLS key',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            hex,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            style: theme.textButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(transparentPurple8),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: hex));
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcons.copyIcon(
                  context: rootContext,
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'COPY',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Future<void> _showExportBlsKeyFlow(BuildContext context) async {
  if (!kIsWeb) return;

  final settingsRepo = GetIt.I<SettingsRepository>();
  final useCase = GetIt.I<ExportEncryptedBlsPrivateKeyUseCase>();
  final walletConfigRepo = GetIt.I<WalletConfigRepository>();

  String? walletPassword;
  if (settingsRepo.requirePasswordForCryptoOperations) {
    walletPassword = await _promptWalletPasswordForBlsExport(context);
    if (walletPassword == null || !context.mounted) return;
  }

  final exportPassword = await _promptExportPasswordForBls(context);
  if (exportPassword == null || !context.mounted) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final String hex;
  try {
    final walletConfig = await walletConfigRepo.getCurrent();
    final decryptionStrategy = settingsRepo.requirePasswordForCryptoOperations
        ? Password(walletPassword!)
        : InMemoryKey();

    hex = await useCase(ExportEncryptedBlsPrivateKeyParams(
      walletConfig: walletConfig,
      decryptionStrategy: decryptionStrategy,
      exportPassword: exportPassword,
    ));
  } catch (e) {
    if (navigator.mounted && navigator.canPop()) {
      navigator.pop();
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_userFacingBlsExportError(e)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return;
  }

  if (navigator.mounted && navigator.canPop()) {
    navigator.pop();
  }
  if (!context.mounted) return;
  await _showBlsExportResultDialog(context, hex);
}

class SettingsAdvancedProvider extends StatelessWidget {
  final WalletConfigRepository _walletConfigRepository;
  final Widget child;

  SettingsAdvancedProvider({
    super.key,
    required this.child,
    WalletConfigRepository? walletConfigRepository,
  }) : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>();
  @override
  Widget build(BuildContext context) {
    // TODO: not sure i really like FutureBuilder
    return FutureBuilder(
        future: _walletConfigRepository.getCurrent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          // TODO: not sure
          if (snapshot.hasError) {
            throw Exception("invariant");
          }

          if (snapshot.hasData) {
            return BlocProvider(
              create: (context) =>
                  SettingsAdvancedBloc(walletConfig: snapshot.data!),
              child: child,
            );
          }
          return const SizedBox.shrink();
        });
  }
}

class LegacyAddressTypeSettings extends StatelessWidget {
  final SettingsAdvancedState state;
  const LegacyAddressTypeSettings({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    context.read<SessionStateCubit>().state.successOrThrow();

    return Column(children: [
      SettingsItem(
          title: "P2PKH",
          trailing: Switch(
              value: state.walletConfigChange.fold(
                  () => state.initialWalletConfig.supportedKinds
                      .contains(AddressV2Type.p2pkh),
                  (change) =>
                      change.supportedKinds.contains(AddressV2Type.p2pkh)),
              onChanged: (value) {
                context
                    .read<SettingsAdvancedBloc>()
                    .add(EnableP2PKHChanged(value));
              }))
    ]);
  }
}

class SettingsAdvanced extends StatelessWidget {
  const SettingsAdvanced({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsAdvancedBloc, SettingsAdvancedState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            children: [
              SettingsItem(
                title: 'Wallet Type',
                trailing: SizedBox(
                  width: 140,
                  height: 40,
                  child: HorizonRedesignDropdown<String>(
                    hintText: 'Select wallet type',
                    useModal: true,
                    onChanged: (value) {
                      context.read<SettingsAdvancedBloc>().add(
                            ImportFormatChanged(
                              ImportFormat.values
                                  .firstWhere((e) => e.name == value),
                            ),
                          );
                    },
                    items: ImportFormat.values
                        .map((importFormat) => DropdownMenuItem<String>(
                              value: importFormat.name,
                              child: Text(
                                importFormat
                                    .name, // or a prettier label if desired
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList(),
                    selectedValue: state.importFormatChange.isSome()
                        ? state.importFormatChange.getOrThrow().name
                        : state.inferredImportFormat
                            .map((f) => f.name)
                            .getOrElse(() => ""),
                  ),
                ),
              ),
              SettingsItem(
                  title: "Base Path",
                  trailing: state.walletConfigChange.fold(
                      () => Text(state.initialWalletConfig.basePath
                          .get(state.initialWalletConfig.network)),
                      (configChange) => Text(configChange.basePath
                          .get(state.initialWalletConfig.network)))),
              SettingsItem(
                  title: "Seed Derivation",
                  trailing: state.walletConfigChange.fold(
                      () => Text(state.initialWalletConfig.seedDerivation.name),
                      (configChange) =>
                          Text(configChange.seedDerivation.name))),
              if (kIsWeb)
                SettingsItem(
                  title: 'Export BLS Key',
                  onTap: () => _showExportBlsKeyFlow(context),
                ),
              state.importFormatChange.fold(
                  () => state.inferredImportFormat.fold(
                      () => const SizedBox.shrink(),
                      (inferredImportFormat) => switch (inferredImportFormat) {
                            ImportFormat.counterwallet =>
                              LegacyAddressTypeSettings(state: state),
                            ImportFormat.freewallet =>
                              LegacyAddressTypeSettings(state: state),
                            ImportFormat.horizon => const SizedBox.shrink(),
                          }),
                  (change) => switch (change) {
                        ImportFormat.counterwallet =>
                          LegacyAddressTypeSettings(state: state),
                        ImportFormat.freewallet =>
                          LegacyAddressTypeSettings(state: state),
                        ImportFormat.horizon => const SizedBox.shrink(),
                      }),
              const SizedBox(height: 40),
              state.walletConfigChange.fold(
                  () => const SizedBox.shrink(),
                  (walletConfig) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: HorizonButton(
                            disabled: state.walletConfigError.isSome(),
                            child: TextButtonContent(value: "Save Changes"),
                            onPressed: () {
                              context.read<SettingsAdvancedBloc>().add(
                                  SaveChangesClicked(onSuccess:
                                      (WalletConfig newWalletConfig) {
                                context
                                    .read<SessionStateCubit>()
                                    .onWalletConfigChanged(
                                      newWalletConfig,
                                    );
                              }));
                            }),
                      )),
              state.walletConfigError.fold(
                () => const SizedBox.shrink(),
                (error) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
