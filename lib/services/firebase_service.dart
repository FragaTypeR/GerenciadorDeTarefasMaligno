import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';

/// Acesso ao Firebase Realtime Database.
/// Estrutura: usuarios/{uid} e tarefas/{uid}/{idDaTarefa}
class FirebaseService {
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static DatabaseReference get _tarefasRef => _db.ref('tarefas/$_uid');

  // ---------- Usuário ----------

  static Future<void> salvarUsuario(Usuario usuario) {
    return _db.ref('usuarios/${usuario.uid}').set(usuario.toMap());
  }

  // ---------- Tarefas ----------

  /// Listener em tempo real: emite a lista sempre que algo mudar no banco.
  static Stream<List<Tarefa>> tarefasStream() {
    return _tarefasRef.onValue.map((evento) {
      final valor = evento.snapshot.value;
      if (valor == null || valor is! Map) return <Tarefa>[];

      final lista = valor.entries
          .map((e) => Tarefa.fromMap(
                e.key as String,
                Map<dynamic, dynamic>.from(e.value as Map),
              ))
          .toList();
      lista.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      return lista;
    });
  }

  /// Cria (id vazio) ou atualiza (id preenchido) uma tarefa.
  static Future<void> salvarTarefa(Tarefa tarefa) async {
    if (tarefa.id.isEmpty) {
      await _tarefasRef.push().set(tarefa.toMap());
    } else {
      await _tarefasRef.child(tarefa.id).set(tarefa.toMap());
    }
  }

  static Future<void> alterarSituacao(Tarefa tarefa, bool concluida) {
    return _tarefasRef.child(tarefa.id).update({'concluida': concluida});
  }

  static Future<void> excluirTarefa(String id) {
    return _tarefasRef.child(id).remove();
  }
}
