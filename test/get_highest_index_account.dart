import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/common/shared_util.dart';

Account createTestAccount({
  required String accountIndex,
  String uuid = 'test-uuid',
  String name = 'test-name',
  String walletUuid = 'test-wallet',
  String purpose = '84',
  String coinType = '0',
  ImportFormat importFormat = ImportFormat.horizon,
}) {
  return Account(
    uuid: uuid,
    name: name,
    walletUuid: walletUuid,
    purpose: purpose,
    coinType: coinType,
    accountIndex: accountIndex,
    importFormat: importFormat,
  );
}

void main() {
  group('getHighestIndexAccount', () {
    test('throws exception when accounts list is empty', () {
      expect(
        () => getHighestIndexAccount([]),
        throwsException,
      );
    });

    test('returns single account when list has only one account', () {
      final account = createTestAccount(accountIndex: "0'");
      final result = getHighestIndexAccount([account]);
      expect(result, account);
    });

    test('finds highest index in ordered list', () {
      final accounts = [
        createTestAccount(accountIndex: "0'"),
        createTestAccount(accountIndex: "1'"),
        createTestAccount(accountIndex: "2'"),
      ];
      final result = getHighestIndexAccount(accounts);
      expect(result.accountIndex, "2'");
    });

    test('finds highest index in unordered list', () {
      final accounts = [
        createTestAccount(accountIndex: "2'"),
        createTestAccount(accountIndex: "0'"),
        createTestAccount(accountIndex: "1'"),
      ];
      final result = getHighestIndexAccount(accounts);
      expect(result.accountIndex, "2'");
    });

    test('handles non-sequential indexes', () {
      final accounts = [
        createTestAccount(accountIndex: "0'"),
        createTestAccount(accountIndex: "5'"),
        createTestAccount(accountIndex: "2'"),
      ];
      final result = getHighestIndexAccount(accounts);
      expect(result.accountIndex, "5'");
    });

    test('handles large numbers', () {
      final accounts = [
        createTestAccount(accountIndex: "999999'"),
        createTestAccount(accountIndex: "1000000'"),
        createTestAccount(accountIndex: "999998'"),
      ];
      final result = getHighestIndexAccount(accounts);
      expect(result.accountIndex, "1000000'");
    });

    test('returns correct full account object, not just highest index', () {
      final accounts = [
        createTestAccount(
          accountIndex: "0'",
          name: "First Account",
          uuid: "uuid-1",
        ),
        createTestAccount(
          accountIndex: "2'",
          name: "Highest Account",
          uuid: "uuid-2",
        ),
        createTestAccount(
          accountIndex: "1'",
          name: "Second Account",
          uuid: "uuid-3",
        ),
      ];

      final result = getHighestIndexAccount(accounts);
      expect(result.accountIndex, "2'");
      expect(result.name, "Highest Account");
      expect(result.uuid, "uuid-2");
    });

    test('throws exception for malformed account indexes', () {
      final accounts = [
        createTestAccount(accountIndex: "not-a-number'"),
        createTestAccount(accountIndex: "1'"),
      ];

      expect(
        () => getHighestIndexAccount(accounts),
        throwsFormatException,
      );
    });
  });
}
