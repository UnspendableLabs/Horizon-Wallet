import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/models/balance.dart';
import 'package:uniparty/counterparty_api/models/response_wrapper.dart';
import 'package:uniparty/models/transaction.dart';
import 'package:uniparty/models/utxo.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class CounterpartyApi {
  Future<List<Balance>> fetchBalanceV2(String address, NetworkEnum network) async {
    String url = _getUrl(network);

    try {
      final response = await http.get(
        Uri.parse("${url}addresses/$address/balances"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Basic ${base64.encode(utf8.encode('rpc:rpc'))}'
        },
      );
      if (response.statusCode == 200) {
        print('BALANCE RESPONSE: ${response.body}');
        var res = ResponseWrapper.fromJson(jsonDecode(response.body));

        final List<Balance> balances = [];
        for (var item in res.result) {
          balances.add(Balance.fromJson(item));
        }
        return balances;
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (error) {
      // print("error: ${jsonEncode(error)}");
      if (error is ClientException) {
        logger.e(error.message, error: error);
      }
      rethrow;
    }
  }

  Future<List<Balance>> fetchBalance(String address, NetworkEnum network) async {
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
        print('BALANCE RESPONSE: ${response.body}');
        var res = ResponseWrapper.fromJson(jsonDecode(response.body));

        final List<Balance> balances = [];
        for (var item in res.result) {
          balances.add(Balance.fromJson(item));
        }
        return balances;
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (error) {
      if (error is ClientException) {
        logger.e(error.message, error: error);
      }
      rethrow;
    }
  }

  Future<Object> createBurn(String address, NetworkEnum network) async {
    String url = _getUrl(network);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Basic ${base64.encode(utf8.encode('rpc:rpc'))}'
        },
        body: jsonEncode(<String, dynamic>{
          "method": "create_burn",
          "params": {"source": "n2HcDKczzjsY4SfJ6tUtuBrkDfqjYVCoDw", "quantity": 0.0003},
          "jsonrpc": "2.0",
          "id": "0"
        }),
      );
      if (response.statusCode == 200) {
        print('CREATE BURN RESPONSE: ${response.body}');
        var res = ResponseWrapper.fromJson(jsonDecode(response.body));
        return res;
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (error) {
      if (error is ClientException) {
        logger.e(error.message, error: error);
      }
      rethrow;
    }
  }

  Future<List<UniUTXO>> getUnspentTxOut(String address, NetworkEnum network) async {
    String url = _getUrl(network);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Basic ${base64.encode(utf8.encode('rpc:rpc'))}'
        },
        body: jsonEncode(<String, dynamic>{
          "method": "get_unspent_txouts",
          "params": {"address": address},
          "jsonrpc": "2.0",
          "id": "0"
        }),
      );
      if (response.statusCode == 200) {
        print('UTXO RESPONSE: ${response.body}');
        var res = ResponseWrapper.fromJson(jsonDecode(response.body));
        List<UniUTXO> utxos = [];
        for (var item in res.result) {
          utxos.add(UniUTXO.fromJson(item));
        }
        return utxos;
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (error) {
      if (error is ClientException) {
        logger.e(error.message, error: error);
      }
      rethrow;
    }
  }

  Future<String> createSendTransaction(SendTransaction sendTransaction, NetworkEnum network) async {
    String url = _getUrl(network);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Basic ${base64.encode(utf8.encode('rpc:rpc'))}'
        },
        body: jsonEncode(<String, dynamic>{
          "method": "create_send",
          "params": {
            "source": sendTransaction.sourceAddress,
            "destination": sendTransaction.destinationAddress,
            "asset": sendTransaction.asset.name,
            "quantity": sendTransaction.quantity,
            "memo": sendTransaction.memo,
            "memo_is_hex": sendTransaction.memoIsHex
          },
          "jsonrpc": "2.0",
          "id": 0
        }),
      );
      if (response.statusCode == 200) {
        var res = ResponseWrapper.fromJson(jsonDecode(response.body));

        return res.result;
      } else {
        throw Exception('Failed to create send transaction: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      if (error is ClientException) {
        logger.e(error.message, error: error);
      }
      rethrow;
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
