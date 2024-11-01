import 'package:horizon/data/sources/network/api/v1_api.dart';
import 'package:horizon/domain/entities/create_send_params.dart';
import 'package:horizon/domain/repositories/create_send_repository.dart';

class CreateSendRepositoryImpl implements CreateSendRepository {
  final V1Api v1Api;

  CreateSendRepositoryImpl({required this.v1Api});

  @override
  Future<void> createSend(CreateSendParams params) {
    return v1Api.sendAsset(
      source: params.source,
      destination: params.destination,
      asset: params.asset,
      quantity: params.quantity,
    );
  }
}
