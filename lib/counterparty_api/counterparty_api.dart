import 'dart:convert';

import 'package:counterparty_wallet/counterparty_api/models/balance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CounterpartyApi {
  Future<Balance> fetchAlbum() async {
    String url = dotenv.env['TESTNET_URL'] as String; // TODO
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Balance.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load balance');
    }
  }
}
