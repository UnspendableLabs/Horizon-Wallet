import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/entities/address.dart';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:bitcoin_base/bitcoin_base.dart';

class AddressServiceNative implements AddressService {
  final Config config;

  AddressServiceNative({required this.config});

  @override
  Future<Address> deriveAddressSegwit({
    required String privKey,
    required String chainCodeHex,
    required String accountUuid,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
  }) async {
    final path = 'm/$purpose/$coin/$account/$change/$index';
    final privateKey = ECPrivate.fromHex(privKey);

    final bip32 = Bip32Slip10Secp256k1.fromPrivateKey(privateKey.toBytes(),
        keyData: Bip32KeyData(
          chainCode: Bip32ChainCode(BytesUtils.fromHexString(chainCodeHex)),
        ),
        keyNetVer: _getKeyNetVer());

    final child = bip32.derivePath(path);
    final address = P2WPKHAddrEncoder().encodeKey(
      child.publicKey.compressed,
      _getAddrParams(),
    );

    return Address(
      address: address,
      accountUuid: accountUuid,
      index: index,
    );
  }

  @override
  Future<Address> deriveAddressFreewallet({
    required AddressType type,
    required dynamic root,
    required String accountUuid,
    required String account,
    required String change,
    required int index,
  }) {
    throw UnimplementedError(
      '[AddressServiceNative] deriveAddressFreewallet() is not implemented for native platform.',
    );
  }

  @override
  Future<List<Address>> deriveAddressSegwitRange({
    required String privKey,
    required String chainCodeHex,
    required String accountUuid,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int start,
    required int end,
  }) async {
    return Future.wait(
      List.generate(
        end - start + 1,
        (i) => deriveAddressSegwit(
          privKey: privKey,
          chainCodeHex: chainCodeHex,
          accountUuid: accountUuid,
          purpose: purpose,
          coin: coin,
          account: account,
          change: change,
          index: start + i,
        ),
      ),
    );
  }

  @override
  Future<List<Address>> deriveAddressFreewalletRange({
    required AddressType type,
    required String privKey,
    required String chainCodeHex,
    required String accountUuid,
    required String account,
    required String change,
    required int start,
    required int end,
  }) {
    throw UnimplementedError(
      '[AddressServiceNative] deriveAddressFreewalletRange() is not implemented for native platform.',
    );
  }

  @override
  Future<String> deriveAddressPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  }) async {
    String path = _getPathForImportFormat(
        purpose: purpose,
        coin: coin,
        account: account,
        change: change,
        index: index,
        importFormat: importFormat);

    final privateKey = ECPrivate.fromHex(rootPrivKey);

    final bip32 = Bip32Slip10Secp256k1.fromPrivateKey(privateKey.toBytes(),
        keyData: Bip32KeyData(
          chainCode: Bip32ChainCode(BytesUtils.fromHexString(chainCodeHex)),
        ),
        keyNetVer: _getKeyNetVer());

    final child = bip32.derivePath(path);

    return child.privateKey.toHex();
  }

  @override
  Future<String> getAddressWIFFromPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  }) {
    throw UnimplementedError(
      '[AddressServiceNative] getAddressWIFFromPrivateKey() is not implemented for native platform.',
    );
  }

  String _getPathForImportFormat(
          {required String purpose,
          required String coin,
          required String account,
          required String change,
          required int index,
          required ImportFormat importFormat}) =>
      switch (importFormat) {
        ImportFormat.horizon => 'm/$purpose/$coin/$account/$change/$index',
        _ => 'm/$account/$change/$index',
      };

  Bip32KeyNetVersions _getKeyNetVer() => switch (config.network) {
        Network.mainnet => Bip84Conf.bitcoinMainNet.keyNetVer,
        Network.testnet => Bip84Conf.bitcoinTestNet.keyNetVer,
        Network.testnet4 => Bip84Conf.bitcoinTestNet.keyNetVer,
        Network.regtest => throw UnimplementedError(
            'Regtest network is not supported in this implementation'),
      };

  Map<String, dynamic> _getAddrParams() => switch (config.network) {
        Network.mainnet => Bip84Conf.bitcoinMainNet.addrParams,
        Network.testnet => Bip84Conf.bitcoinTestNet.addrParams,
        Network.testnet4 => Bip84Conf.bitcoinTestNet.addrParams,
        Network.regtest => throw UnimplementedError(
            'Regtest network is not supported in this implementation'),
      };
}

AddressService createAddressServiceImpl({required Config config}) =>
    AddressServiceNative(config: config);
