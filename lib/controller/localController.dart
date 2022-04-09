import 'package:gps_app/database/database.dart';
import 'package:gps_app/model/localModel.dart';

class LocalController {
  final db = DatabaseHandler();

  Future<void> salvarLocal(LocalModel local) async {
    await db.insertLocal(local);
  }

  Future<void> deletarLocal(int id) async {
    await db.deleteLocal(id);
  }

  Future<List<LocalModel>> listarLocais() async {
    return await db.listarLocais();
  }

  Future<List<LocalModel>> listarLocaisPorRota(int idRota) async {
    return await db.buscarLocaisPorRota(idRota);
  }
}
