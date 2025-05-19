import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import "package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_event.dart";
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_state.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';

class ImportAddressPkBloc
    extends Bloc<ImportAddressPkEvent, ImportAddressPkState> {
  final EncryptionService _encryptionService;
  final ImportedAddressRepository _importedAddressRepository;
  final ImportedAddressService _importedAddressService;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final HttpConfig httpConfig;
  final MnemonicRepository _mnemonicRepository;

  ImportAddressPkBloc(
      {required this.httpConfig,
      ImportedAddressRepository? importedAddressRepository,
      InMemoryKeyRepository? inMemoryKeyRepository,
      ImportedAddressService? importedAddressService,
      EncryptionService? encryptionService,
      MnemonicRepository? mnemonicRepository})
      : _importedAddressRepository =
            importedAddressRepository ?? GetIt.I<ImportedAddressRepository>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _importedAddressService =
            importedAddressService ?? GetIt.I<ImportedAddressService>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _mnemonicRepository =
            mnemonicRepository ?? GetIt.I<MnemonicRepository>(),
        super(ImportAddressPkInitial()) {
    on<Submit>((event, emit) async {
      final task = TaskEither<String, ImportedAddress>.Do(($) async {
        // TODO: abstract password check into authservice
        await $(_mnemonicRepository
            .getT(
              onError: (_, __) => "invariant: could not read mnemonic",
            )
            .flatMap(
              (m) => TaskEither.fromOption(
                m,
                () => "invariant: mnemonic is null",
              ),
            )
            .flatMap((encryptedMnemonic) => _encryptionService.decryptT(
                  data: encryptedMnemonic,
                  password: event.password,
                  onError: (_, __) => "Invalid password",
                )));

        // this is a good check to make sure that network and
        // wif are compatible
        await $(_importedAddressService.getAddressFromWIFT(
            wif: event.wif,
            format: event.format,
            network: httpConfig.network,
            onError: (err, __) => "Error importing WIF: $err"));

        final encryptedWIF = await $(_encryptionService.encryptT(
            data: event.wif,
            password: event.password,
            onError: (_, __) => "Error encrypting WIF"));

        final decryptionKey = await $(_encryptionService.getDecryptionKeyT(
            data: encryptedWIF,
            password: event.password,
            onError: (_, __) => "Error getting WIF decryption key"));

        await $(_inMemoryKeyRepository
            .getMapT(
              onError: (_, __) => "Error getting in-memory key map",
            )
            .flatMap((map) => _inMemoryKeyRepository.setMapT(
                  // TODO: make sure this lookup is consistent everywhere
                  map: {...map, encryptedWIF: decryptionKey},
                  onError: (_, __) => "Error setting in-memory key map",
                )));

        // TODO: we want to actualy store the format here
        await $(
          _importedAddressRepository.insertT(
            address: ImportedAddress(
              encryptedWif: encryptedWIF,
              network: httpConfig.network,
            ),
            onError: (_, __) => "Error saving imported address",
          ),
        );

        return ImportedAddress(
          encryptedWif: encryptedWIF,
          network: httpConfig.network,
        );
      });

      final result = await task.run();

      result.fold(
        (l) => emit(ImportAddressPkError(l)),
        (r) => emit(ImportAddressPkSuccess(r)),
      );
    });
  }
}
