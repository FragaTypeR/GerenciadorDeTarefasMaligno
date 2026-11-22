import 'package:flutter/material.dart';

class AppTheme {
  /// Modo de tema atual. O MaterialApp escuta este notifier.
  static final ValueNotifier<ThemeMode> modo = ValueNotifier(ThemeMode.light);

  static ThemeData get lightTheme => _montar(Brightness.light);
  static ThemeData get darkTheme => _montar(Brightness.dark);

  static ThemeData _montar(Brightness brilho) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: brilho,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
