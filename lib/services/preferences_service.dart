import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _chaveTemaEscuro = 'tema_escuro';

  static Future<ThemeMode> carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final escuro = prefs.getBool(_chaveTemaEscuro) ?? false;
    return escuro ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> salvarTema(ThemeMode modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveTemaEscuro, modo == ThemeMode.dark);
  }
}
