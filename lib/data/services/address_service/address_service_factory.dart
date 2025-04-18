// data/services/address_service_factory.dart

import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

import 'address_service_stub.dart'
    if (dart.library.io) 'address_service_native.dart'
    if (dart.library.html) 'address_service_web.dart';

AddressService createAddressService({required Config config}) =>
    createAddressServiceImpl(config: config);
