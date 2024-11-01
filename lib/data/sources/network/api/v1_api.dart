import 'package:dio/dio.dart';
import 'package:horizon/data/models/create_send_params.dart';
import 'package:retrofit/retrofit.dart';
import 'package:horizon/data/models/jsonrpc_request.dart';

part 'v1_api.g.dart';
/*
curl -X POST http://api.counterparty.io:4000/api/ --user rpc:rpc -H 'Content-Type: application/json; charset=UTF-8' -H 'Accept: application/json, text/javascript' --data-binary '{ "jsonrpc": "2.0", "id": 0, "method": "get_running_info" }'


*/

@RestApi()
abstract class V1Api {
  factory V1Api(Dio dio, {String baseUrl}) = _V1Api;

  @POST("")
  Future<dynamic> createSend({
    @Body() required JsonRpcRequest request,
  });
}

// Helper extension to make the API easier to use
extension V1ApiX on V1Api {
  Future<dynamic> sendAsset({
    required String source,
    required String destination,
    required String asset,
    required int quantity,
  }) {
    return createSend(
      request: JsonRpcRequest(
        method: 'create_send',
        params: CreateSendParams(
          source: source,
          destination: destination,
          asset: asset,
          quantity: quantity,
        ),
      ),
    );
  }
}
