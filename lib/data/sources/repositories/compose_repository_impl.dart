import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_info;
import 'package:horizon/domain/entities/compose_issuance.dart'
    as compose_issuance;
import 'package:horizon/domain/entities/compose_send.dart' as compose_send;
import 'package:horizon/domain/entities/raw_transaction.dart';
import 'package:horizon/domain/entities/utxo.dart';

import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:fpdart/fpdart.dart';

class InvalidUtxoError {
  final String txHash;
  final int outputIndex;

  InvalidUtxoError(this.txHash, this.outputIndex);
}

class ComposeRepositoryImpl extends ComposeRepository {
  final V2Api api;

  ComposeRepositoryImpl({required this.api});

  @override
  Future<RawTransaction> composeSend(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx, int? fee]) async {
    final response = await api.composeSend(
        sourceAddress, destination, asset, quantity, allowUnconfirmedTx, fee);

    if (response.result == null) {
      throw Exception('Failed to compose send');
    }
    return RawTransaction(hex: response.result!.rawtransaction);
  }

  @override
  Future<compose_send.ComposeSend> composeSendVerbose(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx,
      int? fee,
      int? feeRate,
      List<Utxo>? inputsSet]) async {
    final inputsSetString =
        inputsSet?.map((e) => "${e.txid}:${e.vout}").join(',');

    final response = await api.composeSendVerbose(sourceAddress, destination,
        asset, quantity, allowUnconfirmedTx, fee, feeRate, inputsSetString);

    if (response.result == null) {
      throw Exception('Failed to compose send');
    }

    final txVerbose = response.result!;
    return compose_send.ComposeSend(
        params: compose_send.ComposeSendParams(
          source: txVerbose.params.source,
          destination: txVerbose.params.destination,
          asset: txVerbose.params.asset,
          quantity: txVerbose.params.quantity,
          useEnhancedSend: txVerbose.params.useEnhancedSend,
          assetInfo: asset_info.AssetInfo(
              assetLongname: txVerbose.params.assetInfo.assetLongname,
              description: txVerbose.params.assetInfo.description,
              divisible: txVerbose.params.assetInfo.divisible),
          quantityNormalized: txVerbose.params.quantityNormalized,
        ),
        rawtransaction: txVerbose.rawtransaction,
        name: txVerbose.name);
  }

  @override
  Future<compose_issuance.ComposeIssuance> composeIssuance(
      String sourceAddress, String name, int quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination]) async {
    print("\n\n\n\ regular");
    final response = await api.composeIssuance(sourceAddress, name, quantity,
        transferDestination, divisible, lock, reset, description, true);
    if (response.result == null) {
      throw Exception('Failed to compose issuance');
    }
    return compose_issuance.ComposeIssuance(
        rawtransaction: response.result!.rawtransaction,
        params: compose_issuance.ComposeIssuanceParams(
            source: sourceAddress,
            asset: name,
            quantity: quantity,
            divisible: divisible,
            lock: lock,
            description: description,
            transferDestination: transferDestination),
        name: name);
  }

  @override
  Future<compose_issuance.ComposeIssuanceVerbose> composeIssuanceVerbose(
    String sourceAddress,
    String name,
    int quantity, [
    bool? divisible,
    bool? lock,
    bool? reset,
    String? description,
    String? transferDestination,
    bool? unconfirmed,
    int? fee,
    List<Utxo>? inputsSet,
  ]) async {
    print("\n\n\n\ verbose");
    try {
      if (inputsSet != null && inputsSet.isEmpty) {
        throw Exception('Balance is too low');
      }

      final inputsSetString =
          inputsSet?.map((e) => "${e.txid}:${e.vout}").join(',');
      final response = await api.composeIssuanceVerbose(
          sourceAddress,
          name,
          quantity,
          transferDestination,
          divisible,
          lock,
          reset,
          description,
          unconfirmed,
          fee,
          inputsSetString);

      if (response.result == null) {
        throw Exception('Failed to compose issuance');
      }

      final txVerbose = response.result!;
      return compose_issuance.ComposeIssuanceVerbose(
          rawtransaction: txVerbose.rawtransaction,
          params: compose_issuance.ComposeIssuanceVerboseParams(
            source: txVerbose.params.source,
            asset: txVerbose.params.asset,
            quantity: txVerbose.params.quantity,
            divisible: txVerbose.params.divisible,
            lock: txVerbose.params.lock,
            description: description,
            transferDestination: transferDestination,
            quantityNormalized: txVerbose.params.quantityNormalized,
          ),
          name: name);
    } catch (e) {
      final maybeInvalidUtxoError = extractInvalidUtxoError(e.toString());

      return maybeInvalidUtxoError
          .fold(() => throw Exception('Failed to compose issuance'), (error) {
        return composeIssuanceVerbose(
            sourceAddress,
            name,
            quantity,
            divisible,
            lock,
            reset,
            description,
            transferDestination,
            unconfirmed,
            fee,
            removeUtxoFromList(inputsSet!, error.txHash, error.outputIndex));
      });
    }
  }
}

Option<InvalidUtxoError> extractInvalidUtxoError(String errorMessage) {
  final RegExp regex = RegExp(r'invalid UTXO: ([a-fA-F0-9]{64}):(\d+)');
  final match = regex.firstMatch(errorMessage);

  return Option.fromNullable(match).map((m) {
    final txHash = m.group(1)!;
    final outputIndex = int.parse(m.group(2)!);
    return InvalidUtxoError(txHash, outputIndex);
  });
}

List<Utxo> removeUtxoFromList(
    List<Utxo> inputSet, String txidToRemove, int voutToRemove) {
  print("remove utxo from list");
  return inputSet
      .where(
          (utxo) => !(utxo.txid == txidToRemove && utxo.vout == voutToRemove))
      .toList();
}
