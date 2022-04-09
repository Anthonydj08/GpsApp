

import 'package:gps_app/database/database.dart';
import 'package:gps_app/model/rotaModel.dart';

class RotaController {
  final db = DatabaseHandler();

  Future<void> salvarRota(RotaModel rota) async {
    await db.insertRota(rota);
  }

  Future<void> atualizarRota(RotaModel rota, String tempo) async {
    rota = await db.buscarUltimaRota();
    var editRota = RotaModel(
      id: rota.id,
      titulo: rota.titulo,
      tempo: tempo,
    );
    await db.updateRota(editRota);
  }

  Future<void> deletarRota(int id) async {
    await db.deleteRota(id);
  }

  Future<List<RotaModel>> listarRotas() async {
    return await db.listarRotas();
  }

  Future<RotaModel> buscarUltimaRota() async {
    return await db.buscarUltimaRota();
  }
}
