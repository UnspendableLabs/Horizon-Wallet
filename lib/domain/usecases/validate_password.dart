import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/decryption_strategy.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:horizon/domain/services/encryption_service.dart";
import "package:horizon/domain/services/seed_service.dart";

import "./usecase.dart";
export "./usecase.dart";

class ValidatePasswordUseCase implements UseCase<bool, String> {
  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;

  ValidatePasswordUseCase({
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    EncryptionService? encryptionService,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>();

  @override
  Future<bool> call(String password) async {
    final TaskEither<String, Unit> validatePassword = _walletConfigRepository
        .getCurrentT((_) => "invariant: could not read wallet config")
        .flatMap((walletConfig) => _seedService
            .getForWalletConfigT(
                walletConfig: walletConfig,
                decryptionStrategy: Password(password),
                onError: (_) => "invalid password")
            .map((_) => unit));

    final result = await validatePassword.run();

    return result.fold(
      (_) => false,
      (_) => true,
    );
  }
}
