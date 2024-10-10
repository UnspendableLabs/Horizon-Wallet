import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_info;
import 'package:horizon/domain/entities/compose_issuance.dart'
    as compose_issuance;
import 'package:horizon/domain/entities/compose_send.dart' as compose_send;
import 'package:horizon/domain/entities/compose_dispenser.dart'
    as compose_dispenser;
import 'package:horizon/domain/entities/compose_dispense.dart'
    as compose_dispense;
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

import 'package:logger/logger.dart';


final logger = Logger();

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
  Future<compose_issuance.ComposeIssuanceResponseVerbose>
      composeIssuanceVerbose(
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
    return compose_issuance.ComposeIssuanceResponseVerbose(
        rawtransaction: txVerbose.rawtransaction,
        params: compose_issuance.ComposeIssuanceResponseVerboseParams(
          reset: txVerbose.params.reset,
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
  Future<compose_dispenser.ComposeDispenserResponseVerbose>
      composeDispenserVerbose(int fee, List<Utxo> inputsSet,
          compose_dispenser.ComposeDispenserParams params) async {
    final sourceAddress = params.source;
    final asset = params.asset;
    final giveQuantity = params.giveQuantity;
    final escrowQuantity = params.escrowQuantity;
    final mainchainrate = params.mainchainrate;
    final status = params.status ?? 0;
    const openAddress = null;
    const oracleAddress = null;
    const allowUnconfirmedTx = true;

    final inputsSetString =
        inputsSet.map((e) => "${e.txid}:${e.vout}").join(',');

    final response = await api.composeDispenserVerbose(
        sourceAddress,
        asset,
        giveQuantity,
        escrowQuantity,
        mainchainrate,
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
    return compose_dispenser.ComposeDispenserResponseVerbose(
        rawtransaction: txVerbose.rawtransaction,
        btcIn: txVerbose.btcIn,
        btcOut: txVerbose.btcOut,
        btcChange: txVerbose.btcChange,
        btcFee: txVerbose.btcFee,
        data: txVerbose.data,
        params: compose_dispenser.ComposeDispenserResponseVerboseParams(
          source: txVerbose.params.source,
          asset: txVerbose.params.asset,
          giveQuantity: txVerbose.params.giveQuantity,
          escrowQuantity: txVerbose.params.escrowQuantity,
          mainchainrate: txVerbose.params.mainchainrate,
          status: txVerbose.params.status,
          openAddress: txVerbose.params.openAddress,
          oracleAddress: txVerbose.params.oracleAddress,
          giveQuantityNormalized: txVerbose.params.giveQuantityNormalized,
          escrowQuantityNormalized: txVerbose.params.escrowQuantityNormalized,
        ),
        name: txVerbose.name);
  }

  @override
  Future<compose_dispense.ComposeDispenseResponse> composeDispense(
      int fee,
      List<Utxo> inputsSet,
      compose_dispense.ComposeDispenseParams params) async {
    final sourceAddress = params.address;
    final dispenser = params.dispenser;
    final quantity = params.quantity;
    const allowUnconfirmedTx = true;

    

    final inputsSetString =
        inputsSet.map((e) => "${e.txid}:${e.vout}").join(',');

    logger.e("""

      address: $sourceAddress,
      dispenser: $dispenser,
      quantity: $quantity



    """);

    final response = await api.composeDispense(sourceAddress, dispenser,
        quantity, allowUnconfirmedTx, fee, inputsSetString);

    if (response.result == null) {
      throw Exception('Failed to compose dispense');
    }

    return response.result!.toDomain();
  }
}
