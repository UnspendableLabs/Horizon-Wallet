import 'package:horizon/domain/services/imported_address_service.dart';

import './imported_address_service_stub.dart'
    if (dart.library.io) './imported_address_service_native.dart'
    if (dart.library.html) './imported_address_service_web.dart';

ImportedAddressService createImportedAddressService() =>
    createImportedAddressServiceImpl();
