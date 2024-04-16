import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/models/response_wrapper.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class CounterpartyApi {
  Future<Object> fetchBalance(String address, NetworkEnum network) async {
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
        var res = ResponseWrapper.fromJson(jsonDecode(response.body));
        return res;
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (error) {
      if (error is ClientException) {
        logger.e(error.message, error: error);

        throw ErrorDescription(error.message);
      }

      throw ErrorDescription('error from balance fetch');
    }
  }

  _getUrl(NetworkEnum network) {
    switch (network) {
      case NetworkEnum.mainnet:
        return dotenv.env['MAINNET_URL'];
      case NetworkEnum.testnet:
        return dotenv.env['TESTNET_URL'];
    }
  }
}
