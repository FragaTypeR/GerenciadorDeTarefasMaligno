import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';

/// Cadastra (tarefa == null) ou edita (tarefa != null) uma tarefa.
class CadastroTarefaScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const CadastroTarefaScreen({super.key, this.tarefa});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _dataCtrl;
  late DateTime _data;
  late Prioridade _prioridade;
  late bool _concluida;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descricaoCtrl = TextEditingController(text: t?.descricao ?? '');
    _data = t?.dataVencimento ?? DateTime.now();
    _dataCtrl = TextEditingController(text: _formatar(_data));
    _prioridade = t?.prioridade ?? Prioridade.media;
    _concluida = t?.concluida ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _dataCtrl.dispose();
    super.dispose();
  }

  String _formatar(DateTime d) {
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) {
      setState(() {
        _data = escolhida;
        _dataCtrl.text = _formatar(escolhida);
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final tarefa = Tarefa(
      id: widget.tarefa?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      dataVencimento: _data,
      prioridade: _prioridade,
      concluida: _concluida,
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseService.salvarTarefa(tarefa);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      messenger.showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
      return;
    }

    navigator.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(_editando
            ? 'Tarefa atualizada com sucesso!'
            : 'Tarefa cadastrada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataCtrl,
                readOnly: true,
                onTap: _escolherData,
                decoration: const InputDecoration(
                  labelText: 'Data de vencimento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Prioridade>(
                initialValue: _prioridade,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: Prioridade.values
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(Icons.flag, color: p.cor, size: 20),
                              const SizedBox(width: 8),
                              Text(p.rotulo),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (p) {
                  if (p != null) setState(() => _prioridade = p);
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Concluída'),
                subtitle: Text(_concluida ? 'Concluída' : 'Pendente'),
                value: _concluida,
                onChanged: (v) => setState(() => _concluida = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_editando ? 'Atualizar' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
