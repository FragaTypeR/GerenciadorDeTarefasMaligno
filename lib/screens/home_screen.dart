import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';
import 'tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Criado uma única vez para não reassinar o listener a cada rebuild.
  final Stream<List<Tarefa>> _stream = FirebaseService.tarefasStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      drawer: const DrawerMenu(atual: Destino.inicio),
      body: StreamBuilder<List<Tarefa>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar tarefas:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final tarefas = snap.data ?? [];
          final carregando = snap.connectionState == ConnectionState.waiting;
          final total = tarefas.length;
          final concluidas = tarefas.where((t) => t.concluida).length;
          final pendentes = total - concluidas;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (carregando) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              StreamBuilder<Usuario?>(
                stream: AuthService.usuarioStream,
                initialData: AuthService.usuarioAtual,
                builder: (context, s) => Text(
                  'Olá, ${s.data?.nome ?? ''}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ResumoCard(
                      rotulo: 'Total',
                      valor: total,
                      icone: Icons.list_alt,
                      cor: Colors.indigo,
                    ),
                  ),
                  Expanded(
                    child: _ResumoCard(
                      rotulo: 'Pendentes',
                      valor: pendentes,
                      icone: Icons.hourglass_bottom,
                      cor: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _ResumoCard(
                      rotulo: 'Concluídas',
                      valor: concluidas,
                      icone: Icons.check_circle,
                      cor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.checklist),
                label: const Text('Minhas tarefas'),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const TarefasScreen()),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nova tarefa'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CadastroTarefaScreen()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String rotulo;
  final int valor;
  final IconData icone;
  final Color cor;

  const _ResumoCard({
    required this.rotulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icone, color: cor),
            const SizedBox(height: 8),
            Text('$valor', style: Theme.of(context).textTheme.headlineMedium),
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
