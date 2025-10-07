import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/utxo.dart';

// {
//      "tx_hash": "fe207d05cd6d680f68161dcbdd5353d83e07fa20c6d4390268fa90b544e1fd10",
//      "event": "ATTACH_TO_UTXO",
//      "params": {
//        "asset": "A1101615775224090282",
//        "block_index": 9999999,
//        "destination": "fe207d05cd6d680f68161dcbdd5353d83e07fa20c6d4390268fa90b544e1fd10:0",
//        "destination_address": "tb1q4zepxe42rkhq00l72tzk73seuqw9ydckgynzv5",
//        "fee_paid": 0,
//        "msg_index": 0,
//        "quantity": 10,
//        "send_type": "attach",
//        "source": "tb1q4zepxe42rkhq00l72tzk73seuqw9ydckgynzv5",
//        "status": "valid",
//        "tx_hash": "fe207d05cd6d680f68161dcbdd5353d83e07fa20c6d4390268fa90b544e1fd10",
//        "tx_index": 1147
//      },
//      "timestamp": 1759849666.94698
//    },

class UtxoAttach {
  final String address;
  final String asset;
  final AssetQuantity quantity;
  final UtxoID id;
  final DateTime createdAt;

  UtxoAttach({
    required this.address,
    required this.asset,
    required this.quantity,
    required this.id,
    required this.createdAt,
  });
}
