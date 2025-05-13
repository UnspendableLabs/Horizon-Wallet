import 'package:horizon/data/models/transaction_unpacked.dart';
import 'package:horizon/data/models/transaction_info.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart'
    as unpacked_entity;
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:get_it/get_it.dart';

// import "package:horizon/data/models/unpacked.dart" as unpacked_model;

class TransactionRepositoryImpl implements TransactionRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;
  final AddressRepository addressRepository;

  TransactionRepositoryImpl({
    required this.addressRepository,
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<unpacked_entity.TransactionUnpacked> unpack(
      {required String raw, required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .unpackTransactionVerbose(raw);

    // todo: check for errors
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $raw");
    }

    return UnpackedVerboseMapper.toDomain(response.result!);
  }

  @override
  Future<TransactionInfo> getInfo(
      {required String raw, required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .getTransactionInfoVerbose(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    api.InfoVerbose info = response.result!;

    return InfoVerboseMapper.toDomain(info);
  }
}
