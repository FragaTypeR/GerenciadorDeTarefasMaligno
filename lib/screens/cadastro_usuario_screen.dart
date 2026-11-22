import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    String? erro;
    try {
      await AuthService.cadastrar(
        nome: _nomeCtrl.text,
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      erro = AuthService.mensagemDeErro(e);
    } catch (e) {
      erro = 'Erro inesperado: $e';
    }

    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
      return;
    }

    // O Firebase já deixa o usuário logado; ao fechar esta tela,
    // o AuthGate mostra a Home.
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Conta criada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo usuário')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Mínimo de 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmaCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar senha'),
                validator: (v) =>
                    v != _senhaCtrl.text ? 'As senhas não conferem' : null,
              ),
              const SizedBox(height: 24),
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
                      : const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
