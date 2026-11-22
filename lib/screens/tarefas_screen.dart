import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';
import 'tarefa_detalhes_screen.dart';

enum Filtro { todas, pendentes, concluidas }

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final Stream<List<Tarefa>> _stream = FirebaseService.tarefasStream();
  Filtro _filtro = Filtro.todas;

  List<Tarefa> _filtrar(List<Tarefa> lista) {
    switch (_filtro) {
      case Filtro.todas:
        return lista;
      case Filtro.pendentes:
        return lista.where((t) => !t.concluida).toList();
      case Filtro.concluidas:
        return lista.where((t) => t.concluida).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas tarefas')),
      drawer: const DrawerMenu(atual: Destino.tarefas),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CadastroTarefaScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<Filtro>(
              segments: const [
                ButtonSegment(value: Filtro.todas, label: Text('Todas')),
                ButtonSegment(value: Filtro.pendentes, label: Text('Pendentes')),
                ButtonSegment(
                    value: Filtro.concluidas, label: Text('Concluídas')),
              ],
              selected: {_filtro},
              onSelectionChanged: (s) => setState(() => _filtro = s.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Tarefa>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Erro ao carregar tarefas:\n${snap.error}',
                          textAlign: TextAlign.center),
                    ),
                  );
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tarefas = _filtrar(snap.data ?? []);
                if (tarefas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa encontrada.\n'
                        'Toque em + para adicionar.',
                        textAlign: TextAlign.center),
                  );
                }

                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final t = tarefas[index];
                    final cor = t.prioridade.cor;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cor.withValues(alpha: 0.15),
                          child: Icon(Icons.flag, color: cor),
                        ),
                        title: Text(
                          t.titulo,
                          style: TextStyle(
                            decoration: t.concluida
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'Vence em ${t.dataFormatada} • ${t.prioridade.rotulo}\n'
                          '${t.situacao}',
                        ),
                        isThreeLine: true,
                        trailing: Checkbox(
                          value: t.concluida,
                          onChanged: (v) => FirebaseService.alterarSituacao(
                              t, v ?? false),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TarefaDetalhesScreen(tarefa: t),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
