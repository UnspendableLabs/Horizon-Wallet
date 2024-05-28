import 'dart:convert';
import 'dart:developer';

import 'package:horizon/common/constants.dart';
import 'package:horizon/counterparty_api/models/balance.dart';
import 'package:horizon/counterparty_api/models/btc_balance_response.dart';
import 'package:http/http.dart' as http;

// http --follow 'https://api.blockcypher.com/v1/btc/main/addrs/16Fg2yjwrbtC6fZp61EV9mNVKmwCzGasw5/' | jq .final_balance
// 367135

abstract class BlockCypherService {
  Future<List<Balance>> fetchBalance(String signedHex, NetworkEnum network);
}

class BlockCypherImpl implements BlockCypherService {
  final String url;

  BlockCypherImpl({required this.url});
  @override
  Future<List<Balance>> fetchBalance(String address, NetworkEnum network) async {
    try {
      final response = await http.get(
        Uri.parse("$url${_network(network)}/$address/balance"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE, HEAD',
        },
      );
      if (response.statusCode == 200) {
        print('get balances: ${response.body}');
        var res = BlockCypherResponseWrapper.fromJson(jsonDecode(response.body));
        debugger(when: true);
        return [Balance(address: res.address, quantity: res.balance, asset: AssetEnum.BTC.name)];
      } else {
        throw Exception('Failed to get balances');
      }
    } catch (error) {
      debugger(when: true);

      rethrow;
    }
  }

  _network(NetworkEnum network) {
    return network == NetworkEnum.mainnet ? 'main' : 'test3';
  }
}
