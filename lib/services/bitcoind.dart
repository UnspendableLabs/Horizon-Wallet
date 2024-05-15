import 'dart:convert' as c;

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import "package:uniparty/api/v2_api.dart" as v2_api;

// curl --user myusername --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "sendrawtransaction", "params": ["signedhex"]}' -H 'content-type: text/plain;' http://127.0.0.1:8332/

abstract class BitcoindService {
  Future<void> sendrawtransaction(String signedHex);
}




class BitcoindServiceHttpImpl implements BitcoindService {
  final String _rpcUser;
  final String _rpcPassword;
  final String _rpcUrl;

  BitcoindServiceHttpImpl({required String rpcUser, required String rpcPassword, required String rpcUrl})
      : _rpcUser = rpcUser,
        _rpcPassword = rpcPassword,
        _rpcUrl = rpcUrl;

  @override
  Future<void> sendrawtransaction(String signetHex) async {
    try {
      final response = await http.post(
        Uri.parse(_rpcUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Basic ${c.base64.encode(c.utf8.encode('$_rpcUser:$_rpcPassword'))}'
        },
        body: c.jsonEncode(<String, dynamic>{
          "jsonrpc": "1.0",
          "id": "curltest",
          "method": "sendrawtransaction",
          "params": [signetHex]
        }),
      );
      if (response.statusCode == 200) {
        print('SEND TRANSACTION RESPONSE: ${response.body}');
      } else {
        throw Exception('Failed to send transaction');
      }
    } catch (error) {
      rethrow;
    }
  }
}


class BitcoindServiceCounterpartyProxyImpl implements BitcoindService {
  final client = v2_api.V2Api(Dio());

  BitcoindServiceCounterpartyProxyImpl();

  @override
  Future<v2_api.Response<String>> sendrawtransaction(String signedHex) async {
      return client.createTransaction(signedHex);
  }
}
