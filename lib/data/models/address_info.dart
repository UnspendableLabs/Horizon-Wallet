import "package:horizon/domain/entities/address_info.dart";
import "package:horizon/data/models/address_stats.dart";

class AddressInfoModel {
  final String address;
  final AddressStatsModel chainStats;
  final AddressStatsModel mempoolStats;

  AddressInfoModel({
    required this.address,
    required this.chainStats,
    required this.mempoolStats,
  });

  factory AddressInfoModel.fromJson(Map<String, dynamic> json) {
    return AddressInfoModel(
      address: json['address'] as String,
      chainStats: AddressStatsModel.fromJson(
          json['chain_stats'] as Map<String, dynamic>),
      mempoolStats: AddressStatsModel.fromJson(
          json['mempool_stats'] as Map<String, dynamic>),
    );
  }

  AddressInfo toEntity() {
    return AddressInfo(
      address: address,
      chainStats: chainStats.toEntity(),
      mempoolStats: mempoolStats.toEntity(),
    );
  }
}
