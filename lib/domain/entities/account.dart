import 'package:horizon/common/constants.dart';

class Account {
  final String uuid;
  final String name;
  final String walletUuid;
  final String purpose;
  final String coinType;
  final String accountIndex;
  final ImportFormat importFormat;
  Account({
    required this.uuid,
    required this.name,
    required this.walletUuid,
    required this.purpose,
    required this.coinType,
    required this.accountIndex,
    required this.importFormat,
  });
}
