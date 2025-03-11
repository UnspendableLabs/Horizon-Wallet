import 'package:flutter/foundation.dart';
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
      assetPath = kDebugMode ? 'btc-img.png' : 'assets/btc-img.png';
    } else {
      assetPath = kDebugMode ? 'xcp-img.png' : 'assets/xcp-img.png';
    }
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(assetPath),
    );
  }
}
