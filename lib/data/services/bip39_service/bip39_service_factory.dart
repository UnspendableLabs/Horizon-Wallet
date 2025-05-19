// data/services/bip39_service_factory.dart

import 'package:horizon/domain/services/bip39.dart';

import './bip39_service_stub.dart'
    if (dart.library.io) './bip39_service_native.dart'
    if (dart.library.html) './bip39_service_web.dart';

Bip39Service createBip39Service() => createBip39ServiceImpl();
