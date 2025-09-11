import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/address_v2.dart';

class BTCActivityView extends StatelessWidget {
  final AddressV2 address;

  const BTCActivityView({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BTC tx list for [address]
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text('BTC activity for ${address.address}'),
    );
  }
}
