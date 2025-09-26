import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import "package:equatable/equatable.dart";
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

abstract class SettingsAdvancedEvent {}

// class SettingsAdvancedLoaded extends SettingsAdvancedEvent {}

class ImportFormatChanged extends SettingsAdvancedEvent {
  final ImportFormat importFormat;
  ImportFormatChanged(this.importFormat);
}

class SaveChangesClicked extends SettingsAdvancedEvent {
  void Function(WalletConfig config)? onSuccess;

  SaveChangesClicked({this.onSuccess});
}

class EnableP2PKHChanged extends SettingsAdvancedEvent {
  final bool value;
  EnableP2PKHChanged(this.value);
}

class SettingsAdvancedState extends Equatable {
  final WalletConfig initialWalletConfig;
  final Option<ImportFormat> importFormatChange;
  final Option<WalletConfig> walletConfigChange;
  final Option<String> walletConfigError;
  final Option<bool> enableP2PKHChange;

  final FormzSubmissionStatus status;

  const SettingsAdvancedState(
      {required this.initialWalletConfig,
      this.status = FormzSubmissionStatus.initial,
      this.importFormatChange = const Option.none(),
      this.walletConfigChange = const Option.none(),
      this.enableP2PKHChange = const Option.none(),
      this.walletConfigError = const Option.none()});

  SettingsAdvancedState copyWith({
    WalletConfig? initialWalletConfig,
    FormzSubmissionStatus? status,
    Option<ImportFormat>? importFormatChange,
    Option<WalletConfig>? walletConfigChange,
    Option<String>? walletConfigError,
    Option<bool>? enableP2PKHChange,
  }) {
    return SettingsAdvancedState(
      initialWalletConfig: initialWalletConfig ?? this.initialWalletConfig,
      status: status ?? this.status,
      importFormatChange: importFormatChange ?? this.importFormatChange,
      walletConfigChange: walletConfigChange ?? this.walletConfigChange,
      walletConfigError: walletConfigError ?? this.walletConfigError,
      enableP2PKHChange: enableP2PKHChange ?? this.enableP2PKHChange,
    );
  }

  @override
  List<Object?> get props => [
        status,
        importFormatChange,
        walletConfigChange,
        enableP2PKHChange,
        walletConfigError
      ];

  Option<ImportFormat> get inferredImportFormat {
    return switch ((
      initialWalletConfig.basePath.serialize(),
      initialWalletConfig.seedDerivation
    )) {
      (BasePath.horizonSerialized, SeedDerivation.bip39MnemonicToSeed) =>
        const Option.of(ImportFormat.horizon),
      (BasePath.legacySerialized, SeedDerivation.bip39MnemonicToEntropy) =>
        const Option.of(ImportFormat.freewallet),
      (BasePath.legacySerialized, SeedDerivation.mnemonicJSToHex) =>
        const Option.of(ImportFormat.counterwallet),
      _ => const Option.none(),
    };
  }
}

class SettingsAdvancedBloc
    extends Bloc<SettingsAdvancedEvent, SettingsAdvancedState> {
  final WalletConfigRepository _walletConfigRepository;
  final MnemonicRepository _mnemonicRepository;
  final EncryptionService _encryptionService;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final SeedService _seedService;

  SettingsAdvancedBloc({
    required WalletConfig walletConfig,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _encryptionService = GetIt.I<EncryptionService>(),
        _mnemonicRepository = GetIt.I<MnemonicRepository>(),
        _inMemoryKeyRepository = GetIt.I<InMemoryKeyRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        super(SettingsAdvancedState(initialWalletConfig: walletConfig)) {
    on<ImportFormatChanged>(_handleImportFormatChanged);
    on<SaveChangesClicked>(_handleSaveChangesClicked);
    on<EnableP2PKHChanged>(_handleEnableP2PKHChanged);
  }

  _handleEnableP2PKHChanged(EnableP2PKHChanged event, emit) {
    final base =
        state.walletConfigChange.getOrElse(() => state.initialWalletConfig);

    final walletSupportsP2PKH =
        base.supportedKinds.contains(AddressV2Type.p2pkh);

    Option<bool> enableP2PKHChange = walletSupportsP2PKH == event.value
        ? const Option.none()
        : Option.of(event.value);

    Option<WalletConfig> walletConfigChange =
        enableP2PKHChange.fold(() => const Option.none(), (enableP2PKHChange) {
      final supportedKindsChange = Set<AddressV2Type>.from(base.supportedKinds);

      if (enableP2PKHChange) {
        supportedKindsChange.add(AddressV2Type.p2pkh);
      } else {
        supportedKindsChange.remove(AddressV2Type.p2pkh);
      }

      final change = base.copyWith(supportedKinds: supportedKindsChange);

      return change == state.initialWalletConfig
          ? const Option.none()
          : Option.of(change);
    });

    emit(state.copyWith(
      enableP2PKHChange: enableP2PKHChange,
      walletConfigChange: walletConfigChange,
    ));
  }

  _handleImportFormatChanged(ImportFormatChanged event, emit) async {
    Option<ImportFormat> importFormatChange = state.inferredImportFormat
        .flatMap((inferredImportFormat) =>
            inferredImportFormat == event.importFormat
                ? const Option.none()
                : Option.of(event.importFormat));

    Option<WalletConfig> walletConfigChange =
        importFormatChange.map<WalletConfig>((importFormatChange) {
      final current = state.initialWalletConfig;

      final basePathChange = switch (importFormatChange) {
        ImportFormat.horizon => BasePath.horizon,
        ImportFormat.counterwallet => BasePath.legacy,
        ImportFormat.freewallet => BasePath.legacy,
      };

      final seedDerivationChange = switch (importFormatChange) {
        ImportFormat.horizon => SeedDerivation.bip39MnemonicToSeed,
        ImportFormat.counterwallet => SeedDerivation.mnemonicJSToHex,
        ImportFormat.freewallet => SeedDerivation.bip39MnemonicToEntropy,
      };

      final supportedKindsChange = basePathChange.defaultKinds();

      final change = current.copyWith(
        basePath: basePathChange,
        seedDerivation: seedDerivationChange,
        supportedKinds: supportedKindsChange,
      );

      return change;
    });

    final walletConfigError = await walletConfigChange
        .map((cfg) => _seedService.getForWalletConfigT(
            onError: (err) => "invariant: no seed for wallet config",
            walletConfig: cfg,
            decryptionStrategy: InMemoryKey()))
        .map((taskEither) => taskEither.swap().run().then(Option.fromEither))
        .getOrElse(() => Future.value(const Option.none()));

    emit(state.copyWith(
      importFormatChange: importFormatChange,
      walletConfigChange: walletConfigChange,
      walletConfigError: walletConfigError,
    ));
  }

  _handleSaveChangesClicked(
      SaveChangesClicked event, Emitter<SettingsAdvancedState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    await TaskEither.fromOption(state.walletConfigChange,
            () => "invariant: walletConfigChange is None")
        .flatMap((walletConfigChange) => TaskEither.tryCatch(
            () => _walletConfigRepository.createOrUpdate(walletConfigChange),
            (_, __) => "Error updating wallet config"))
        .match(
      (error) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
        ));
      },
      (WalletConfig newWallet) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          // walletConfigChange:
          //     const Option.none(), // Clear after successful save
        ));

        if (event.onSuccess != null) {

          event.onSuccess!(newWallet);
        } else {
        }
      },
    ).run();
  }
}
