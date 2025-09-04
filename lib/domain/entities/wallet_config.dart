import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/network.dart';

enum AddressKind {
  p2pkh,
  p2wpkh,
// p2tr
}

extension BasePathX on BasePath {
  bool get isHorizon => serialize() == BasePath.horizonSerialized;
  bool get isLegacy => serialize() == BasePath.legacySerialized;

  /// Defaults you asked for:
  /// - legacy: {p2pkh, p2wpkh}
  /// - horizon: {p2wpkh}
  /// Plus sensible heuristics for other paths (84' => p2wpkh, 86' => p2tr).
  Set<AddressKind> defaultKinds() {
    if (isLegacy) return {AddressKind.p2pkh, AddressKind.p2wpkh};
    if (isHorizon) return {AddressKind.p2wpkh};
    return {};
  }
}

class WalletConfig {
  String uuid;
  Network network;
  BasePath basePath;
  int accountIndexStart;
  int accountIndexEnd;
  SeedDerivation seedDerivation;

  final Set<AddressKind> supportedKinds;

  WalletConfig({
    required this.uuid,
    required this.network,
    required this.basePath,
    this.accountIndexStart = 0,
    required this.accountIndexEnd,
    required this.seedDerivation,
    Set<AddressKind>? supportedKinds,
  }) : supportedKinds = supportedKinds ?? basePath.defaultKinds();

  WalletConfig copyWith({
    Network? network,
    BasePath? basePath,
    int? accountIndexStart,
    int? accountIndexEnd,
    SeedDerivation? seedDerivation,
    Set<AddressKind>? supportedKinds,
  }) {
    return WalletConfig(
      uuid: uuid,
      network: network ?? this.network,
      basePath: basePath ?? this.basePath,
      accountIndexStart: accountIndexStart ?? this.accountIndexStart,
      accountIndexEnd: accountIndexEnd ?? this.accountIndexEnd,
      seedDerivation: seedDerivation ?? this.seedDerivation,
      supportedKinds: supportedKinds ?? this.supportedKinds,
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
        'supportedKinds: $supportedKinds'
        ')';
  }
}
