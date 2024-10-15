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

class MockTransactionInfo extends Mock implements TransactionInfo {}

class FakeTransactionInfo extends Fake implements TransactionInfo {}

void main() {
  late WriteLocalTransactionUseCase writeLocalTransactionUseCase;
  late MockTransactionRepository mockTransactionRepository;
  late MockTransactionLocalRepository mockTransactionLocalRepository;

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeTransactionInfo());
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
      final mockTransactionInfo = MockTransactionInfo();

      // Mock the behavior
      when(() => mockTransactionRepository.getInfo(hex))
          .thenAnswer((_) async => mockTransactionInfo);
      when(() => mockTransactionInfo.copyWith(hash: hash))
          .thenReturn(mockTransactionInfo);
      when(() => mockTransactionLocalRepository.insert(mockTransactionInfo))
          .thenAnswer((_) async => {});

      // Act
      await writeLocalTransactionUseCase.call(hex, hash);

      // Assert
      verify(() => mockTransactionRepository.getInfo(hex)).called(1);
      verify(() => mockTransactionInfo.copyWith(hash: hash)).called(1);
      verify(() => mockTransactionLocalRepository.insert(mockTransactionInfo))
          .called(1);
    });

    test('should handle errors silently', () async {
      // Arrange
      const hex = 'transaction_hex';
      const hash = 'transaction_hash';

      // Mock the behavior to throw an error
      when(() => mockTransactionRepository.getInfo(hex))
          .thenThrow(Exception('Failed to fetch transaction info'));

      // Act
      await writeLocalTransactionUseCase.call(hex, hash);

      // Assert
      verify(() => mockTransactionRepository.getInfo(hex)).called(1);
      verifyNever(() => mockTransactionLocalRepository.insert(any()));
    });
  });
}
