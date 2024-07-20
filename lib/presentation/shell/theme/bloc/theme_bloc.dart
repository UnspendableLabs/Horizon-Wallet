import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final CacheProvider cacheProvider;

  ThemeBloc(this.cacheProvider) : super(ThemeMode.light) {
    on<ThemeEvent>((event, emit) async {
      if (event == ThemeEvent.toggle) {
        final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        await cacheProvider.setBool('isDarkMode', newTheme == ThemeMode.dark);
        emit(newTheme);
      }
    });

    _loadTheme();
  }

  void _loadTheme() async {
    final isDarkMode = cacheProvider.getBool('isDarkMode') ?? false;
    add(ThemeEvent.toggle);
    if (isDarkMode) {
      add(ThemeEvent.toggle);
    }
  }
}
