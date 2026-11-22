import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import 'cadastro_tarefa_screen.dart';

class TarefaDetalhesScreen extends StatefulWidget {
  final Tarefa tarefa;

  const TarefaDetalhesScreen({super.key, required this.tarefa});

  @override
  State<TarefaDetalhesScreen> createState() => _TarefaDetalhesScreenState();
}

class _TarefaDetalhesScreenState extends State<TarefaDetalhesScreen> {
  late Tarefa _tarefa;

  @override
  void initState() {
    super.initState();
    _tarefa = widget.tarefa;
  }

  Future<void> _alternarSituacao() async {
    final nova = !_tarefa.concluida;
    await FirebaseService.alterarSituacao(_tarefa, nova);
    if (!mounted) return;
    setState(() => _tarefa.concluida = nova);
  }

  Future<void> _editar() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CadastroTarefaScreen(tarefa: _tarefa)),
    );
    if (salvou == true && mounted) {
      Navigator.of(context).pop(); // a lista já se atualiza pelo listener
    }
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja realmente excluir "${_tarefa.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmou != true) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await FirebaseService.excluirTarefa(_tarefa.id);
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Tarefa excluída.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _tarefa;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da tarefa'),
        actions: [
          IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: _editar),
          IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete),
              onPressed: _excluir),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.titulo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Descrição'),
            subtitle: Text(t.descricao.isEmpty ? '—' : t.descricao),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Data de vencimento'),
            subtitle: Text(t.dataFormatada),
          ),
          ListTile(
            leading: Icon(Icons.flag, color: t.prioridade.cor),
            title: const Text('Prioridade'),
            subtitle: Text(t.prioridade.rotulo),
          ),
          ListTile(
            leading: Icon(
              t.concluida ? Icons.check_circle : Icons.hourglass_bottom,
              color: t.concluida ? Colors.green : Colors.orange,
            ),
            title: const Text('Situação'),
            subtitle: Text(t.situacao),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: Icon(t.concluida ? Icons.undo : Icons.check),
            label: Text(
                t.concluida ? 'Marcar como pendente' : 'Marcar como concluída'),
            onPressed: _alternarSituacao,
          ),
        ],
      ),
    );
  }
}
