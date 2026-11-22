import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Decide entre Login e Home conforme a sessão do Firebase.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usuario?>(
      stream: AuthService.usuarioStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return snap.data == null ? const LoginScreen() : const HomeScreen();
      },
    );
  }
}
