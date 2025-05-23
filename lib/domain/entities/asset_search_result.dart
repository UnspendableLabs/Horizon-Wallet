import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:fpdart/fpdart.dart';

class AssetSearchResult {
  final String name;
  final String description;

  const AssetSearchResult({
    required this.name,
    required this.description,
  });

  AssetSearchResult copyWith({required Option<MultiAddressBalance> balance}) {
    return AssetSearchResult(
      name: name,
      description: description,
    );
  }
}
