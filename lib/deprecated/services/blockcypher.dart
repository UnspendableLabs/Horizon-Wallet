import 'dart:convert';

import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/deprecated/counterparty_api/models/btc_balance_response.dart';
import 'package:http/http.dart' as http;

// http --follow 'https://api.blockcypher.com/v1/btc/main/addrs/16Fg2yjwrbtC6fZp61EV9mNVKmwCzGasw5/' | jq .final_balance
// 367135

// TODO: redo entire blockcypher impl or find a new public node

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
        Uri.parse("$url${_network(network)}/addrs/$address/balance?omitWalletAddresses=true"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE, HEAD',
        },
      );
      if (response.statusCode == 200) {
        var res = BlockCypherResponseWrapper.fromJson(jsonDecode(response.body));

        return [Balance(address: res.address, quantity: res.balance.toDouble(), asset: AssetEnum.BTC.name)];
      } else {
        throw Exception('Failed to get balances');
      }
    } catch (error) {
      rethrow;
    }
  }

  _network(NetworkEnum network) {
    return network == NetworkEnum.mainnet ? 'main' : 'test3';
  }
}
