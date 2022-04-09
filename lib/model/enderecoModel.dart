class EnderecoModel {
  final int? id;
  String? rua;
  String? cep;
  String? pais;
  String? estado;
  String? cidade;
  String? bairro;

  EnderecoModel({
    this.id,
    required this.rua,
    required this.cep,
    required this.pais,
    required this.estado,
    required this.cidade,
    required this.bairro,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'rua': rua,
      'cep': cep,
      'pais': pais,
      'estado': estado,
      'cidade': cidade,
      'bairro': bairro,
    };
  }
 
  @override
  String toString() {
    return 'EnderecoModel{id: $id, rua: $rua, cep: $cep, pais: $pais, estado: $estado, cidade: $cidade, bairro: $bairro}';
  }
}