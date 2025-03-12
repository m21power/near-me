import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Cubit<ThemeMode> {
  ThemeBloc() : super(ThemeMode.light);

  void toggleTheme() {
    sl<SharedPreferences>().setBool('isDarkMode', state == ThemeMode.light);
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
