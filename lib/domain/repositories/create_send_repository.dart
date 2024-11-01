import 'package:horizon/domain/entities/create_send_params.dart';

abstract class CreateSendRepository {
  Future<void> createSend(CreateSendParams params);
}
