// this is not comprehensivew, just adding minimal set of fields that we need
class Asset {
  final String asset;
  final String assetLongname;
  final bool divisible;
  const Asset(
      {required this.asset,
      required this.assetLongname,
      required this.divisible});
}
