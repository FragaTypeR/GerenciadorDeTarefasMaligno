import 'package:flutter/material.dart';

enum Prioridade { baixa, media, alta }

extension PrioridadeX on Prioridade {
  String get rotulo {
    switch (this) {
      case Prioridade.baixa:
        return 'Baixa';
      case Prioridade.media:
        return 'Média';
      case Prioridade.alta:
        return 'Alta';
    }
  }

  Color get cor {
    switch (this) {
      case Prioridade.baixa:
        return Colors.green;
      case Prioridade.media:
        return Colors.orange;
      case Prioridade.alta:
        return Colors.red;
    }
  }
}

class Tarefa {
  String id;
  String titulo;
  String descricao;
  DateTime dataVencimento;
  Prioridade prioridade;
  bool concluida;

  Tarefa({
    this.id = '',
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  String get situacao => concluida ? 'Concluída' : 'Pendente';

  String get dataFormatada {
    final d = dataVencimento.day.toString().padLeft(2, '0');
    final m = dataVencimento.month.toString().padLeft(2, '0');
    return '$d/$m/${dataVencimento.year}';
  }

  /// O id é a chave do nó no Realtime Database, por isso não vai no mapa.
  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'dataVencimento': dataVencimento.millisecondsSinceEpoch,
        'prioridade': prioridade.name,
        'concluida': concluida,
      };

  factory Tarefa.fromMap(String id, Map<dynamic, dynamic> map) => Tarefa(
        id: id,
        titulo: (map['titulo'] ?? '') as String,
        descricao: (map['descricao'] ?? '') as String,
        dataVencimento: DateTime.fromMillisecondsSinceEpoch(
            (map['dataVencimento'] as num).toInt()),
        prioridade: Prioridade.values.firstWhere(
          (p) => p.name == map['prioridade'],
          orElse: () => Prioridade.media,
        ),
        concluida: (map['concluida'] ?? false) as bool,
      );
}
