import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';

// Mock classes
class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

class MockTransactionInfoVerbose extends Mock
    implements TransactionInfoVerbose {}

class FakeTransactionInfoVerbose extends Fake
    implements TransactionInfoVerbose {}

void main() {
  late WriteLocalTransactionUseCase writeLocalTransactionUseCase;
  late MockTransactionRepository mockTransactionRepository;
  late MockTransactionLocalRepository mockTransactionLocalRepository;

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeTransactionInfoVerbose());
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockTransactionLocalRepository = MockTransactionLocalRepository();
    writeLocalTransactionUseCase = WriteLocalTransactionUseCase(
      transactionRepository: mockTransactionRepository,
      transactionLocalRepository: mockTransactionLocalRepository,
    );
  });

  group('WriteLocalTransactionUseCase', () {
    test('should fetch transaction info and write to local repository',
        () async {
      // Arrange
      const hex = 'transaction_hex';
      const hash = 'transaction_hash';
      final mockTransactionInfo = MockTransactionInfoVerbose();

      // Mock the behavior
      when(() => mockTransactionRepository.getInfoVerbose(hex))
          .thenAnswer((_) async => mockTransactionInfo);
      when(() => mockTransactionInfo.copyWith(hash: hash))
          .thenReturn(mockTransactionInfo);
      when(() =>
              mockTransactionLocalRepository.insertVerbose(mockTransactionInfo))
          .thenAnswer((_) async => {});

      // Act
      await writeLocalTransactionUseCase.call(hex, hash);

      // Assert
      verify(() => mockTransactionRepository.getInfoVerbose(hex)).called(1);
      verify(() => mockTransactionInfo.copyWith(hash: hash)).called(1);
      verify(() =>
              mockTransactionLocalRepository.insertVerbose(mockTransactionInfo))
          .called(1);
    });

    test('should handle errors silently', () async {
      // Arrange
      const hex = 'transaction_hex';
      const hash = 'transaction_hash';

      // Mock the behavior to throw an error
      when(() => mockTransactionRepository.getInfoVerbose(hex))
          .thenThrow(Exception('Failed to fetch transaction info'));

      // Act
      await writeLocalTransactionUseCase.call(hex, hash);

      // Assert
      verify(() => mockTransactionRepository.getInfoVerbose(hex)).called(1);
      verifyNever(() => mockTransactionLocalRepository.insertVerbose(any()));
    });
  });
}
