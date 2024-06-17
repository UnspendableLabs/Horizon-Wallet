class AssetInfo {
  final String assetLongname;
  final String description;
  final String? issuer;
  final bool divisible;
  final bool locked;
  const AssetInfo({
    required this.assetLongname,
    required this.description,
    required this.divisible,
    required this.locked,
    this.issuer,
  });
}
