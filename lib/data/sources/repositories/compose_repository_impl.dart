import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/raw_transaction.dart';
import 'package:horizon/domain/entities/compose_issuance.dart'
    as compose_issuance;
import 'package:horizon/domain/repositories/compose_repository.dart';

class ComposeRepositoryImpl extends ComposeRepository {
  final V2Api api;

  ComposeRepositoryImpl({required this.api});

  @override
  Future<RawTransaction> composeSend(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx, int? fee]) async {
    final response = await api.composeSend(
        sourceAddress, destination, asset, quantity, allowUnconfirmedTx, fee);
    if (response.result == null) {
      // TODO: handle errors
      throw Exception('Failed to compose send');
    }
    return RawTransaction(hex: response.result!.rawtransaction);
  }

  @override
  Future<compose_issuance.ComposeIssuance> composeIssuance(
      String sourceAddress, String name, double quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination]) async {
    final response = await api.composeIssuance(sourceAddress, name, quantity,
        transferDestination, divisible, lock, reset, description, true);
    if (response.result == null) {
      // TODO: handle errors
      throw Exception('Failed to compose issuance');
    }
    return compose_issuance.ComposeIssuance(
        rawtransaction: response.result!.rawtransaction,
        params: compose_issuance.ComposeIssuanceParams(
            source: sourceAddress,
            asset: name,
            quantity: quantity,
            divisible: divisible,
            lock: lock,
            description: description,
            transferDestination: transferDestination),
        name: name);
  }
}
