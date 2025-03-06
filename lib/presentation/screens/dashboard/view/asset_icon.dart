import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  final String asset;
  final double size;

  const AssetIcon({
    required this.asset,
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    String assetPath;
    if (asset == 'BTC') {
      assetPath = 'btc-img.png';
    } else {
      assetPath = 'xcp-img.png';
    }
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(assetPath),
    );
  }
}
