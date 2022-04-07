
import 'package:gps_app/model/localModel.dart';
import 'package:gps_app/model/rotaModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'GPS.db'),
      onCreate: (database, version) async {
        await database.execute(
            "CREATE TABLE Rotas(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT NOT NULL, tempo TEXT NOT NULL)");
        await database.execute(
            "CREATE TABLE Locais(id INTEGER PRIMARY KEY AUTOINCREMENT, latitude TEXT NOT NULL, longitude TEXT NOT NULL, idRota INTEGER NOT NULL, FOREIGN KEY (idRota) REFERENCES Rotas (id) ON DELETE NO ACTION ON UPDATE NO ACTION)");
      },
      version: 1,
    );
  }

  //-----------------ROTAS----------------------
  Future<void> insertRota(RotaModel r) async {
    final db = await initializeDB();
    await db.insert(
      'Rotas',
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<RotaModel>> listarRotas() async {
    final Database db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('Rotas');
    return List.generate(queryResult.length, (i) {
      return RotaModel(
        id: queryResult[i]['id'],
        titulo: queryResult[i]['titulo'],
        tempo: queryResult[i]['tempo'],
      );
    });
  }

  Future<void> updateRota(RotaModel r) async {
    final Database db = await initializeDB();
    await db.update(
      'Rotas',
      r.toMap(),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<void> deleteRota(int id) async {
    final Database db = await initializeDB();
    db.delete(
      'Rotas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<RotaModel> buscarUltimaRota() async {
    final Database db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query('Rotas', orderBy: 'id DESC', limit: 1);
    return RotaModel(
      id: queryResult[0]['id'],
      titulo: queryResult[0]['titulo'],
      tempo: queryResult[0]['tempo'],
    );
  }

  //-----------------LOCAIS----------------------
  Future<void> insertLocal(LocalModel l) async {
    final db = await initializeDB();
    await db.insert(
      'Locais',
      l.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<LocalModel>> listarLocais() async {
    final Database db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('Locais');
    return List.generate(queryResult.length, (i) {
      return LocalModel(
        id: queryResult[i]['id'],
        latitude: queryResult[i]['latitude'],
        longitude: queryResult[i]['longitude'],
        idRota: queryResult[i]['idRota'],
      );
    });
  }

  Future<void> updateLocal(LocalModel l) async {
    final Database db = await initializeDB();
    db.update(
      'Locais',
      l.toMap(),
      where: 'id = ?',
      whereArgs: [l.id],
    );
  }

  Future<void> deleteLocal(int id) async {
    final Database db = await initializeDB();
    db.delete(
      'Locais',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalModel>> buscarLocaisPorRota(int idRota) async {
    final Database db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(
      'Locais',
      where: 'idRota = ?',
      whereArgs: [idRota],
    );
    return List.generate(queryResult.length, (i) {
      return LocalModel(
        id: queryResult[i]['id'],
        latitude: queryResult[i]['latitude'],
        longitude: queryResult[i]['longitude'],
        idRota: queryResult[i]['idRota'],
      );
    });
  }
}