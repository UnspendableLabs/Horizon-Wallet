class Asset {
  final String asset;
  final String? assetLongname;
  final String? description;
  final bool? divisible_;
  final bool? locked;
  final String? issuer;
  final String? owner;
  final int? supply;
  final String? supplyNormalized;

  const Asset(
      {required this.asset,
      this.assetLongname,
      this.description,
      this.divisible_,
      this.locked,
      this.issuer,
      this.owner,
      this.supply,
      this.supplyNormalized});

  String get displayName => assetLongname ?? asset;


  bool get divisible => divisible_ ?? false;

}
