// data/services/transaction_service_stub.dart

import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/utxo.dart';
import "package:horizon/domain/entities/http_config.dart";

class TransactionServiceStub implements TransactionService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
          HttpConfig config,
          [List<int>? sighashTypes]) =>
      _unsupported('signPsbt');

  @override
  String psbtToUnsignedTransactionHex(String psbtHex) =>
      _unsupported('psbtToUnsignedTransactionHex');

  @override
  String signMessage(String message, String privateKey, HttpConfig config) =>
      _unsupported('signMessage');

  @override
  Future<String> signTransaction(String unsignedTransaction, String privateKey,
          String sourceAddress, Map<String, Utxo> utxoMap, HttpConfig config) =>
      Future.error(_unsupported('signTransaction'));

  @override
  int getVirtualSize(String unsignedTransaction) =>
      _unsupported('getVirtualSize');

  @override
  bool validateBTCAmount(
          {required String rawtransaction,
          required String source,
          required int expectedBTC,
          required HttpConfig httpConfig}) =>
      _unsupported('validateBTCAmount');

  @override
  bool validateFee({
    required String rawtransaction,
    required int expectedFee,
    required Map<String, Utxo> utxoMap,
  }) =>
      _unsupported('validateFee');

  @override
  int countSigOps({required String rawtransaction}) =>
      _unsupported('countSigOps');

  @override
  Future<String> constructChainAndSignTransaction(
          {required String unsignedTransaction,
          required String sourceAddress,
          required List<Utxo> utxos,
          required int btcQuantity,
          required String sourcePrivKey,
          required String destinationAddress,
          required String destinationPrivKey,
          required num fee,
          required HttpConfig httpConfig}) =>
      Future.error(_unsupported('constructChainAndSignTransaction'));

  @override
  Future<MakeRBFResponse> makeRBF(
          {required String source,
          required String txHex,
          required num oldFee,
          required num newFee,
          required HttpConfig httpConfig}) =>
      Future.error(_unsupported('makeRBF'));
}

TransactionService createTransactionServiceImpl() => TransactionServiceStub();
