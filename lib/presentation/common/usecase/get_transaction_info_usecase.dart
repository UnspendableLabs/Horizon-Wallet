import "package:horizon/domain/entities/transaction_info_mempool.dart";
import "package:horizon/domain/repositories/transaction_info_repository.dart";

class GetTransactionInfoUseCase {
  final TransactionInfoRepository transactionInfoRepository;

  const GetTransactionInfoUseCase({
    required this.transactionInfoRepository,
  });

  Future<TransactionInfoMempool> call(String txid) async {
    return transactionInfoRepository.getTransactionInfo(txid).run().then(
          (either) => either.fold(
            (error) => throw Exception("GetTransactionInfo failure"),
            (transactionInfo) => transactionInfo,
          ),
        );
  }
}
