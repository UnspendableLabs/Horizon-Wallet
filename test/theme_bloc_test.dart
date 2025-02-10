import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheProvider extends Mock implements CacheProvider {}

void main() {
  late MockCacheProvider mockCacheProvider;

  setUp(() {
    mockCacheProvider = MockCacheProvider();
  });

  group('ThemeBloc', () {
    test('initial state is ThemeMode.dark', () {
      when(() => mockCacheProvider.getBool('isDarkMode')).thenReturn(null);
      when(() => mockCacheProvider.setBool('isDarkMode', true))
          .thenAnswer((_) async {});

      final bloc = ThemeBloc(mockCacheProvider);
      expect(bloc.state, equals(ThemeMode.dark));
    });

    blocTest<ThemeBloc, ThemeMode>(
      'initializes with dark theme when isDarkMode is null',
      build: () {
        when(() => mockCacheProvider.getBool('isDarkMode')).thenReturn(null);
        when(() => mockCacheProvider.setBool('isDarkMode', true))
            .thenAnswer((_) async {});
        return ThemeBloc(mockCacheProvider);
      },
      expect: () => [ThemeMode.dark],
      verify: (bloc) {
        verify(() => mockCacheProvider.getBool('isDarkMode')).called(1);
        verify(() => mockCacheProvider.setBool('isDarkMode', true)).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeMode>(
      'initializes with stored theme preference when available',
      build: () {
        when(() => mockCacheProvider.getBool('isDarkMode')).thenReturn(false);
        return ThemeBloc(mockCacheProvider);
      },
      expect: () => [ThemeMode.light],
      verify: (bloc) {
        verify(() => mockCacheProvider.getBool('isDarkMode')).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeMode>(
      'toggles theme from light to dark',
      build: () {
        when(() => mockCacheProvider.getBool('isDarkMode')).thenReturn(false);
        when(() => mockCacheProvider.setBool('isDarkMode', true))
            .thenAnswer((_) async {});
        return ThemeBloc(mockCacheProvider);
      },
      act: (bloc) => bloc.add(ThemeToggled()),
      expect: () => [ThemeMode.light, ThemeMode.dark],
      verify: (bloc) {
        verify(() => mockCacheProvider.getBool('isDarkMode')).called(2);
        verify(() => mockCacheProvider.setBool('isDarkMode', true)).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeMode>(
      'toggles theme from dark to light',
      build: () {
        when(() => mockCacheProvider.getBool('isDarkMode')).thenReturn(true);
        when(() => mockCacheProvider.setBool('isDarkMode', false))
            .thenAnswer((_) async {});
        return ThemeBloc(mockCacheProvider);
      },
      act: (bloc) => bloc.add(ThemeToggled()),
      expect: () => [ThemeMode.dark, ThemeMode.light],
      verify: (bloc) {
        verify(() => mockCacheProvider.getBool('isDarkMode')).called(2);
        verify(() => mockCacheProvider.setBool('isDarkMode', false)).called(1);
      },
    );
  });
}
