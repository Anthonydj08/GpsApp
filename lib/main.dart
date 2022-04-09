import 'package:flutter/material.dart';
import 'database/database.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHandler();
  await db.initializeDB();
  runApp(
    const Routes(),
  );
}