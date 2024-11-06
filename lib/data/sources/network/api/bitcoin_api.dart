import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:horizon/data/models/bitcoin_decoded_tx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bitcoin_api.g.dart';

@JsonSerializable(genericArgumentFactories: true, fieldRename: FieldRename.snake)
class Response<T> {
  final T? result;
  final String? error;

  Response({required this.result, required this.error});

  factory Response.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ResponseFromJson(json, fromJsonT);
}

@RestApi()
abstract class BitcoinRpcClient {
  factory BitcoinRpcClient(Dio dio, {String baseUrl}) = _BitcoinRpcClient;

  @POST("")
  Future<Response<BitcoinDecodedTxModel>> decodeRawTransaction(
    @Body() Map<String, dynamic> request,
  );
}

// Helper extension to make the API easier to use
extension BitcoinRpcClientX on BitcoinRpcClient {
  Future<BitcoinDecodedTxModel> decodeRawTx(String hexString) async {
    final response = await decodeRawTransaction({
      'jsonrpc': '1.0',
      'method': 'decoderawtransaction',
      'params': [hexString],
    });
    return response.result!;
  }
}
