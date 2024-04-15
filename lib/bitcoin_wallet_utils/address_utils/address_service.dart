import 'dart:typed_data';

import 'package:uniparty/common/constants.dart';

class AddressArgs {
  final Uint8List publicKeyIntList;
  final NetworkEnum network;
  AddressArgs({required this.publicKeyIntList, required this.network});
}

abstract class AddressService {
  String deriveAddress(AddressArgs args);
}
