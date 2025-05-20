import 'package:flutter/material.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import "./bloc/settings_advanced_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';

import "../settings_view.dart" show SettingsItem;

class SettingsAdvancedProvider extends StatelessWidget {
  final WalletConfigRepository _walletConfigRepository;
  Widget child;

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
                      print("value $value");
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
    return const Center(
      child: Text("Advanced settings"),
    );
  }
}
