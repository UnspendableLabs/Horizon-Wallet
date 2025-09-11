import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/address_v2.dart';

class XCPActivityView extends StatelessWidget {
  final AddressV2 address;
  const XCPActivityView({required this.address});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with XCP tx list for [address]
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text('XCP activity for ${address.address}'),
    );
  }
}
