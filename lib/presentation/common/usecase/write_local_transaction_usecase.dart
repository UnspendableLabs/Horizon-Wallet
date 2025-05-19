import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';

class WriteLocalTransactionUseCase {
  final TransactionRepository transactionRepository;
  final TransactionLocalRepository transactionLocalRepository;
  WriteLocalTransactionUseCase({
    required this.transactionRepository,
    required this.transactionLocalRepository,
  });
  Future<void> call(
      {required String hex,
      required String hash,
      required HttpConfig httpConfig}) async {
    try {
      final txInfo =
          await transactionRepository.getInfo(raw: hex, httpConfig: httpConfig);

      await transactionLocalRepository.insert(txInfo.copyWith(
        hash: hash,
      ));
    } catch (e) {
      // error can be a no-op for now
    }
  }
}
