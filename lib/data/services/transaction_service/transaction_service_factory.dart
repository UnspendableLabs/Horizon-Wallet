// data/services/transaction_service_factory.dart

import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

import 'transaction_service_stub.dart'
    if (dart.library.io) 'transaction_service_native.dart'
    // if (dart.library.html) 'transaction_service_web.dart';
    if (dart.library.html) 'transaction_service_native.dart';

TransactionService createTransactionService({
  required Config config

  }) => createTransactionServiceImpl(config: config);

