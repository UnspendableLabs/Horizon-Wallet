import 'dart:async';
import 'package:horizon/domain/entities/imported_address.dart';

import 'package:horizon/domain/entities/wallet_config.dart';
// import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_v2.dart';

class Session {
  AccountV2 currentAccount;
  String decryptionKey;
  List<AccountV2> accounts;
  List<AddressV2> addresses;
  List<ImportedAddress>? importedAddresses;
  WalletConfig walletConfig;

  Session({
    required this.currentAccount,
    required this.accounts,
    // required Wallet wallet,
    required this.decryptionKey,
    required this.addresses,
    this.importedAddresses,
    required this.walletConfig,
  });
}

abstract class SessionRepository {
  final _controller = StreamController<Session>();
  Stream<Session> get stream;
  void addToStream(Session session) => _controller.sink.add(session);
}
