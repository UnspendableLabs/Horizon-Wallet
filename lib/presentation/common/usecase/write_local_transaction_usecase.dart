import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';

class WriteLocalTransactionUseCase {
  final TransactionRepository transactionRepository;
  final TransactionLocalRepository transactionLocalRepository;
  WriteLocalTransactionUseCase({
    required this.transactionRepository,
    required this.transactionLocalRepository,
  });
  Future<void> call(String hex, String hash) async {
    try {
      final txInfo = await transactionRepository.getInfo(hex);

      await transactionLocalRepository.insert(txInfo.copyWith(
        hash: hash,
      ));
    } catch (e) {
      // error can be a no-op for now
    }
  }
}
