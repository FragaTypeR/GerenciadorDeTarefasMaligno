import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Usuario? _paraUsuario(User? u) {
    if (u == null) return null;
    return Usuario(
      uid: u.uid,
      nome: u.displayName ?? '',
      email: u.email ?? '',
    );
  }

  static Usuario? get usuarioAtual => _paraUsuario(_auth.currentUser);

  /// Emite o usuário logado (ou null). O Firebase restaura a sessão sozinho
  /// quando o app é reaberto.
  static final Stream<Usuario?> usuarioStream =
      _auth.userChanges().map(_paraUsuario);

  static Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final user = cred.user!;
    await user.updateDisplayName(nome.trim());
    await user.reload();

    // Guarda também o perfil no Realtime Database (não impede o cadastro se falhar).
    try {
      await FirebaseService.salvarUsuario(
        Usuario(uid: user.uid, nome: nome.trim(), email: email.trim()),
      );
    } catch (_) {}
  }

  static Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  static Future<void> sair() => _auth.signOut();

  static String mensagemDeErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca (mínimo de 6 caracteres).';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'operation-not-allowed':
        return 'Login por e-mail/senha não está habilitado no Firebase.';
      default:
        return 'Erro de autenticação (${e.code}).';
    }
  }
}
