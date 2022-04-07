class RotaModel {
  final int? id;
  final String titulo;
  final String tempo;

  RotaModel({
    this.id,
    required this.titulo,
    required this.tempo,
  });

  Map<String, Object?> toMap() {
    return {'id': id, 'titulo': titulo, 'tempo': tempo};
  }

  @override
  String toString() {
    return 'Pessoa{id: $id, titulo: $titulo, tempo: $tempo}';
  }
}