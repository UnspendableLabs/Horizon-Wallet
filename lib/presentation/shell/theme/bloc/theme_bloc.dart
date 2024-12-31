import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final CacheProvider cacheProvider;

  ThemeBloc(this.cacheProvider) : super(ThemeMode.dark) {
    on<ThemeInitialized>(_onInitialized);
    on<ThemeToggled>(_onToggled);

    add(ThemeInitialized());
  }

  Future<void> _onInitialized(
    ThemeInitialized event,
    Emitter<ThemeMode> emit,
  ) async {
    final isDarkMode = cacheProvider.getBool('isDarkMode');

    // If not set, default to dark mode
    if (isDarkMode == null) {
      await cacheProvider.setBool('isDarkMode', true);
      emit(ThemeMode.dark);
      return;
    }

    // Otherwise use the stored preference
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _onToggled(
    ThemeToggled event,
    Emitter<ThemeMode> emit,
  ) async {
    final isDarkMode = cacheProvider.getBool('isDarkMode') ?? false;
    final newTheme = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await cacheProvider.setBool('isDarkMode', !isDarkMode);
    emit(newTheme);
  }
}
