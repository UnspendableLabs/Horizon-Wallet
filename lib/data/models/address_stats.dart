import "package:horizon/domain/entities/address_stats.dart";

class AddressStatsModel extends AddressStats {
  AddressStatsModel({
    required super.txCount,
    required super.fundedTxoCount,
    required super.fundedTxoSum,
    required super.spentTxoCount,
    required super.spentTxoSum,
  });

  factory AddressStatsModel.fromJson(Map<String, dynamic> json) {
    return AddressStatsModel(
      txCount: json['tx_count'] as int,
      fundedTxoCount: json['funded_txo_count'] as int,
      fundedTxoSum: json['funded_txo_sum'] as int,
      spentTxoCount: json['spent_txo_count'] as int,
      spentTxoSum: json['spent_txo_sum'] as int,
    );
  }

  AddressStats toEntity() {
    return AddressStats(
      txCount: super.txCount,
      fundedTxoCount: super.fundedTxoCount,
      fundedTxoSum: super.fundedTxoSum,
      spentTxoCount: super.spentTxoCount,
      spentTxoSum: super.spentTxoSum,
    );
  }
}
