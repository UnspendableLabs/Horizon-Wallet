import "package:horizon/domain/entities/address_stats.dart";

class AddressInfo {
  final String address;
  final AddressStats chainStats;
  final AddressStats mempoolStats;

  AddressInfo({
    required this.address,
    required this.chainStats,
    required this.mempoolStats,
  });
}
