import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/network.dart';

class WalletConfig {
  String uuid;
  Network network;
  BasePath basePath;
  int accountIndexStart;
  int accountIndexEnd;
  SeedDerivation seedDerivation;

  WalletConfig(
      {required this.uuid,
      required this.network,
      required this.basePath,
      this.accountIndexStart = 0,
      required this.accountIndexEnd,
      required this.seedDerivation});

  WalletConfig copyWith({
    Network? network,
    BasePath? basePath,
    int? accountIndexStart,
    int? accountIndexEnd,
    SeedDerivation? seedDerivation,
  }) {
    return WalletConfig(
      uuid: uuid,
      network: network ?? this.network,
      basePath: basePath ?? this.basePath,
      accountIndexStart: accountIndexStart ?? this.accountIndexStart,
      accountIndexEnd: accountIndexEnd ?? this.accountIndexEnd,
      seedDerivation: seedDerivation ?? this.seedDerivation,
    );
  }

  @override
  String toString() {
    return 'WalletConfig('
        'uuid: $uuid, '
        'network: $network, '
        'basePath: $basePath, '
        'accountIndexStart: $accountIndexStart, '
        'accountIndexEnd: $accountIndexEnd, '
        'seedDerivation: $seedDerivation'
        ')';
  }
}
