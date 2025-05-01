import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';

class SetMnemonicUseCase {
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final EncryptionService _encryptionService;
  final MnemonicRepository _mnemonicRepository;

  SetMnemonicUseCase({
    required InMemoryKeyRepository inMemoryKeyRepository,
    required EncryptionService encryptionService,
    required MnemonicRepository mnemonicRepository,
  })  : _mnemonicRepository = mnemonicRepository,
        _encryptionService = encryptionService,
        _inMemoryKeyRepository = inMemoryKeyRepository;

  /// Factory that pulls dependencies from GetIt.

  Future<void> call({
    required String mnemonic,
    required String password,
  }) async {
    final encryptedMnemonic =
        await _encryptionService.encrypt(mnemonic, password);

    final decryptionKey =
        await _encryptionService.getDecryptionKey(encryptedMnemonic, password);

    await _inMemoryKeyRepository.setMnemonicKey(key: decryptionKey);

    await _mnemonicRepository.set(encryptedMnemonic: encryptedMnemonic);
  }
}
