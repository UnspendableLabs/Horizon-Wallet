class Asset {
  final String? asset;
  final String? assetLongname;
  final String? description;
  final bool? divisible;
  final bool? locked;
  final String? issuer;
  final String? owner;
  final int? supply;
  final String? supplyNormalized;

  const Asset(
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
