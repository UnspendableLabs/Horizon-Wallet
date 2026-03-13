import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:equatable/equatable.dart";

extension BasePathX on BasePath {
  bool get isHorizon => serialize() == BasePath.horizonSerialized;
  bool get isLegacy => serialize() == BasePath.legacySerialized;

  Set<AddressV2Type> defaultKinds() {
    if (isLegacy) return {AddressV2Type.p2pkh, AddressV2Type.p2wpkh};
    if (isHorizon) return {AddressV2Type.p2wpkh, AddressV2Type.p2tr};
    return {};
  }
}

class WalletConfig extends Equatable {
  String uuid;
  Network network;
  BasePath basePath;
  int accountIndexStart;
  int accountIndexEnd;
  SeedDerivation seedDerivation;

  final Set<AddressV2Type> supportedKinds;

  WalletConfig({
    required this.uuid,
    required this.network,
    required this.basePath,
    this.accountIndexStart = 0,
    required this.accountIndexEnd,
    required this.seedDerivation,
    Set<AddressV2Type>? supportedKinds,
  }) : supportedKinds = {
          ...(supportedKinds ?? basePath.defaultKinds()),
          if (basePath.isHorizon) AddressV2Type.p2tr,
        };

  WalletConfig copyWith({
    Network? network,
    BasePath? basePath,
    int? accountIndexStart,
    int? accountIndexEnd,
    SeedDerivation? seedDerivation,
    Set<AddressV2Type>? supportedKinds,
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
  List<Object?> get props => [
        uuid,
        network, // assuming Network has value equality
        basePath.serialize(), // compare BasePath by canonical form
        accountIndexStart,
        accountIndexEnd,
        seedDerivation, // assuming value equality
        supportedKinds // compare Set by contents
      ];

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
