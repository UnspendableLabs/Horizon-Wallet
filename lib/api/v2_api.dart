import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'v2_api.g.dart';

// Domain

@JsonSerializable(genericArgumentFactories: true)
class Response<T> {
  final T result;

  Response({required this.result});

  factory Response.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ResponseFromJson(json, fromJsonT);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Block {
  final int blockIndex;
  final String blockHash;
  final DateTime blockTime;
  final String previousBlockHash;
  final double difficulty;
  final String ledgerHash;
  final String txlistHash;
  final String messagesHash;

  const Block(
      {required this.blockIndex,
      required this.blockTime,
      required this.blockHash,
      required this.previousBlockHash,
      required this.difficulty,
      required this.ledgerHash,
      required this.txlistHash,
      required this.messagesHash});

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction {
  final int txIndex;
  final String txlistHash;
  final int blockIndex;
  final String blockHash;
  final DateTime blockTime;
  final String source;
  final String destination;
  final double btcAmount;
  final int fee;
  final String data;
  final int supported;

  // final supported int; // TODO double check if this shoult be int or bool""

  const Transaction(
      {required this.txIndex,
      required this.txlistHash,
      required this.blockIndex,
      required this.blockHash,
      required this.blockTime,
      required this.source,
      required this.destination,
      required this.btcAmount,
      required this.fee,
      required this.data,
      required this.supported});

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Event {
  final int eventIndex;
  final String event;
  final dynamic params; // TODO: refine

  const Event({
    required this.eventIndex,
    required this.event,
    required this.params,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EventCount {
  final String event;
  final int eventCount;

  const EventCount({
    required this.event,
    required this.eventCount,
  });

  factory EventCount.fromJson(Map<String, dynamic> json) => _$EventCountFromJson(json);

}

 // {
 //                "block_index": 840464,
 //                "address": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
 //                "asset": "UNNEGOTIABLE",
 //                "quantity": 1,
 //                "calling_function": "issuance",
 //                "event": "876a6cfbd4aa22ba4fa85c2e1953a1c66649468a43a961ad16ea4d5329e3e4c5",
 //                "tx_index": 2726605,
 //                "asset_info": {
 //                    "asset_longname": null,
 //                    "description": "https://zawqddvy75sz6dwqllsrupumldqwi26kk3amlz4fqci7hrsuqcfq.arweave.net/yC0Bjrj_ZZ8O0FrlGj6MWOFka8pWwMXnhYCR88ZUgIs/UNNEG.json",
 //                    "issuer": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
 //                    "divisible": 0,
 //                    "locked": 1
 //                },
 //                "quantity_normalized": "1"
 //            }

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetInfo {
  final String assetLongname;
  final String description;
  final String? issuer;
  final int divisible;
  final int locked;
  const AssetInfo({
    required this.assetLongname,
    required this.description,
    required this.divisible,
    required this.locked,
    this.issuer, // TODO: validate shape 
  });
  factory AssetInfo.fromJson(Map<String, dynamic> json) => _$AssetInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Credit {
  final String blockIndex;
  final String address;
  final String asset;
  final int quantity;
  final String callingFunction;
  final String event;
  final int txIndex;
  final AssetInfo assetInfo;
  final String quantityNormalized;


  const Credit({
    required this.blockIndex,
    required this.address,
    required this.asset,
    required this.quantity,
    required this.callingFunction,
    required this.event,
    required this.txIndex,
    required this.assetInfo,
    required this.quantityNormalized,
  });


  factory Credit.fromJson(Map<String, dynamic> json) => _$CreditFromJson(json);

}

// {
//                 "block_index": 840464,
//                 "address": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
//                 "asset": "XCP",
//                 "quantity": 50000000,
//                 "action": "issuance fee",
//                 "event": "876a6cfbd4aa22ba4fa85c2e1953a1c66649468a43a961ad16ea4d5329e3e4c5",
//                 "tx_index": 2726605,
//                 "asset_info": {
//                     "divisible": true,
//                     "asset_longname": "Counterparty",
//                     "description": "The Counterparty protocol native currency",
//                     "locked": true
//                 },
//                 "quantity_normalized": "0.5"
//             }

@JsonSerializable(fieldRename: FieldRename.snake)
class Debit {
  final int blockIndex;
  final String address;
  final String asset;
  final int quantity;
  final String action;
  final String event;
  final int txIndex;
  final AssetInfo assetInfo;
  final String quantityNormalized;
  const Debit({
    required this.blockIndex,
    required this.address,
    required this.asset,
    required this.quantity,
    required this.action,
    required this.event,
    required this.txIndex,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Debit.fromJson(Map<String, dynamic> json) => _$DebitFromJson(json);


}

  // {
  //               "type": "order",
  //               "object_id": "533d5c0ecd8ca9c2946d3298cc5e570eee55b62b887dd85c95de6de4fdc7f441"
  //           },

@JsonSerializable(fieldRename: FieldRename.snake)
class Expiration {
  final String type;
  final String objectId;
  const Expiration({
    required this.type,
    required this.objectId,
  });
  factory Expiration.fromJson(Map<String, dynamic> json) => _$ExpirationFromJson(json);
}


  // {
  //               "tx_index": 2725738,
  //               "tx_hash": "793af9129c7368f974c3ea0c87ad38131f0d82d19fbaf1adf8aaf2e657ec42b8",
  //               "block_index": 839746,
  //               "source": "1E6tyJ2zCyX74XgEK8t9iNMjxjNVLCGR1u",
  //               "offer_hash": "04b258ac37f73e3b9a8575110320d67c752e1baace0f516da75845f388911735",
  //               "status": "valid"
  //           },
@JsonSerializable(fieldRename: FieldRename.snake)
class Cancel {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String offerHash;
  final String status;

  const Cancel({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.offerHash,
    required this.status,
  });

  factory Cancel.fromJson(Map<String, dynamic> json) => _$CancelFromJson(json);
}

// i  {
//                 "tx_index": 2726496,
//                 "tx_hash": "f5609facc8dac6cdf70b15c514ea15a9acc24a9bd86dcac2b845d5740fbcc50b",
//                 "block_index": 839988,
//                 "source": "1FpLAtreZjTVCMcj1pq1AHWuqcs3n7obMm",
//                 "asset": "COBBEE",
//                 "quantity": 50000,
//                 "tag": "",
//                 "status": "valid",
//                 "asset_info": {
//                     "asset_longname": null,
//                     "description": "https://easyasset.art/j/m4dl0x/COBBE.json",
//                     "issuer": "1P3KQWLsTPXVWimiF2Q6WSES5vbJE8be5i",
//                     "divisible": 0,
//                     "locked": 0
//                 },
//                 "quantity_normalized": "50000"
//             }
@JsonSerializable(fieldRename: FieldRename.snake)
class Destruction {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String asset;
  final int quantity;
  final String tag;
  final String status;
  final AssetInfo assetInfo;
  final String quantityNormalized;

  const Destruction({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.asset,
    required this.quantity,
    required this.tag,
    required this.status,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Destruction.fromJson(Map<String, dynamic> json) => _$DestructionFromJson(json);

}

// issuance
  // {
  //               "tx_index": 2726605,
  //               "tx_hash": "876a6cfbd4aa22ba4fa85c2e1953a1c66649468a43a961ad16ea4d5329e3e4c5",
  //               "msg_index": 0,
  //               "block_index": 840464,
  //               "asset": "UNNEGOTIABLE",
  //               "quantity": 1,
  //               "divisible": 0,
  //               "source": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
  //               "issuer": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
  //               "transfer": 0,
  //               "callable": 0,
  //               "call_date": 0,
  //               "call_price": 0.0,
  //               "description": "UNNEGOTIABLE WE MUST BECOME UNNEGOTIABLE WE ARE",
  //               "fee_paid": 50000000,
  //               "locked": 0,
  //               "status": "valid",
  //               "asset_longname": null,
  //               "reset": 0
  //           }


@JsonSerializable(fieldRename: FieldRename.snake)
class Issuance {
  final int txIndex;
  final String txHash;
  final int msgIndex;
  final int blockIndex;
  final String asset;
  final int quantity;
  final int divisible;
  final String source;
  final String issuer;
  final int transfer;
  final int callable;
  final int callDate;
  final double callPrice;
  final String description;
  final int feePaid;
  final int locked;
  final String status;
  final String? assetLongname;
  final int reset;

  const Issuance({
    required this.txIndex,
    required this.txHash,
    required this.msgIndex,
    required this.blockIndex,
    required this.asset,
    required this.quantity,
    required this.divisible,
    required this.source,
    required this.issuer,
    required this.transfer,
    required this.callable,
    required this.callDate,
    required this.callPrice,
    required this.description,
    required this.feePaid,
    required this.locked,
    required this.status,
    this.assetLongname,
    required this.reset,
  });

  factory Issuance.fromJson(Map<String, dynamic> json) => _$IssuanceFromJson(json);
}

// Send 
// {
//                 "tx_index": 2726604,
//                 "tx_hash": "b4bbb14c99dd260eb634243e5c595e1b7213459979857a32850de84989bb71ec",
//                 "block_index": 840459,
//                 "source": "13Hnmhs5gy2yXKVBx4wSM5HCBdKnaSBZJH",
//                 "destination": "1LfT83WAxbN9qKhtrXxcQA6xgdhfZk21Hz",
//                 "asset": "GAMESOFTRUMP",
//                 "quantity": 1,
//                 "status": "valid",
//                 "msg_index": 0,
//                 "memo": null,
//                 "asset_info": {
//                     "asset_longname": null,
//                     "description": "",
//                     "issuer": "1JJP986hdU9Qy9b49rafM9FoXdbz1Mgbjo",
//                     "divisible": 0,
//                     "locked": 0
//                 },
//                 "quantity_normalized": "1"
//             }

@JsonSerializable(fieldRename: FieldRename.snake)
class Send {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final String asset;
  final int quantity;
  final String status;
  final int msgIndex;
  final String? memo;
  final AssetInfo assetInfo;
  final String quantityNormalized;

  const Send({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
    required this.status,
    required this.msgIndex,
    this.memo,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Send.fromJson(Map<String, dynamic> json) => _$SendFromJson(json);

}

// Dispense
// {
//                 "tx_index": 2726580,
//                 "dispense_index": 0,
//                 "tx_hash": "e7f0f2c9bef7a492b714a5952ec61b283be344419c5bc33f405f9af41ebfa48b",
//                 "block_index": 840322,
//                 "source": "bc1qq735dv8peps2ayr3qwwwdwylq4ddwcgrpyg9r2",
//                 "destination": "bc1qzcdkhnexpjc8wvkyrpyrsn0f5xzcpu877mjmgj",
//                 "asset": "FLOCK",
//                 "dispense_quantity": 90000000000,
//                 "dispenser_tx_hash": "753787004d6e93e71f6e0aa1e0932cc74457d12276d53856424b2e4088cc542a",
//                 "dispenser": {
//                     "tx_index": 2536311,
//                     "block_index": 840322,
//                     "source": "bc1qq735dv8peps2ayr3qwwwdwylq4ddwcgrpyg9r2",
//                     "give_quantity": 10000000000,
//                     "escrow_quantity": 250000000000,
//                     "satoshirate": 330000,
//                     "status": 0,
//                     "give_remaining": 140000000000,
//                     "oracle_address": null,
//                     "last_status_tx_hash": null,
//                     "origin": "bc1qq735dv8peps2ayr3qwwwdwylq4ddwcgrpyg9r2",
//                     "dispense_count": 2,
//                     "give_quantity_normalized": "100",
//                     "give_remaining_normalized": "1400",
//                     "escrow_quantity_normalized": "2500"
//                 },
//                 "asset_info": {
//                     "asset_longname": null,
//                     "description": "",
//                     "issuer": "18VNeRv8vL528HF7ruKwxycrfNEeoqmHpa",
//                     "divisible": 1,
//                     "locked": 1
//                 }
//             }


@JsonSerializable(fieldRename: FieldRename.snake)
class Dispenser {
  final int txIndex;
  final int blockIndex;
  final String source;
  final int giveQuantity;
  final int escrowQuantity;
  final int satoshiRate;
  final int status;
  final int giveRemaining;
  final String? oracleAddress;
  final String? lastStatusTxHash;
  final String origin;
  final int dispenseCount;
  final String giveQuantityNormalized;
  final String giveRemainingNormalized;
  final String escrowQuantityNormalized;

  const Dispenser({
    required this.txIndex,
    required this.blockIndex,
    required this.source,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.satoshiRate,
    required this.status,
    required this.giveRemaining,
    required this.oracleAddress,
    required this.lastStatusTxHash,
    required this.origin,
    required this.dispenseCount,
    required this.giveQuantityNormalized,
    required this.giveRemainingNormalized,
    required this.escrowQuantityNormalized,
    });

    factory Dispenser.fromJson(Map<String, dynamic> json) => _$DispenserFromJson(json);
      


}

@JsonSerializable(fieldRename: FieldRename.snake)
class  Dispense {
  final int txIndex;
  final int dispenseIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final String asset;
  final int dispenseQuantity;
  final String dispenserTxHash;
  final Dispenser dispenser;
  final AssetInfo assetInfo;

  const Dispense({
    required this.txIndex,
    required this.dispenseIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.asset,
    required this.dispenseQuantity,
    required this.dispenserTxHash,
    required this.dispenser,
    required this.assetInfo,
  });


  factory Dispense.fromJson(Map<String, dynamic> json) => _$DispenseFromJson(json);

}

// Sweep
// {
//                 "tx_index": 2720536,
//                 "tx_hash": "9309a4c0aed426e281a52e5d48acadd1464999269a5e75cf2293edd0277d743d",
//                 "block_index": 836519,
//                 "source": "1DMVnJuqBobXA9xYioabBsR4mN8bvVtCAW",
//                 "destination": "1HC2q92SfH1ZHzS4CrDwp6KAipV4FqUL4T",
//                 "flags": 3,
//                 "status": "valid",
//                 "memo": null,
//                 "fee_paid": 1400000
//             },
@JsonSerializable(fieldRename: FieldRename.snake)
class Sweep {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final int flags;
  final String status;
  final String? memo;
  final int feePaid;


  const Sweep({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.flags,
    required this.status,
    this.memo,
    required this.feePaid,
  });


  factory Sweep.fromJson(Map<String, dynamic> json) => _$SweepFromJson(json);

}

// Rest


@RestApi(baseUrl: "https://api.counterparty.io/api/v2")
abstract class V2Api {
  factory V2Api(Dio dio, {String baseUrl}) = _V2Api;

  // Counterparty API Root
  // Blocks
  //     Get Blocks
  @GET("/blocks")
  Future<Response<List<Block>>> getBlocks(
    @Query("limit") int limit,
    @Query("last") int last,
    @Query("verbose") bool verbose, // TODO: validate bool parsing
  );
  //     Get Block
  @GET("/blocks/{block_index}")
  Future<Response<Block>> getBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Transactions By Block
  @GET("/blocks/{block_index}/transactions")
  Future<Response<List<Transaction>>> getTransactionsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Events By Block
  @GET("/blocks/{block_index}/events")
  Future<Response<List<Event>>> getEventsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Event Counts By Block
  @GET("/blocks/{block_index}/events/counts")
  Future<Response<List<EventCount>>> getEventCountsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Events By Block And Event
  @GET("/blocks/{block_index}/events/{event}")
  Future<Response<List<Event>>> getEventsByBlockAndEvent(
    @Path("block_index") int blockIndex,
    @Path("event") String event,
    @Query("verbose") bool verbose,
  );
  //     Get Credits By Block
  @GET("/blocks/{block_index}/credits")
  Future<Response<List<Credit>>> getCreditsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Debits By Block
  @GET("/blocks/{block_index}/debits")
  Future<Response<List<Debit>>> getDebitsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Expirations
  @GET("/blocks/{block_index}/expirations")
  Future<Response<List<Expiration>>> getExpirations(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Cancels
  @GET("/blocks/{block_index}/cancels")
  Future<Response<List<Cancel>>> getCancels(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Destructions
  @GET("/blocks/{block_index}/destructions")
  Future<Response<List<Destruction>>> getDestructions(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );

  //     Get Issuances By Block
  @GET("/blocks/{block_index}/issuances")
  Future<Response<List<Issuance>>> getIssuancesByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Sends By Block
  @GET("/blocks/{block_index}/sends")
  Future<Response<List<Send>>> getSendsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
    @Query("limit") int limit,
    @Query("offset") int offset,
  );
  //     Get Dispenses By Block
  @GET("/blocks/{block_index}/dispenses")
  Future<Response<List<Dispense>>> getDispensesByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Sweeps By Block
  @GET("/blocks/{block_index}/sweeps")
  Future<Response<List<Sweep>>> getSweepsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  // Transactions
  //     Info
  //     Unpack
  //     Get Transaction By Hash
  // Addresses
  //     Get Address Balances
  //     Get Balance By Address And Asset
  //     Get Credits By Address
  //     Get Debits By Address
  //     Get Bet By Feed
  //     Get Broadcasts By Source
  //     Get Burns By Address
  //     Get Send By Address
  //     Get Receive By Address
  //     Get Send By Address And Asset
  //     Get Receive By Address And Asset
  //     Get Dispensers By Address
  //     Get Dispensers By Address And Asset
  //     Get Sweeps By Address
  // Compose
  //     Compose Be
  //     Compose Broadcast
  //     Compose BTCPay
  //     Compose Burn
  //     Compose Cancel
  //     Compose Destroy
  //     Compose Dispenser
  //     Compose Dividend
  //     Compose Issuance
  //     Compose MPMA
  //     Compose Order
  //     Compose Send
  //     Compose Sweep
  // Assets
  //     Get Valid Assets
  //     Get Asset Info
  //     Get Asset Balances
  //     Get Balance By Address And Asset
  //     Get Orders By Asset
  //     Get Credits By Asset
  //     Get Debits By Asset
  //     Get Dividends
  //     Get Issuances By Asset
  //     Get Sends By Asset
  //     Get Dispensers By Asset
  //     Get Dispensers By Address And Asset
  //     Get Asset Holders
  // Orders
  //     Get Order
  //     Get Order Matches By Order
  //     Get BTCPays By Order
  //     Get Orders By Two Assets
  // Bets
  //     Get Bet
  //     Get Bet Matches By Bet
  //     Get Resolutions By Bet
  // Burns
  //     Get All Burns
  // Dispensers
  //     Get Dispenser Info By Hash
  //     Get Dispenses By Dispenser
  // Events
  //     Get All Events
  //     Get Event By Index
  //     Get All Events Counts
  //     Get Events By Name
  // Z-pages
  //     Check Server Health
  // Bitcoin
  //     Get Transactions By Address
  //     Get Oldest Transaction By Address
  //     Get Unspent Txouts
  //     PubKeyHash To Pubkey
  //  Counterparty API Root
  // Blocks
  //     Get Blocks
  //     Get Block
  //     Get Transactions By Block
  //     Get Events By Block
  //     Get Event Counts By Block
  //     Get Events By Block And Event
  //     Get Credits By Block
  //     Get Debits By Block
  //     Get Expirations
  //     Get Cancels
  //     Get Destructions
  //     Get Issuances By Block
  //     Get Sends By Block
  //     Get Dispenses By Block
  //     Get Sweeps By Block
  // Transactions
  //     Info
  //     Unpack
  //     Get Transaction By Hash
  // Addresses
  //     Get Address Balances
  //     Get Balance By Address And Asset
  //     Get Credits By Address
  //     Get Debits By Address
  //     Get Bet By Feed
  //     Get Broadcasts By Source
  //     Get Burns By Address
  //     Get Send By Address
  //     Get Receive By Address
  //     Get Send By Address And Asset
  //     Get Receive By Address And Asset
  //     Get Dispensers By Address
  //     Get Dispensers By Address And Asset
  //     Get Sweeps By Address
  // Compose
  //     Compose Bet
  //     Compose Broadcast
  //     Compose BTCPay
  //     Compose Burn
  //     Compose Cancel
  //     Compose Destroy
  //     Compose Dispenser
  //     Compose Dividend
  //     Compose Issuance
  //     Compose MPMA
  //     Compose Order
  //     Compose Send
  //     Compose Sweep
  // Assets
  //     Get Valid Assets
  //     Get Asset Info
  //     Get Asset Balances
  //     Get Balance By Address And Asset
  //     Get Orders By Asset
  //     Get Credits By Asset
  //     Get Debits By Asset
  //     Get Dividends
  //     Get Issuances By Asset
  //     Get Sends By Asset
  //     Get Dispensers By Asset
  //     Get Dispensers By Address And Asset
  //     Get Asset Holders
  // Orders
  //     Get Order
  //     Get Order Matches By Order
  //     Get BTCPays By Order
  //     Get Orders By Two Assets
  // Bets
  //     Get Bet
  //     Get Bet Matches By Bet
  //     Get Resolutions By Bet
  // Burns
  //     Get All Burns
  // Dispensers
  //     Get Dispenser Info By Hash
  //     Get Dispenses By Dispenser
  // Events
  //     Get All Events
  //     Get Event By Index
  //     Get All Events Counts
  //     Get Events By Name
  // Z-pages
  //     Check Server Health
  // Bitcoin
  //     Get Transactions By Address
  //     Get Oldest Transaction By Address
  //     Get Unspent Txouts
  //     PubKeyHash To Pubkey
  //     Get Transaction
  //     Fee Per Kb
  // Mempool
  //     Get All Mempool Events
  //     Get Mempool Events By Name       Get Transaction
  //     Fee Per Kb
  // Mempool
  //     Get All Mempool Events
  //     Get Mempool Events By Name
  //
}
