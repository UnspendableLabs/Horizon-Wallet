import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uniparty/counterparty_api/models/response_wrapper.dart';

class CounterpartyApi {
  Future<Object> fetchBalance(String address, String network) async {
    String url = _getUrl(network);

    try {
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
      if (response.statusCode == 200) {
        return ResponseWrapper.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (error) {
      throw ErrorDescription('error from balance fetch');
    }
  }

  _getUrl(String network) {
    if (network == 'mainnet') {
      return dotenv.env['MAINNET_URL'];
    } else {
      return dotenv.env['TESTNET_URL'];
    }
  }
}
