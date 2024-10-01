import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_info;
import 'package:horizon/domain/entities/compose_issuance.dart'
    as compose_issuance;
import 'package:horizon/domain/entities/compose_send.dart' as compose_send;
import 'package:horizon/domain/entities/compose_dispenser.dart'
    as compose_dispenser;
import 'package:horizon/domain/entities/raw_transaction.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

class ComposeRepositoryImpl extends ComposeRepository {
  final V2Api api;

  ComposeRepositoryImpl({required this.api});


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
  }

  @override
  Future<compose_dispenser.ComposeDispenserVerbose> composeDispenserVerbose(
      String sourceAddress,
      String asset,
      int giveQuantity,
      int escrowQuantity,
      int mainchainRate,
      int status,
      [String? openAddress,
      String? oracleAddress,
      bool? allowUnconfirmedTx,
      int? fee,
      List<Utxo>? inputsSet]) async {
    final inputsSetString =
        inputsSet?.map((e) => "${e.txid}:${e.vout}").join(',');

    final response = await api.composeDispenserVerbose(
        sourceAddress,
        asset,
        giveQuantity,
        escrowQuantity,
        mainchainRate,
        status,
        openAddress,
        oracleAddress,
        allowUnconfirmedTx,
        fee,
        inputsSetString);

    if (response.result == null) {
      throw Exception('Failed to compose dispenser');
    }

    final txVerbose = response.result!;
    return compose_dispenser.ComposeDispenserVerbose(
        rawtransaction: txVerbose.rawtransaction,
        params: compose_dispenser.ComposeDispenserVerboseParams(
          source: txVerbose.params.source,
          asset: txVerbose.params.asset,
          giveQuantity: txVerbose.params.giveQuantity,
          escrowQuantity: txVerbose.params.escrowQuantity,
          mainchainRate: txVerbose.params.mainchainRate,
          status: txVerbose.params.status,
          openAddress: txVerbose.params.openAddress,
          oracleAddress: txVerbose.params.oracleAddress,
          giveQuantityNormalized: txVerbose.params.giveQuantityNormalized,
          escrowQuantityNormalized: txVerbose.params.escrowQuantityNormalized,
          btcIn: txVerbose.params.btcIn,
          btcOut: txVerbose.params.btcOut,
          btcChange: txVerbose.params.btcChange,
          btcFee: txVerbose.params.btcFee,
          data: txVerbose.params.data,
        ),
        name: txVerbose.name);
  }
}
