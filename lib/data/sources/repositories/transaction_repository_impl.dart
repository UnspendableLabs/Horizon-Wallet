import 'package:horizon/data/models/transaction_unpacked.dart';
import 'package:horizon/data/models/transaction_info.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart'
    as unpacked_entity;
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';

// import "package:horizon/data/models/unpacked.dart" as unpacked_model;

class TransactionRepositoryImpl implements TransactionRepository {
  final api.V2Api api_;
  final AddressRepository addressRepository;

  TransactionRepositoryImpl(
      {required this.api_, required this.addressRepository});

  @override
  Future<unpacked_entity.TransactionUnpacked> unpack(String hex) async {
    final response = await api_.unpackTransactionVerbose(hex);

    // todo: check for errors
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $hex");
    }

    return UnpackedVerboseMapper.toDomain(response.result!);
  }

  @override
  Future<TransactionInfo> getInfo(String raw) async {
    final response = await api_.getTransactionInfoVerbose(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    api.InfoVerbose info = response.result!;

    return InfoVerboseMapper.toDomain(info);
  }
}
