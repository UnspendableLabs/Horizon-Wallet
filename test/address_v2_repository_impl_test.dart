import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:horizon/data/sources/repositories/address_v2_repository_impl.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/repositories/account_configurations_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/seed_service.dart';

class MockWalletConfigRepository extends Mock
    implements WalletConfigRepository {}

class MockAddressService extends Mock implements AddressService {}

class MockSeedService extends Mock implements SeedService {}

class MockImportedAddressRepository extends Mock
    implements ImportedAddressRepository {}

class MockImportedAddressService extends Mock
    implements ImportedAddressService {}

class MockAccountConfigurationsRepository extends Mock
    implements AccountConfigurationsRepository {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

const compressed =
    "02f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9";
const xOnly = "f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9";

void main() {
  late MockImportedAddressRepository importedAddressRepository;
  late MockImportedAddressService importedAddressService;
  late MockInMemoryKeyRepository inMemoryKeyRepository;
  late MockEncryptionService encryptionService;
  late AddressV2RepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(Network.mainnet);
  });

  setUp(() {
    importedAddressRepository = MockImportedAddressRepository();
    importedAddressService = MockImportedAddressService();
    inMemoryKeyRepository = MockInMemoryKeyRepository();
    encryptionService = MockEncryptionService();
    repository = AddressV2RepositoryImpl(
      walletConfigRepository: MockWalletConfigRepository(),
      addressService: MockAddressService(),
      seedService: MockSeedService(),
      importedAddressRepository: importedAddressRepository,
      importedAddressService: importedAddressService,
      accountConfigurationsRepository: MockAccountConfigurationsRepository(),
      inMemoryKeyRepository: inMemoryKeyRepository,
      encryptionService: encryptionService,
    );

    when(() => inMemoryKeyRepository.getMap())
        .thenAnswer((_) async => {"encrypted-wif": "decryption-key"});
    when(() => encryptionService.decryptWithKey("encrypted-wif", "decryption-key"))
        .thenAnswer((_) async => "wif");
    when(() => importedAddressService.getAddressPublicKeyFromWIF(
            wif: "wif", network: any(named: "network")))
        .thenAnswer((_) async => compressed);
  });

  group("publicKeyForType", () {
    test("keeps the compressed key for P2WPKH and P2PKH, x-only for P2TR", () {
      expect(publicKeyForType(compressed, AddressV2Type.p2wpkh), compressed);
      expect(publicKeyForType(compressed, AddressV2Type.p2pkh), compressed);
      expect(publicKeyForType(compressed, AddressV2Type.p2tr), xOnly);
      // already x-only: unchanged
      expect(publicKeyForType(xOnly, AddressV2Type.p2tr), xOnly);
    });
  });

  group("importedAddressType", () {
    test("recognizes the address encoding", () {
      expect(importedAddressType("bc1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej"),
          AddressV2Type.p2wpkh);
      expect(importedAddressType("tb1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej"),
          AddressV2Type.p2wpkh);
      expect(
          importedAddressType(
              "bc1pvqks06mnslxdrwf7x6l6s02s92yx5cxt94gg3pw4gtv0455jj6csnc99dt"),
          AddressV2Type.p2tr);
      expect(
          importedAddressType(
              "tb1pvqks06mnslxdrwf7x6l6s02s92yx5cxt94gg3pw4gtv0455jj6csnc99dt"),
          AddressV2Type.p2tr);
      expect(importedAddressType("1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2"),
          AddressV2Type.p2pkh);
    });
  });

  group("getByAccount on an imported WIF", () {
    test("fills the compressed public key of a P2WPKH address", () async {
      final set = await repository.getByAccount(ImportedWIF(
        network: Network.mainnet,
        address: "bc1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej",
        encryptedWIF: "encrypted-wif",
      ));

      final address = set.list.single;
      expect(address.type, AddressV2Type.p2wpkh);
      expect(address.publicKey, compressed);
      expect(address.derivation, isA<WIF>());
      verify(() => importedAddressService.getAddressPublicKeyFromWIF(
          wif: "wif", network: Network.mainnet)).called(1);
    });

    test("fills the x-only public key of a P2TR address", () async {
      final set = await repository.getByAccount(ImportedWIF(
        network: Network.mainnet,
        address:
            "bc1pvqks06mnslxdrwf7x6l6s02s92yx5cxt94gg3pw4gtv0455jj6csnc99dt",
        encryptedWIF: "encrypted-wif",
      ));

      final address = set.list.single;
      expect(address.type, AddressV2Type.p2tr);
      expect(address.publicKey, xOnly);
    });

    test("fails instead of returning an empty key", () async {
      when(() => inMemoryKeyRepository.getMap()).thenAnswer((_) async => {});

      expect(
          () => repository.getByAccount(ImportedWIF(
                network: Network.mainnet,
                address: "bc1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej",
                encryptedWIF: "encrypted-wif",
              )),
          throwsA(isA<Exception>()));
    });
  });

  group("getAllImported", () {
    test("uses one public key format per address type", () async {
      when(() => importedAddressRepository.getAll()).thenAnswer((_) async => [
            const ImportedAddress(
              address: "bc1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej",
              type: AddressV2Type.p2wpkh,
              network: Network.mainnet,
              encryptedWif: "encrypted-wif",
            ),
            const ImportedAddress(
              address:
                  "bc1pvqks06mnslxdrwf7x6l6s02s92yx5cxt94gg3pw4gtv0455jj6csnc99dt",
              type: AddressV2Type.p2tr,
              network: Network.mainnet,
              encryptedWif: "encrypted-wif",
            ),
          ]);

      final addresses = await repository.getAllImported();
      expect(addresses.map((a) => a.publicKey), [compressed, xOnly]);
    });
  });
}
