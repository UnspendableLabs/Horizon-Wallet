// this is not comprehensivew, just adding minimal set of fields that we need
class Asset {
  final String? asset;
  final String? assetLongname;
  final bool? divisible;
  final String? issuer;
  final String? owner;
  final int? supply;

  const Asset(
      {this.asset,
      this.assetLongname,
      this.divisible,
      this.issuer,
      this.owner,
      this.supply});
}
