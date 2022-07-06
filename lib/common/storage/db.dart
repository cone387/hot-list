import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:hot_list/common/logger.dart';

abstract class SqliteDB {
  static Database? _db;

  static Database get db => _db!;

  static Future<void> init(
      {String name: "app.db",
      Function(Database db, int version)? onInit}) async {
    String path = await getDatabasesPath() + '/' + name;
    logger.d("db path is $path");
    _db = await openDatabase(path, onCreate: onInit);
  }
}
