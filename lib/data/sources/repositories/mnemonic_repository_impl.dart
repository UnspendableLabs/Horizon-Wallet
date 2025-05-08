import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import "package:fpdart/fpdart.dart";

class MnemonicRepositoryImpl implements MnemonicRepository {
  // TODO: these keys should be centralized somewhere to ensure uniqueness
  final _key = '__ENCRYPTED_MNEMONIC';

  final SecureKVService secureKVService;

  MnemonicRepositoryImpl({required this.secureKVService});

  @override
  Task<Option<String>> get()  {
    return Task(() => secureKVService.read(key: _key)).map(Option.fromNullable);
  }

  @override
  Future<void> set({required String encryptedMnemonic}) async {
    return await secureKVService.write(key: _key, value: encryptedMnemonic);
  }

  @override
  Future<void> delete() async {
    await secureKVService.delete(key: _key);
  }
}
