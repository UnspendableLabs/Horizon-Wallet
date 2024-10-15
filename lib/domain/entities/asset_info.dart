class AssetInfo {
  final String? assetLongname;
  final String description;
  final bool divisible;
  final String? issuer;
  const AssetInfo({
    required this.description,
    required this.divisible,
    this.issuer,
    this.assetLongname,
  });
}
