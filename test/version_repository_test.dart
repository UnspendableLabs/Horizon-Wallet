import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/version_repository.dart';
import 'package:horizon/data/sources/repositories/version_repository_extension_impl.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/version_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks
class MockConfig extends Mock implements Config {}

class MockDio extends Mock implements Dio {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockConfig mockConfig;
  late MockDio mockDio;
  late MockLogger mockLogger;
  late VersionRepositoryExtensionImpl versionRepository;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(StackTrace.current);
  });

  setUp(() {
    mockConfig = MockConfig();
    mockDio = MockDio();
    mockLogger = MockLogger();

    // Stub the config to return a base URL
    when(() => mockConfig.versionInfoEndpoint)
        .thenReturn('https://mock-api.com');

    // Inject the mocked Dio instance into VersionRepositoryImpl
    versionRepository =
        VersionRepositoryExtensionImpl(config: mockConfig, logger: mockLogger);
    versionRepository.dio = mockDio; // Replace the dio instance with the mock
  });

  test('should return VersionInfo on successful API response', () async {
    // Arrange
    final responseData = {
      'wallet': {
        'latest': '1.3.11',
        'min': '1.3.10',
      },
    };

    final mockResponse = Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

    when(() => mockDio.get('')).thenAnswer((_) async => mockResponse);

    // Act
    final result = await versionRepository.get().run();

    // Assert
    result.match(
      (error) => fail('Expected success, got error: $error'),
      (versionInfo) {
        expect(versionInfo.latest, Version.parse('1.3.11'));
        expect(versionInfo.min, Version.parse('1.3.10'));
      },
    );
  });

  test('should return error message when Dio throws an exception', () async {
    // Arrange
    final dioError = DioError(
      requestOptions: RequestOptions(path: ''),
      error: 'Network error',
      type: DioErrorType.unknown,
    );

    when(() => mockDio.get('')).thenThrow(dioError);

    // Act
    final result = await versionRepository.get().run();

    // Assert
    result.match(
      (error) {
        expect(error, contains('Error fetching version info'));
        verify(() => mockLogger.error(any(), any(), any())).called(1);
      },
      (_) => fail('Expected error, got success'),
    );
  });

  test('should return error message when parsing fails', () async {
    // Arrange
    final invalidResponseData = {
      'wallet': {
        'latest': 'invalid_version',
        'min': '1.3.10',
      },
    };

    final mockResponse = Response(
      data: invalidResponseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

    when(() => mockDio.get('')).thenAnswer((_) async => mockResponse);

    // Act
    final result = await versionRepository.get().run();

    // Assert
    result.match(
      (error) {
        expect(error, contains('Error fetching version info'));
        verify(() => mockLogger.error(any(), any(), any())).called(1);
      },
      (_) => fail('Expected error due to parsing failure, but got success'),
    );
  });
}
