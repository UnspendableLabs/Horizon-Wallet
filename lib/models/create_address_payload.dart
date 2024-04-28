import 'dart:typed_data';

import 'package:uniparty/common/constants.dart';

class CreateAddressPayload {
  final Uint8List publicKeyIntList;
  final NetworkEnum network;
  CreateAddressPayload({required this.publicKeyIntList, required this.network});
}
