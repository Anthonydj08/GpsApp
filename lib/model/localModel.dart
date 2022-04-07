class LocalModel {
  final int? id;
  final String latitude;
  final String longitude;
  final int idRota;

  LocalModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.idRota,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'idRota': idRota,
    };
  }

  @override
  String toString() {
    return 'Pessoa{id: $id, latitude: $latitude, longitude: $longitude, , idRota: $idRota}';
  }
}