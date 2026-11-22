class Usuario {
  final String uid;
  final String nome;
  final String email;

  Usuario({required this.uid, required this.nome, required this.email});

  /// O uid é a chave do nó no Realtime Database, por isso não vai no mapa.
  Map<String, dynamic> toMap() => {
        'nome': nome,
        'email': email,
      };

  factory Usuario.fromMap(String uid, Map<dynamic, dynamic> map) => Usuario(
        uid: uid,
        nome: (map['nome'] ?? '') as String,
        email: (map['email'] ?? '') as String,
      );
}
