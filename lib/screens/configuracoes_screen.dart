import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../themes/app_theme.dart';
import '../widgets/drawer_menu.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  Future<void> _alterarTema(ThemeMode modo) async {
    AppTheme.modo.value = modo; // reflete em todas as telas na hora
    await PreferencesService.salvarTema(modo); // persiste a escolha
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const DrawerMenu(atual: Destino.configuracoes),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.modo,
            builder: (context, modo, _) {
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Escuro'),
                  ),
                ],
                selected: {modo},
                onSelectionChanged: (s) => _alterarTema(s.first),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'A escolha é salva no aparelho e mantida ao reabrir o aplicativo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
