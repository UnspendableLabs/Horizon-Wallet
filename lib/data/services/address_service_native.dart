import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/common/constants.dart';

import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:bitcoin_base/bitcoin_base.dart';

class AddressServiceImplNative implements AddressService {
  final Config config;

  AddressServiceImplNative({required this.config});

  @override
  Future<Address> deriveAddressSegwit(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index}) async {
    // final String basePath = 'm/84\'/1\'/0\'/0/';

    print("native called");
    String path = 'm/$purpose/$coin/$account/$change/$index';

    ECPrivate privateKey = ECPrivate.fromHex(privKey);

    Bip32Slip10Secp256k1 bip32 = Bip32Slip10Secp256k1.fromPrivateKey(
        privateKey.toBytes(),
        keyData: Bip32KeyData(
            chainCode: Bip32ChainCode(BytesUtils.fromHexString(chainCodeHex))),
        keyNetVer: Bip84Conf.bitcoinTestNet.keyNetVer);

    final child = bip32.derivePath(path);

    final address = P2WPKHAddrEncoder().encodeKey(
        child.publicKey.compressed, Bip84Conf.bitcoinTestNet.addrParams);

    print("about to print index and account uuid");
    print("address: $address");
    print("about to print index and account uuid");
    print("index: $index");
    print("Account UUID: $accountUuid");

    return Address(
      address: address,
      accountUuid: accountUuid,
      index: index,
    );
  }

  @override
  Future<Address> deriveAddressFreewallet(
      {required AddressType type,
      required dynamic root,
      required String accountUuid,
      required String account,
      required String change,
      required int index}) async {
    throw Exception("Not implemented");
  }

  @override
  Future<List<Address>> deriveAddressSegwitRange(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int start,
      required int end}) async {
    List<Future<Address>> futures = List.generate(
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
    );

    return await Future.wait(futures);
  }

  Future<List<Address>> deriveAddressFreewalletRange(
      {required AddressType type,
      required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String account,
      required String change,
      required int start,
      required int end}) {
    throw Exception("Not implemented");
  }

  Future<String> deriveAddressPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  }) {
    throw Exception("Not implemented");
  }

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
    throw Exception("Not implemented");
  }
}
