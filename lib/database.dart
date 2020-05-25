import 'dart:io';

import 'package:flutterappfirst/imageList.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

var test = eat(id: 1, image_path: 'testPath', text: 'testText');

void insertDB(int id, String path, String text) async {
  var tmpEat = eat(id: id, image_path: path, text: text);

  final database = openDatabase(
    join(await getDatabasesPath(), 'eat_app.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE eat(id INTEGER PRIMARY KEY, image_path TEXT, text TEXT)",
      );
    },

    version: 1,
  );

  void insertdb(eat eatins) async {
    final Database db = await database;

    await db.insert(
      'eat',
      eatins.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  insertdb(tmpEat);

  print('DB');
}

Future<eat> readDB(int id) async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'eat_app.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE eat(id INTEGER PRIMARY KEY, image_path TEXT, text TEXT)",
      );
    },
    version: 1,
  );

  Future<eat> read(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('eat');
    var res = eat(
        id: maps[id]['id'],
        image_path: maps[id]['image_path'],
        text: maps[id]['text']);
    print('path from DB = ${res.image_path}');

    return res;


    /* return List.generate(maps.length, (i) {
      return eat(
        id: maps[i]['id'],
        image_path: maps[i]['image_path'],
        text: maps[i]['text'],
      );
    });*/
  }


  return read(id);


  print('DB');
}
