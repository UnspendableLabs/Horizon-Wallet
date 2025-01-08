class DividendAssetInfo {
  final String? assetLongname;
  final String? description;
  final bool divisible;
  final String? issuer;
  const DividendAssetInfo({
    this.description,
    required this.divisible,
    this.issuer,
    this.assetLongname,
  });
}
