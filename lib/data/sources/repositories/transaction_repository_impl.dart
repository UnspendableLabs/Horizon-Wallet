import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final V2Api api;

  TransactionRepositoryImpl({required this.api});

  @override
  Future<TransactionUnpacked> unpack(String hex) async {
    final response = await api.unpackTransaction(hex);
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $hex");
    }

    Unpack unpacked = response.result!;

    return TransactionUnpacked(
      messageType: unpacked.messageType,
      messageData: unpacked.messageData,
    );
  }
}
