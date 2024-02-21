import 'dart:convert';

import 'package:counterparty_wallet/counterparty_api/models/balance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CounterpartyApi {
  Future<Balance> fetchBalance(address) async {
    String url = dotenv.env['TESTNET_URL'] as String; // TODO
    print('url: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'authorization': 'Basic ${base64.encode(utf8.encode('rpc:rpc'))}'
      },
      body: jsonEncode(<String, dynamic>{
        "method": "get_balances",
        "params": {
          "filters": [
            {"field": "address", "op": "==", "value": address}
          ]
        },
        "jsonrpc": "2.0",
        "id": "0"
      }),
    );
    print('RESPONSE: $response');
    return Balance.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    // if (response.statusCode == 200) {
    //   return Balance.fromJson(
    //       jsonDecode(response.body) as Map<String, dynamic>);
    // } else {
    //   throw Exception('Failed to load balance');
    // }
  }
}
