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

  Map<String, dynamic> toJson() => _$BlockToJson(this);
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



  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  


}

// Rest

@RestApi(baseUrl: "https://api.counterparty.io/api/v2")
abstract class V2Api {
  factory V2Api(Dio dio, {String baseUrl}) = _V2Api;

  @GET("/blocks")
  Future<Response<List<Block>>> getBlocks(
    @Query("limit") int limit,
    @Query("last") int last,
    @Query("verbose") bool verbose, // TODO: validate bool parsing
  );

  @GET("/blocks/{block_index}")
  Future<Response<Block>> getBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
}
