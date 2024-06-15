import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/raw_transaction.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

class ComposeRepositoryImpl extends ComposeRepository {
  final V2Api api;

  ComposeRepositoryImpl({required this.api});

  @override
  Future<RawTransaction> composeSend(String sourceAddress, String destination, String asset, double quantity,
      [bool? allowUnconfirmedTx, int? fee]) async {
    final response = await api.composeSend(sourceAddress, destination, asset, quantity, allowUnconfirmedTx, fee);
    if (response.result == null) {
      // TODO: handle errors
      throw Exception('Failed to compose send');
    }
    return RawTransaction(hex: response.result!.rawtransaction);
  }
}
