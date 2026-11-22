import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../screens/auth_gate.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tarefas_screen.dart';
import '../services/auth_service.dart';

enum Destino { inicio, tarefas, configuracoes }

/// Menu lateral usado pelas telas principais.
class DrawerMenu extends StatelessWidget {
  final Destino atual;

  const DrawerMenu({super.key, required this.atual});

  void _ir(BuildContext context, Destino destino) {
    Navigator.of(context).pop(); // fecha o drawer
    if (destino == atual) return;

    final Widget tela;
    switch (destino) {
      case Destino.inicio:
        tela = const HomeScreen();
      case Destino.tarefas:
        tela = const TarefasScreen();
      case Destino.configuracoes:
        tela = const ConfiguracoesScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => tela),
    );
  }

  void _sobre(BuildContext context) {
    Navigator.of(context).pop();
    showAboutDialog(
      context: context,
      applicationName: 'Gerenciador de Tarefas',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.task_alt, size: 40),
      children: const [
        Text('Aplicativo de gerenciamento de tarefas pessoais, desenvolvido '
            'em Flutter com Firebase Authentication, Realtime Database e '
            'SharedPreferences.'),
      ],
    );
  }

  Future<void> _sair(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop(); // fecha o drawer
    await AuthService.sair();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<Usuario?>(
        stream: AuthService.usuarioStream,
        initialData: AuthService.usuarioAtual,
        builder: (context, snap) {
          final nome = snap.data?.nome ?? '';
          final email = snap.data?.email ?? '';
          final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(nome),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(inicial, style: const TextStyle(fontSize: 28)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Início'),
                selected: atual == Destino.inicio,
                onTap: () => _ir(context, Destino.inicio),
              ),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Minhas tarefas'),
                selected: atual == Destino.tarefas,
                onTap: () => _ir(context, Destino.tarefas),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                selected: atual == Destino.configuracoes,
                onTap: () => _ir(context, Destino.configuracoes),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre o aplicativo'),
                onTap: () => _sobre(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () => _sair(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
