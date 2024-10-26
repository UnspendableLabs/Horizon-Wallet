import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/common/usecase/batch_update_address_pks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/domain/entities/transaction_info.dart';

// Mock classes
class MockAddressRepository extends Mock implements AddressRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockBitcoindService extends Mock implements BitcoindService {}

class MockBatchUpdateAddressPksUseCase extends Mock
    implements BatchUpdateAddressPksUseCase {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

class FakeTransactionInfo extends Fake implements TransactionInfo {}

class MockUtxo extends Mock implements Utxo {
  @override
  final txid = "test-txid";
}

class MockAddress extends Mock implements Address {
  @override
  final accountUuid = "test-account-uuid";

  @override
  final index = 0;
}

class MockAccount extends Mock implements Account {
  @override
  final walletUuid = "test-wallet-uuid";

  @override
  final purpose = "test-purpose";

  @override
  final coinType = "test-coin-type";

  @override
  final accountIndex = "test-account-index";

  @override
  final importFormat = ImportFormat.horizon;
}

class MockWallet extends Mock implements Wallet {
  @override
  final encryptedPrivKey = "test-encrypted-priv-key";

  @override
  final chainCodeHex = "test-chain-code-hex";
}

void main() {
  late SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  late MockAddressRepository mockAddressRepository;
  late MockAccountRepository mockAccountRepository;
  late MockWalletRepository mockWalletRepository;
  late MockUtxoRepository mockUtxoRepository;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockTransactionService mockTransactionService;
  late MockBitcoindService mockBitcoindService;
  late MockTransactionLocalRepository mockTransactionLocalRepository;
  late MockBatchUpdateAddressPksUseCase mockBatchUpdateAddressPksUseCase;
  setUpAll(() {
    registerFallbackValue(FakeTransactionInfo());
  });

  setUp(() {
    mockAddressRepository = MockAddressRepository();
    mockAccountRepository = MockAccountRepository();
    mockWalletRepository = MockWalletRepository();
    mockUtxoRepository = MockUtxoRepository();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockTransactionService = MockTransactionService();
    mockBitcoindService = MockBitcoindService();
    mockTransactionLocalRepository = MockTransactionLocalRepository();
    mockBatchUpdateAddressPksUseCase = MockBatchUpdateAddressPksUseCase();

    signAndBroadcastTransactionUseCase = SignAndBroadcastTransactionUseCase(
      addressRepository: mockAddressRepository,
      accountRepository: mockAccountRepository,
      walletRepository: mockWalletRepository,
      utxoRepository: mockUtxoRepository,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      transactionService: mockTransactionService,
      bitcoindService: mockBitcoindService,
      transactionLocalRepository: mockTransactionLocalRepository,
      batchUpdateAddressPksUseCase: mockBatchUpdateAddressPksUseCase,
    );
  });

  group('SignAndBroadcastTransactionUseCase', () {
    test('should sign and broadcast transaction successfully', () async {
      // Arrange
      final mockUtxos = [MockUtxo()];
      final mockAddress = MockAddress();
      final mockAccount = MockAccount();
      final mockWallet = MockWallet();
      const String password = 'password';
      const String decryptedRootPrivKey = 'decrypted_private_key';
      const String addressPrivKey = 'address_private_key';
      const String txHex = 'transaction_hex';
      const String txHash = 'transaction_hash';

      // Mock behaviors
      when(() => mockUtxoRepository.getUnspentForAddress('source'))
          .thenAnswer((_) async => mockUtxos);
      when(() => mockAddressRepository.getAddress('source'))
          .thenAnswer((_) async => mockAddress);
      when(() =>
              mockAccountRepository.getAccountByUuid(mockAddress.accountUuid))
          .thenAnswer((_) async => mockAccount);
      when(() => mockWalletRepository.getWallet(mockAccount.walletUuid))
          .thenAnswer((_) async => mockWallet);
      when(() => mockEncryptionService.decrypt(
              mockWallet.encryptedPrivKey, password))
          .thenAnswer((_) async => decryptedRootPrivKey);
      when(() => mockAddressService.deriveAddressPrivateKey(
            rootPrivKey: decryptedRootPrivKey,
            chainCodeHex: mockWallet.chainCodeHex,
            purpose: mockAccount.purpose,
            coin: mockAccount.coinType,
            account: mockAccount.accountIndex,
            change: '0',
            index: mockAddress.index,
            importFormat: mockAccount.importFormat,
          )).thenAnswer((_) async => addressPrivKey);
      when(() => mockTransactionService.signTransaction(
            'rawtransaction',
            addressPrivKey,
            'source',
            {mockUtxos[0].txid: mockUtxos[0]},
          )).thenAnswer((_) async => txHex);
      when(() => mockBitcoindService.sendrawtransaction(txHex))
          .thenAnswer((_) async => txHash);
      when(() => mockBatchUpdateAddressPksUseCase
          .populateEncryptedPrivateKeys(any())).thenAnswer((_) async {});

      // Define callbacks
      var successCallbackInvoked = false;
      onSuccess(String txHex, String txHash) {
        successCallbackInvoked = true;
      }

      onError(String error) {}

      // Act
      await signAndBroadcastTransactionUseCase.call(
        source: "source",
        rawtransaction: "rawtransaction",
        password: password,
        onSuccess: onSuccess,
        onError: onError,
      );

      // Assert
      expect(successCallbackInvoked, true);
      verify(() => mockUtxoRepository.getUnspentForAddress('source')).called(1);
      verify(() => mockAddressRepository.getAddress('source')).called(1);
      verify(() =>
              mockAccountRepository.getAccountByUuid(mockAddress.accountUuid))
          .called(1);
      verify(() => mockWalletRepository.getWallet(mockAccount.walletUuid))
          .called(1);
      verify(() => mockEncryptionService.decrypt(
          mockWallet.encryptedPrivKey, password)).called(1);
      verify(() => mockAddressService.deriveAddressPrivateKey(
            rootPrivKey: decryptedRootPrivKey,
            chainCodeHex: mockWallet.chainCodeHex,
            purpose: mockAccount.purpose,
            coin: mockAccount.coinType,
            account: mockAccount.accountIndex,
            change: '0',
            index: mockAddress.index,
            importFormat: mockAccount.importFormat,
          )).called(1);
      verify(() => mockTransactionService.signTransaction(
            'rawtransaction',
            addressPrivKey,
            'source',
            {mockUtxos[0].txid: mockUtxos[0]},
          )).called(1);
      verify(() => mockBitcoindService.sendrawtransaction(txHex)).called(1);
    });

    test('should return error if address is not found', () async {
      // Arrange

      final mockUtxos = [MockUtxo()];

      when(() => mockUtxoRepository.getUnspentForAddress('source'))
          .thenAnswer((_) async => mockUtxos);

      when(() => mockAddressRepository.getAddress('source'))
          .thenAnswer((_) async => null);

      var errorCallbackInvoked = false;
      onSuccess(String txHex, String txHash) {}
      onError(String error) {
        expect(error, 'Address not found.');
        errorCallbackInvoked = true;
      }

      // Act
      await signAndBroadcastTransactionUseCase.call(
        source: "source",
        rawtransaction: "rawtransaction",
        password: 'password',
        onSuccess: onSuccess,
        onError: onError,
      );

      // Assert
      expect(errorCallbackInvoked, true);
      verify(() => mockAddressRepository.getAddress('source')).called(1);
      verifyNever(() => mockAccountRepository.getAccountByUuid(any()));
      verifyNever(() => mockWalletRepository.getWallet(any()));
    });

    test('should return `Incorrect Password` if decrypt fails', () async {
      // Arrange
      final mockAddress = MockAddress();
      final mockAccount = MockAccount();
      final mockWallet = MockWallet();

      final mockUtxos = [MockUtxo()];

      when(() => mockUtxoRepository.getUnspentForAddress('source'))
          .thenAnswer((_) async => mockUtxos);

      when(() => mockAddressRepository.getAddress('source'))
          .thenAnswer((_) async => mockAddress);
      when(() =>
              mockAccountRepository.getAccountByUuid(mockAddress.accountUuid))
          .thenAnswer((_) async => mockAccount);
      when(() => mockWalletRepository.getWallet(mockAccount.walletUuid))
          .thenAnswer((_) async => mockWallet);
      when(() => mockEncryptionService.decrypt(
              mockWallet.encryptedPrivKey, "wrong_password"))
          .thenThrow(
              SignAndBroadcastTransactionException('Incorrect password.'));

      var errorCallbackInvoked = false;
      onSuccess(String txHex, String txHash) {}
      onError(String error) {
        expect(error, 'Incorrect password.');
        errorCallbackInvoked = true;
      }

      // Act
      await signAndBroadcastTransactionUseCase.call(
        source: "source",
        rawtransaction: "rawtransaction",
        password: 'wrong_password',
        onSuccess: onSuccess,
        onError: onError,
      );

      // Assert
      expect(errorCallbackInvoked, true);
      verify(() => mockEncryptionService.decrypt(
          mockWallet.encryptedPrivKey, 'wrong_password')).called(1);
      verifyNever(() =>
          mockTransactionService.signTransaction(any(), any(), any(), any()));
      verifyNever(() => mockBitcoindService.sendrawtransaction(any()));
    });
    //
    test('should return error if transaction broadcast fails', () async {
      // Arrange
      final mockUtxos = [MockUtxo()];
      final mockAddress = MockAddress();
      final mockAccount = MockAccount();
      final mockWallet = MockWallet();
      const String password = 'password';
      const String decryptedRootPrivKey = 'decrypted_private_key';
      const String addressPrivKey = 'address_private_key';
      const String txHex = 'transaction_hex';

      // Mock behaviors
      when(() => mockUtxoRepository.getUnspentForAddress('source'))
          .thenAnswer((_) async => mockUtxos);
      when(() => mockAddressRepository.getAddress('source'))
          .thenAnswer((_) async => mockAddress);
      when(() =>
              mockAccountRepository.getAccountByUuid(mockAddress.accountUuid))
          .thenAnswer((_) async => mockAccount);
      when(() => mockWalletRepository.getWallet(mockAccount.walletUuid))
          .thenAnswer((_) async => mockWallet);
      when(() => mockEncryptionService.decrypt(
              mockWallet.encryptedPrivKey, password))
          .thenAnswer((_) async => decryptedRootPrivKey);
      when(() => mockAddressService.deriveAddressPrivateKey(
            rootPrivKey: decryptedRootPrivKey,
            chainCodeHex: mockWallet.chainCodeHex,
            purpose: mockAccount.purpose,
            coin: mockAccount.coinType,
            account: mockAccount.accountIndex,
            change: '0',
            index: mockAddress.index,
            importFormat: mockAccount.importFormat,
          )).thenAnswer((_) async => addressPrivKey);
      when(() => mockTransactionService.signTransaction(
            'rawtransaction',
            addressPrivKey,
            'source',
            {mockUtxos[0].txid: mockUtxos[0]},
          )).thenAnswer((_) async => txHex);
      when(() => mockBitcoindService.sendrawtransaction(txHex)).thenThrow(
          SignAndBroadcastTransactionException(
              'Failed to broadcast the transaction.'));

      var errorCallbackInvoked = false;
      onSuccess(
        String txHex,
        String txHash,
      ) {}
      onError(String error) {
        expect(error.contains('Failed to broadcast the transaction'), isTrue);
        errorCallbackInvoked = true;
      }

      // Act
      await signAndBroadcastTransactionUseCase.call(
        source: "source",
        rawtransaction: "rawtransaction",
        password: password,
        onSuccess: onSuccess,
        onError: onError,
      );

      // Assert
      expect(errorCallbackInvoked, true);
      verify(() => mockBitcoindService.sendrawtransaction(txHex)).called(1);
      verifyNever(() => mockTransactionLocalRepository.insert(any()));
    });
  });
}
