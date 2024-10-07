class Asset {
  final String asset;
  final String assetLongname;
  final bool divisible;
  const Asset(
      {required this.asset,
      required this.assetLongname,
      required this.divisible});
}

class AssetVerbose {
  final String? asset;
  final String? assetLongname;
  final String? description;
  final bool? divisible;
  final bool? locked;
  final String? issuer;
  final String? owner;
  final int? supply;
  final String? supplyNormalized;

  const AssetVerbose(
      {this.asset,
      this.assetLongname,
      this.description,
      this.divisible,
      this.locked,
      this.issuer,
      this.owner,
      this.supply,
      this.supplyNormalized});
}
