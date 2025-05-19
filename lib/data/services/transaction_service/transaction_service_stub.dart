// data/services/transaction_service_stub.dart

import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/utxo.dart';

class TransactionServiceStub implements TransactionService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
          [List<int>? sighashTypes]) =>
      _unsupported('signPsbt');

  @override
  String psbtToUnsignedTransactionHex(String psbtHex) =>
      _unsupported('psbtToUnsignedTransactionHex');

  @override
  String signMessage(String message, String privateKey) =>
      _unsupported('signMessage');

  @override
  Future<String> signTransaction(
          String unsignedTransaction,
          String privateKey,
          String sourceAddress,
          Map<String, Utxo> utxoMap) =>
      Future.error(_unsupported('signTransaction'));

  @override
  int getVirtualSize(String unsignedTransaction) =>
      _unsupported('getVirtualSize');

  @override
  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
  }) =>
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
  Future<String> constructChainAndSignTransaction({
    required String unsignedTransaction,
    required String sourceAddress,
    required List<Utxo> utxos,
    required int btcQuantity,
    required String sourcePrivKey,
    required String destinationAddress,
    required String destinationPrivKey,
    required num fee,
  }) =>
      Future.error(_unsupported('constructChainAndSignTransaction'));

  @override
  Future<MakeRBFResponse> makeRBF({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
  }) =>
      Future.error(_unsupported('makeRBF'));
}

TransactionService createTransactionServiceImpl({
   required Config config
  }) => TransactionServiceStub();

