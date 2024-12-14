import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB('local.db');
    return _database!;
  }

  Future<Database> _initializeDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    telefone TEXT NOT NULL,
    email TEXT
    )''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('user', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('user');
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(Contact contact) async {
    final db = await database;
    return await db.update(
      'user',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
}
