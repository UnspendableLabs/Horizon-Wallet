class AssetInfo {
  final String? assetLongname;
  final String? description;
  final bool divisible;
  final String? issuer;
  final String? owner;
  const AssetInfo({
    this.description,
    required this.divisible,
    this.issuer,
    this.assetLongname,
    this.owner,
  });
}
