// import "./compose_response.dart";
import "package:horizon/domain/entities/asset_info.dart";
import "package:horizon/domain/entities/compose_response.dart";

import "./compose_fn.dart";

class ComposeAttachUtxoParams extends ComposeParams {
  final String address;
  final String asset;
  final int quantity;

  ComposeAttachUtxoParams({
    required this.address,
    required this.asset,
    required this.quantity,
  });

  @override
  List<Object> get props => [address, asset, quantity];
}
/**
 * {
        "result": {
            "params": {
                "source": "bcrt1q26zaczwkn20vzza2854zem5a3f8zgrpdddgekw",
                "asset": "XCP",
                "quantity": 1000,
                "destination_vout": null,
                "skip_validation": false,
                "asset_info": {
                    "asset_longname": null,
                    "description": "The Counterparty protocol native currency",
                    "issuer": null,
                    "divisible": true,
                    "locked": true
                },
                "quantity_normalized": "0.00001000"
            },
            "name": "attach",
            "data": "434e545250525459655843507c313030307c",
            "btc_in": 5000000000,
            "btc_out": 546,
            "btc_change": 4999984626,
            "btc_fee": 14828,
            "rawtransaction": "020000000001013dc80da59004277970fa9e192856e0e883104cb9321a00b91e4e544b68f16e36000000001600145685dc09d69a9ec10baa3d2a2cee9d8a4e240c2dffffffff0322020000000000001600145685dc09d69a9ec10baa3d2a2cee9d8a4e240c2d0000000000000000146a12b3e452486e7347ef130da3cb51d7673598aef2b5052a010000001600145685dc09d69a9ec10baa3d2a2cee9d8a4e240c2d02000000000000",
            "unpacked_data": {
                "message_type": "attach",
                "message_type_id": 101,
                "message_data": {
                    "asset": "XCP",
                    "quantity": 1000,
                    "destination_vout": null,
                    "quantity_normalized": "0.00001000"
                }
            }
        }
    }
 */

class ComposeAttachUtxoResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  final String data;
  final String name;

  final ComposeAttachUtxoResponseParams params;

  ComposeAttachUtxoResponse({
    required this.rawtransaction,
    required this.btcFee,
    required this.data,
    required this.name,
    required this.params,
  });
}

class ComposeAttachUtxoResponseParams {
  final String source;
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final String destinationVout;
  final AssetInfo assetInfo;

  ComposeAttachUtxoResponseParams(
      {required this.source,
      required this.asset,
      required this.quantity,
      required this.quantityNormalized,
      required this.destinationVout,
      required this.assetInfo});
}
