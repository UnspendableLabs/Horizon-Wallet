import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/address.dart' as entity;
import 'package:horizon/data/sources/repositories/address_repository_impl.dart';

void main() {
  group('addressSortComparator', () {
    test('sorts addresses by index and type correctly', () {
      // Arrange
      var address1 =
          const entity.Address(accountUuid: '1', address: 'legacy0', index: 0);
      var address2 =
          const entity.Address(accountUuid: '1', address: 'bc1q0', index: 0);
      var address3 =
          const entity.Address(accountUuid: '1', address: 'legacy1', index: 1);
      var address4 =
          const entity.Address(accountUuid: '1', address: 'bc1q1', index: 1);

      var addresses = [address3, address4, address1, address2];

      // Act
      addresses.sort(addressSortComparator);

      // Assert
      expect(addresses[0], address1); // legacy0, index 0
      expect(addresses[1], address2); // bc1q0, index 0
      expect(addresses[2], address3); // legacy1, index 1
      expect(addresses[3], address4); // bc1q1, index 1
    });

    test('sorts addresses with only legacy addresses by index', () {
      // Arrange
      var address1 =
          const entity.Address(accountUuid: '1', address: 'legacy0', index: 0);
      var address2 =
          const entity.Address(accountUuid: '1', address: 'legacy1', index: 1);

      var addresses = [address2, address1];

      // Act
      addresses.sort(addressSortComparator);

      // Assert
      expect(addresses[0], address1); // legacy0, index 0
      expect(addresses[1], address2); // legacy1, index 1
    });

    test('sorts addresses with only bech32 addresses by index', () {
      // Arrange
      var address1 =
          const entity.Address(accountUuid: '1', address: 'bc1q0', index: 0);
      var address2 =
          const entity.Address(accountUuid: '1', address: 'bc1q1', index: 1);

      var addresses = [address2, address1];

      // Act
      addresses.sort(addressSortComparator);

      // Assert
      expect(addresses[0], address1); // bc1q0, index 0
      expect(addresses[1], address2); // bc1q1, index 1
    });
  });
}
