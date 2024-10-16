import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_open_dispensers_on_address.dart';
import 'package:fpdart/fpdart.dart';

// Mock classes using mocktail

class MockDispenserRepository extends Mock implements DispenserRepository {}

class MockLogger extends Mock implements Logger {}

class FakeDispenser extends Fake implements Dispenser {
  final String _source;

  FakeDispenser({required String source}) : _source = source;

  @override
  String get source => _source;
}

void main() {
  late FetchOpenDispensersOnAddressUseCase useCase;
  late MockDispenserRepository mockDispenserRepository;
  late MockLogger mockLogger;

  setUp(() {
    mockDispenserRepository = MockDispenserRepository();
    mockLogger = MockLogger();
    useCase = FetchOpenDispensersOnAddressUseCase(
      dispenserRepository: mockDispenserRepository,
      logger: mockLogger,
    );

    // Register fallback values if necessary
    registerFallbackValue(FakeDispenser(source: 'test_source'));
  });

  group('FetchOpenDispensersOnAddressUseCase', () {
    const testAddress = 'test_address';
    final dispensers = [
      FakeDispenser(
        source: 'test_source', /* other fields */
      ),
    ];

    test('should return a list of dispensers when the repository returns data',
        () async {
      // Arrange
      when(() => mockDispenserRepository.getDispensersByAddress(any()))
          .thenAnswer((_) => TaskEither.right(dispensers));

      // Act
      final result = await useCase.call(testAddress);

      // Assert
      expect(result, dispensers);
      verify(() => mockDispenserRepository.getDispensersByAddress(testAddress))
          .called(1);
    });

    test(
        'should throw FetchOpenDispensersOnAddressException when no dispensers found',
        () async {
      // Arrange
      when(() => mockDispenserRepository.getDispensersByAddress(any()))
          .thenAnswer((_) => TaskEither.right([]));

      // Act & Assert
      expect(
        () async => await useCase.call(testAddress),
        throwsA(isA<FetchOpenDispensersOnAddressException>()),
      );
      verify(() => mockDispenserRepository.getDispensersByAddress(testAddress))
          .called(1);
    });

    test(
        'should throw FetchOpenDispensersOnAddressException on repository error',
        () async {
      // Arrange
      when(() => mockDispenserRepository.getDispensersByAddress(any()))
          .thenAnswer((_) => TaskEither.left("Repository error"));

      // Act & Assert
      expect(
        () async => await useCase.call(testAddress),
        throwsA(isA<FetchOpenDispensersOnAddressException>()),
      );
      verify(() => mockDispenserRepository.getDispensersByAddress(testAddress))
          .called(1);
    });
  });
}
