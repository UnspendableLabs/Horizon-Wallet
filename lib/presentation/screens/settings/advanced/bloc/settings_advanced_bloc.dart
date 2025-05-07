import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import "package:equatable/equatable.dart";
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';

abstract class SettingsAdvancedEvent {}

// class SettingsAdvancedLoaded extends SettingsAdvancedEvent {}

class SeedDerivationChanged extends SettingsAdvancedEvent {
  final SeedDerivation seedDerivation;
  SeedDerivationChanged(this.seedDerivation);
}

class SettingsAdvancedState extends Equatable {
  final WalletConfig initialWalletConfig;

  final FormzSubmissionStatus status;

  const SettingsAdvancedState({
    required this.initialWalletConfig,
    this.status = FormzSubmissionStatus.initial,
  });

  @override
  List<Object?> get props => [status];

  Option<ImportFormat> get inferredImportFormat {

  print("initialWalletConfig.basePath ${initialWalletConfig.basePath}");
  print("initialWalletConfig.seedDerivation ${initialWalletConfig.seedDerivation}");

   return   switch ((
        initialWalletConfig.basePath,
        initialWalletConfig.seedDerivation
      )) {
        (BasePath.horizonMainnet, SeedDerivation.bip39MnemonicToSeed) =>
          const Option.of(ImportFormat.horizon),
        (BasePath.horizonTestnet, SeedDerivation.bip39MnemonicToSeed) =>
          const Option.of(ImportFormat.horizon),
        (BasePath.legacy_, SeedDerivation.bip39MnemonicToEntropy) =>
          const Option.of(ImportFormat.freewallet),
        (BasePath.legacy_, SeedDerivation.mnemonicJSToHex) =>
          const Option.of(ImportFormat.counterwallet),
        _ => const Option.none(),
      };
  }
}

class SettingsAdvancedBloc
    extends Bloc<SettingsAdvancedEvent, SettingsAdvancedState> {
  final WalletConfigRepository _walletConfigRepository;

  SettingsAdvancedBloc({
    required WalletConfig walletConfig,
    WalletConfigRepository? walletConfigRepository,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        super(SettingsAdvancedState(initialWalletConfig: walletConfig)) {
    on<SeedDerivationChanged>(_handleSeedDerivationChanged);
  }

  _handleSeedDerivationChanged(event, emit) async {
    final current = _walletConfigRepository.getCurrent();
  }
}
